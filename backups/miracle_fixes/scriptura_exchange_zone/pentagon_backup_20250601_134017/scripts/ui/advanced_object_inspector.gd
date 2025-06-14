# ==================================================
# SCRIPT NAME: advanced_object_inspector.gd
# DESCRIPTION: Advanced object inspector with full scene editing capabilities
# PURPOSE: Edit any property, save/load scenes, integrate with Floodgate
# CREATED: 2025-05-28 - Enhanced scene editing system
# ==================================================

extends UniversalBeingBase
signal property_changed(object: Node, property: String, new_value: Variant)
signal scene_save_requested(scene_data: Dictionary)
signal scene_load_requested(scene_path: String)
signal object_deleted(object: Node)
signal object_duplicated(object: Node, duplicate: Node)
signal transform_gizmo_requested(object: Node)
signal inspector_closed()

# UI Components - Main Panel
var inspector_panel: PanelContainer
var title_bar: HBoxContainer
var title_label: Label
var close_button: Button
var pin_button: Button
var menu_button: MenuButton

# UI Components - Content
var content_tabs: TabContainer
var properties_tab: Control
var transform_tab: Control
var materials_tab: Control
var physics_tab: Control
var scene_tab: Control

# Property Editor Components
var search_field: LineEdit
var properties_scroll: ScrollContainer
var properties_container: VBoxContainer
var property_editors: Dictionary = {}

# Transform Components
var position_editor: Control
var rotation_editor: Control
var scale_editor: Control
var global_transform_toggle: CheckBox
var transform_reset_button: Button
var snap_settings: Control

# Scene Management Components  
var scene_tree_view: Tree
var scene_save_button: Button
var scene_load_button: Button
var scene_file_dialog: FileDialog
var node_create_button: Button
var node_delete_button: Button
var node_duplicate_button: Button

# Current State
var target_object: Node = null
var is_pinned: bool = false
var show_hidden_properties: bool = false
var show_read_only: bool = true
var property_filter: String = ""
var edit_history: Array = []  # For undo/redo
var max_history: int = 50

# Property Categories (Enhanced)
var property_categories = {
	"Transform": ["position", "rotation", "scale", "global_position", "global_rotation", "global_transform"],
	"Node": ["name", "visible", "modulate", "process_mode", "process_priority", "z_index"],
	"Physics": ["mass", "gravity_scale", "linear_damp", "angular_damp", "freeze", "linear_velocity", "angular_velocity"],
	"Collision": ["collision_layer", "collision_mask", "disabled", "shape", "one_way_collision"],
	"Material": ["albedo_color", "metallic", "roughness", "emission", "normal_scale", "ao_strength"],
	"Light": ["light_energy", "light_color", "shadow_enabled", "shadow_bias", "light_size"],
	"Mesh": ["mesh", "material_override", "cast_shadow", "gi_mode", "lod_bias"],
	"Animation": ["current_animation", "playback_speed", "autoplay", "blend_time"],
	"Audio": ["stream", "volume_db", "pitch_scale", "autoplay", "bus"],
	"Camera": ["fov", "near", "far", "projection", "current", "cull_mask"],
	"Particles": ["emitting", "amount", "lifetime", "preprocess", "speed_scale", "explosiveness"],
	"Custom": []  # For script-exposed properties
}

# Editor Types Registry (will be populated when custom editors are created)
var custom_editors = {}

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_setup_shortcuts()
	hide()
	print("[AdvancedObjectInspector] Enhanced inspector ready with scene editing")

func _setup_ui() -> void:
	# Main panel with enhanced styling
	inspector_panel = PanelContainer.new()
	inspector_panel.name = "AdvancedInspectorPanel"
	inspector_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	inspector_panel.custom_minimum_size = Vector2(450, 700)
	add_child(inspector_panel)
	
	# Main container
	var main_vbox = VBoxContainer.new()
	FloodgateController.universal_add_child(main_vbox, inspector_panel)
	
	# Title bar with controls
	_create_title_bar(main_vbox)
	
	# Tab container for organized editing
	content_tabs = TabContainer.new()
	content_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(content_tabs, main_vbox)
	
	# Create tabs
	_create_properties_tab()
	_create_transform_tab()
	_create_materials_tab()
	_create_physics_tab()
	_create_scene_tab()
	
	# Apply advanced styling
	_apply_advanced_style()

func _create_title_bar(parent: VBoxContainer) -> void:
	title_bar = HBoxContainer.new()
	FloodgateController.universal_add_child(title_bar, parent)
	
	# Title with icon
	title_label = Label.new()
	title_label.text = "🔍 Advanced Inspector"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(title_label, title_bar)
	
	# Menu button for options
	menu_button = MenuButton.new()
	menu_button.text = "⚙️"
	menu_button.flat = true
	var popup = menu_button.get_popup()
	popup.add_check_item("Show Hidden Properties", 0)
	popup.add_check_item("Show Read-Only", 1)
	popup.add_separator()
	popup.add_item("Export Properties", 2)
	popup.add_item("Import Properties", 3)
	popup.add_separator()
	popup.add_item("Reset All", 4)
	FloodgateController.universal_add_child(menu_button, title_bar)
	
	# Pin button
	pin_button = Button.new()
	pin_button.text = "📌"
	pin_button.tooltip_text = "Pin Inspector"
	pin_button.toggle_mode = true
	pin_button.custom_minimum_size = Vector2(30, 30)
	FloodgateController.universal_add_child(pin_button, title_bar)
	
	# Close button
	close_button = Button.new()
	close_button.text = "✕"
	close_button.custom_minimum_size = Vector2(30, 30)
	FloodgateController.universal_add_child(close_button, title_bar)

func _create_properties_tab() -> void:
	properties_tab = VBoxContainer.new()
	properties_tab.name = "Properties"
	FloodgateController.universal_add_child(properties_tab, content_tabs)
	
	# Search with filters
	var search_container = HBoxContainer.new()
	FloodgateController.universal_add_child(search_container, properties_tab)
	
	search_field = LineEdit.new()
	search_field.placeholder_text = "Filter properties..."
	search_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(search_field, search_container)
	
	var clear_search = Button.new()
	clear_search.text = "✕"
	clear_search.pressed.connect(func(): search_field.text = "")
	FloodgateController.universal_add_child(clear_search, search_container)
	
	# Properties scroll
	properties_scroll = ScrollContainer.new()
	properties_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(properties_scroll, properties_tab)
	
	properties_container = VBoxContainer.new()
	properties_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(properties_container, properties_scroll)

func _create_transform_tab() -> void:
	transform_tab = VBoxContainer.new()
	transform_tab.name = "Transform"
	FloodgateController.universal_add_child(transform_tab, content_tabs)
	
	# Transform mode toggle
	global_transform_toggle = CheckBox.new()
	global_transform_toggle.text = "Edit Global Transform"
	FloodgateController.universal_add_child(global_transform_toggle, transform_tab)
	
	# Position editor
	var pos_label = Label.new()
	pos_label.text = "Position:"
	FloodgateController.universal_add_child(pos_label, transform_tab)
	position_editor = _create_vector3_editor()
	FloodgateController.universal_add_child(position_editor, transform_tab)
	
	# Rotation editor
	var rot_label = Label.new()
	rot_label.text = "Rotation (degrees):"
	FloodgateController.universal_add_child(rot_label, transform_tab)
	rotation_editor = _create_vector3_editor()
	FloodgateController.universal_add_child(rotation_editor, transform_tab)
	
	# Scale editor
	var scale_label = Label.new()
	scale_label.text = "Scale:"
	FloodgateController.universal_add_child(scale_label, transform_tab)
	scale_editor = _create_vector3_editor()
	FloodgateController.universal_add_child(scale_editor, transform_tab)
	
	# Transform tools
	var tools_container = HBoxContainer.new()
	FloodgateController.universal_add_child(tools_container, transform_tab)
	
	transform_reset_button = Button.new()
	transform_reset_button.text = "Reset Transform"
	FloodgateController.universal_add_child(transform_reset_button, tools_container)
	
	var snap_button = Button.new()
	snap_button.text = "Snap Settings"
	FloodgateController.universal_add_child(snap_button, tools_container)

func _create_materials_tab() -> void:
	materials_tab = VBoxContainer.new()
	materials_tab.name = "Materials"
	FloodgateController.universal_add_child(materials_tab, content_tabs)
	
	var mat_label = Label.new()
	mat_label.text = "Material properties and shaders"
	FloodgateController.universal_add_child(mat_label, materials_tab)

func _create_physics_tab() -> void:
	physics_tab = VBoxContainer.new()
	physics_tab.name = "Physics"
	FloodgateController.universal_add_child(physics_tab, content_tabs)
	
	var phys_label = Label.new()
	phys_label.text = "Physics body settings and collision"
	FloodgateController.universal_add_child(phys_label, physics_tab)

func _create_scene_tab() -> void:
	scene_tab = VBoxContainer.new()
	scene_tab.name = "Scene"
	FloodgateController.universal_add_child(scene_tab, content_tabs)
	
	# Scene tree view
	scene_tree_view = Tree.new()
	scene_tree_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene_tree_view.hide_root = true
	FloodgateController.universal_add_child(scene_tree_view, scene_tab)
	
	# Scene operation buttons
	var scene_buttons = HBoxContainer.new()
	FloodgateController.universal_add_child(scene_buttons, scene_tab)
	
	node_create_button = Button.new()
	node_create_button.text = "➕ Add Node"
	FloodgateController.universal_add_child(node_create_button, scene_buttons)
	
	node_duplicate_button = Button.new()
	node_duplicate_button.text = "📋 Duplicate"
	FloodgateController.universal_add_child(node_duplicate_button, scene_buttons)
	
	node_delete_button = Button.new()
	node_delete_button.text = "🗑️ Delete"
	FloodgateController.universal_add_child(node_delete_button, scene_buttons)
	
	# Save/Load buttons
	var file_buttons = HBoxContainer.new()
	FloodgateController.universal_add_child(file_buttons, scene_tab)
	
	scene_save_button = Button.new()
	scene_save_button.text = "💾 Save Scene"
	FloodgateController.universal_add_child(scene_save_button, file_buttons)
	
	scene_load_button = Button.new()
	scene_load_button.text = "📁 Load Scene"
	FloodgateController.universal_add_child(scene_load_button, file_buttons)
	
	# File dialog
	scene_file_dialog = FileDialog.new()
	scene_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	scene_file_dialog.add_filter("*.tscn", "Godot Scene")
	scene_file_dialog.add_filter("*.scn", "Binary Scene")
	add_child(scene_file_dialog)

func _create_vector3_editor() -> HBoxContainer:
	var container = HBoxContainer.new()
	
	for axis in ["X", "Y", "Z"]:
		var label = Label.new()
		label.text = axis + ":"
		label.custom_minimum_size.x = 20
		FloodgateController.universal_add_child(label, container)
		
		var spinbox = SpinBox.new()
		spinbox.value = 0.0
		spinbox.step = 0.01
		spinbox.allow_greater = true
		spinbox.allow_lesser = true
		spinbox.custom_minimum_size.x = 80
		FloodgateController.universal_add_child(spinbox, container)
	
	return container

func _apply_advanced_style() -> void:
	# Enhanced dark theme
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.18, 0.98)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.3, 0.5, 0.9, 0.9)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_size = 8
	
	inspector_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Title styling
	title_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	title_label.add_theme_font_size_override("font_size", 16)

func _connect_signals() -> void:
	# Title bar
	close_button.pressed.connect(_on_close_pressed)
	pin_button.toggled.connect(_on_pin_toggled)
	menu_button.get_popup().id_pressed.connect(_on_menu_item_selected)
	
	# Search
	search_field.text_changed.connect(_on_search_changed)
	
	# Transform
	global_transform_toggle.toggled.connect(_on_global_transform_toggled)
	transform_reset_button.pressed.connect(_on_transform_reset)
	
	# Scene operations
	node_create_button.pressed.connect(_on_create_node)
	node_duplicate_button.pressed.connect(_on_duplicate_node)
	node_delete_button.pressed.connect(_on_delete_node)
	scene_save_button.pressed.connect(_on_save_scene)
	scene_load_button.pressed.connect(_on_load_scene)
	scene_tree_view.item_selected.connect(_on_scene_tree_item_selected)
	
	# File dialog
	scene_file_dialog.file_selected.connect(_on_scene_file_selected)

func _setup_shortcuts() -> void:
	# Add keyboard shortcuts
	var _shortcuts = {
		"ui_cancel": _on_close_pressed,
		"ui_undo": _undo_last_change,
		"ui_redo": _redo_last_change
	}

# ================================
# INSPECTION FUNCTIONALITY
# ================================


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
func inspect_object(object: Node) -> void:
	if not object:
		print("[AdvancedInspector] Cannot inspect null object")
		return
	
	# Store in history
	if target_object != object:
		_add_to_history(target_object)
	
	target_object = object
	title_label.text = "🔍 " + object.name + " [" + object.get_class() + "]"
	
	# Update all tabs
	_update_properties_tab()
	_update_transform_tab()
	_update_materials_tab()
	_update_physics_tab()
	_update_scene_tab()
	
	show()
	print("[AdvancedInspector] Inspecting: " + object.name)

func _update_properties_tab() -> void:
	_clear_properties()
	_populate_properties()

func _update_transform_tab() -> void:
	if not target_object:
		return
	
	if target_object is Node3D:
		var node3d = target_object as Node3D
		
		# Update position
		var pos_editors = position_editor.get_children()
		pos_editors[1].value = node3d.position.x  # X spinbox
		pos_editors[3].value = node3d.position.y  # Y spinbox
		pos_editors[5].value = node3d.position.z  # Z spinbox
		
		# Update rotation (convert to degrees)
		var rot_editors = rotation_editor.get_children()
		rot_editors[1].value = rad_to_deg(node3d.rotation.x)
		rot_editors[3].value = rad_to_deg(node3d.rotation.y)
		rot_editors[5].value = rad_to_deg(node3d.rotation.z)
		
		# Update scale
		var scale_editors = scale_editor.get_children()
		scale_editors[1].value = node3d.scale.x
		scale_editors[3].value = node3d.scale.y
		scale_editors[5].value = node3d.scale.z

func _update_materials_tab() -> void:
	# TODO: Implement material editing
	pass

func _update_physics_tab() -> void:
	# TODO: Implement physics editing
	pass

func _update_scene_tab() -> void:
	scene_tree_view.clear()
	if not target_object:
		return
	
	# Build scene tree from target's parent
	var root_node = target_object.get_tree().current_scene
	if root_node:
		_build_scene_tree(root_node, null)

func _build_scene_tree(node: Node, parent_item: TreeItem) -> void:
	var item = scene_tree_view.create_item(parent_item)
	item.set_text(0, node.name + " [" + node.get_class() + "]")
	item.set_metadata(0, node)
	
	# Highlight current target
	if node == target_object:
		item.set_custom_bg_color(0, Color(0.3, 0.5, 0.8, 0.3))
	
	# Add children
	for child in node.get_children():
		_build_scene_tree(child, item)

# ================================
# PROPERTY EDITING (Enhanced)
# ================================

func _populate_properties() -> void:
	if not target_object:
		return
	
	var property_list = target_object.get_property_list()
	var categorized = _categorize_properties(property_list)
	
	for category in categorized:
		if categorized[category].size() > 0:
			_create_category_section(category, categorized[category])

func _categorize_properties(property_list: Array) -> Dictionary:
	var categorized = {}
	for category in property_categories:
		categorized[category] = []
	categorized["Other"] = []
	categorized["Script Variables"] = []
	
	for property in property_list:
		var prop_name = property.name
		var category_found = false
		
		# Check predefined categories
		for category in property_categories:
			if prop_name in property_categories[category]:
				categorized[category].append(property)
				category_found = true
				break
		
		# Script variables
		if not category_found and property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			categorized["Script Variables"].append(property)
		elif not category_found:
			categorized["Other"].append(property)
	
	return categorized

func _create_category_section(category_name: String, properties: Array) -> void:
	# Collapsible category header
	var header_container = HBoxContainer.new()
	FloodgateController.universal_add_child(header_container, properties_container)
	
	var expand_button = Button.new()
	expand_button.text = "▼"
	expand_button.flat = true
	expand_button.custom_minimum_size = Vector2(20, 20)
	FloodgateController.universal_add_child(expand_button, header_container)
	
	var category_label = Label.new()
	category_label.text = category_name + " (" + str(properties.size()) + ")"
	category_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	category_label.add_theme_font_size_override("font_size", 14)
	FloodgateController.universal_add_child(category_label, header_container)
	
	# Category content
	var category_content = VBoxContainer.new()
	FloodgateController.universal_add_child(category_content, properties_container)
	
	# Toggle visibility
	expand_button.pressed.connect(func():
		category_content.visible = !category_content.visible
		expand_button.text = "▼" if category_content.visible else "▶"
	)
	
	# Add properties
	for property in properties:
		_create_enhanced_property_editor(property, category_content)

func _create_enhanced_property_editor(property: Dictionary, parent: Control) -> void:
	var prop_name = property.name
	var prop_type = property.type
	
	if not _should_show_property(property):
		return
	
	# Property container with hover effect
	var prop_container = PanelContainer.new()
	FloodgateController.universal_add_child(prop_container, parent)
	
	var prop_hbox = HBoxContainer.new()
	FloodgateController.universal_add_child(prop_hbox, prop_container)
	
	# Property label with tooltip
	var prop_label = Label.new()
	prop_label.text = _humanize_property_name(prop_name)
	prop_label.custom_minimum_size.x = 140
	prop_label.tooltip_text = "Property: " + prop_name + "\nType: " + _get_type_name(prop_type)
	FloodgateController.universal_add_child(prop_label, prop_hbox)
	
	# Current value
	var current_value = target_object.get(prop_name)
	
	# Create appropriate editor
	var editor = _create_advanced_editor_for_type(prop_type, current_value, property)
	if editor:
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		FloodgateController.universal_add_child(editor, prop_hbox)
		property_editors[prop_name] = editor
		
		# Connect value change signal
		_connect_advanced_editor_signal(editor, prop_name, prop_type)
		
		# Add reset button for modified properties
		if _is_property_modified(prop_name, current_value):
			var reset_button = Button.new()
			reset_button.text = "↺"
			reset_button.tooltip_text = "Reset to default"
			reset_button.custom_minimum_size = Vector2(24, 24)
			reset_button.pressed.connect(func(): _reset_property(prop_name))
			FloodgateController.universal_add_child(reset_button, prop_hbox)

func _create_advanced_editor_for_type(type: int, current_value: Variant, property: Dictionary) -> Control:
	# Check for custom editor first
	var type_name = _get_type_name(type)
	if type_name in custom_editors and custom_editors[type_name]:
		var custom_editor = custom_editors[type_name].new()
		custom_editor.set_value(current_value)
		return custom_editor
	
	# Enhanced default editors
	match type:
		TYPE_BOOL:
			var checkbox = CheckBox.new()
			checkbox.button_pressed = current_value
			checkbox.text = "Enabled" if current_value else "Disabled"
			return checkbox
		
		TYPE_INT:
			var container = HBoxContainer.new()
			var spinbox = SpinBox.new()
			spinbox.value = current_value
			spinbox.step = 1
			spinbox.allow_greater = true
			spinbox.allow_lesser = true
			spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			FloodgateController.universal_add_child(spinbox, container)
			
			# Add slider for constrained values
			if property.has("hint") and property.hint == PROPERTY_HINT_RANGE:
				var slider = HSlider.new()
				slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				_setup_range_from_hint(slider, property.hint_string)
				slider.value = current_value
				FloodgateController.universal_add_child(slider, container)
				slider.value_changed.connect(func(val): spinbox.value = val)
				spinbox.value_changed.connect(func(val): slider.value = val)
			
			return container
		
		TYPE_FLOAT:
			var container = HBoxContainer.new()
			var spinbox = SpinBox.new()
			spinbox.value = current_value
			spinbox.step = 0.001
			spinbox.allow_greater = true
			spinbox.allow_lesser = true
			spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			FloodgateController.universal_add_child(spinbox, container)
			
			# Add slider for constrained values
			if property.has("hint") and property.hint == PROPERTY_HINT_RANGE:
				var slider = HSlider.new()
				slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				_setup_range_from_hint(slider, property.hint_string)
				slider.value = current_value
				FloodgateController.universal_add_child(slider, container)
				slider.value_changed.connect(func(val): spinbox.value = val)
				spinbox.value_changed.connect(func(val): slider.value = val)
			
			return container
		
		TYPE_STRING:
			# Multi-line for long strings
			if str(current_value).length() > 50:
				var text_edit = TextEdit.new()
				text_edit.text = str(current_value)
				text_edit.custom_minimum_size = Vector2(200, 60)
				return text_edit
			else:
				var line_edit = LineEdit.new()
				line_edit.text = str(current_value)
				line_edit.custom_minimum_size.x = 200
				return line_edit
		
		TYPE_COLOR:
			var color_picker = ColorPickerButton.new()
			color_picker.color = current_value
			color_picker.custom_minimum_size = Vector2(100, 24)
			return color_picker
		
		TYPE_VECTOR2:
			return _create_vector2_editor(current_value)
		
		TYPE_VECTOR3:
			return _create_vector3_editor_with_value(current_value)
		
		TYPE_TRANSFORM3D:
			var container = VBoxContainer.new()
			var label = Label.new()
			label.text = "Transform3D Editor"
			FloodgateController.universal_add_child(label, container)
			# TODO: Add full transform editor
			return container
		
		TYPE_OBJECT:
			var container = HBoxContainer.new()
			var label = Label.new()
			if current_value:
				label.text = current_value.get_class()
			else:
				label.text = "null"
			label.add_theme_color_override("font_color", Color.GRAY)
			FloodgateController.universal_add_child(label, container)
			
			# Add buttons for object references
			if current_value:
				var inspect_button = Button.new()
				inspect_button.text = "🔍"
				inspect_button.tooltip_text = "Inspect this object"
				inspect_button.pressed.connect(func(): inspect_object(current_value))
				FloodgateController.universal_add_child(inspect_button, container)
			
			var assign_button = Button.new()
			assign_button.text = "..."
			assign_button.tooltip_text = "Assign object"
			FloodgateController.universal_add_child(assign_button, container)
			
			return container
		
		TYPE_ARRAY:
			var container = VBoxContainer.new()
			var header = HBoxContainer.new()
			FloodgateController.universal_add_child(header, container)
			
			var label = Label.new()
			label.text = "Array[" + str(current_value.size()) + "]"
			FloodgateController.universal_add_child(label, header)
			
			var expand_button = Button.new()
			expand_button.text = "Edit"
			expand_button.pressed.connect(func(): _open_array_editor(property.name, current_value))
			FloodgateController.universal_add_child(expand_button, header)
			
			return container
		
		_:
			var label = Label.new()
			label.text = str(current_value)
			label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
			return label

func _create_vector2_editor(value: Vector2) -> HBoxContainer:
	var container = HBoxContainer.new()
	
	for component in ["x", "y"]:
		var spinbox = SpinBox.new()
		spinbox.value = value[component]
		spinbox.step = 0.001
		spinbox.allow_greater = true
		spinbox.allow_lesser = true
		spinbox.custom_minimum_size.x = 80
		FloodgateController.universal_add_child(spinbox, container)
	
	return container

func _create_vector3_editor_with_value(value: Vector3) -> HBoxContainer:
	var container = HBoxContainer.new()
	
	for i in range(3):
		var spinbox = SpinBox.new()
		spinbox.value = value[i]
		spinbox.step = 0.001
		spinbox.allow_greater = true
		spinbox.allow_lesser = true
		spinbox.custom_minimum_size.x = 65
		FloodgateController.universal_add_child(spinbox, container)
	
	return container

# ================================
# SCENE MANAGEMENT
# ================================

func _on_save_scene() -> void:
	scene_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	scene_file_dialog.popup_centered(Vector2(800, 600))

func _on_load_scene() -> void:
	scene_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	scene_file_dialog.popup_centered(Vector2(800, 600))

func _on_scene_file_selected(path: String) -> void:
	if scene_file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		_save_scene_to_file(path)
	else:
		_load_scene_from_file(path)

func _save_scene_to_file(path: String) -> void:
	if not target_object:
		return
	
	# Get the root to save (either target or its parent tree)
	var root_to_save = target_object.get_tree().current_scene
	
	# Create packed scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(root_to_save)
	
	# Save to file
	var error = ResourceSaver.save(packed_scene, path)
	if error == OK:
		print("[AdvancedInspector] Scene saved to: " + path)
	else:
		print("[AdvancedInspector] Failed to save scene: " + str(error))

func _load_scene_from_file(path: String) -> void:
	scene_load_requested.emit(path)

# ================================
# FLOODGATE INTEGRATION
# ================================

func request_floodgate_operation(operation: Dictionary) -> void:
	# Send operation through Floodgate system
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate and floodgate.has_method("queue_operation"):
		floodgate.queue_operation(operation)

func _on_create_node() -> void:
	# TODO: Show node creation dialog
	pass

func _on_duplicate_node() -> void:
	if not target_object:
		return
	
	var operation = {
		"type": "duplicate_node",
		"target": target_object,
		"parent": target_object.get_parent()
	}
	request_floodgate_operation(operation)

func _on_delete_node() -> void:
	if not target_object:
		return
	
	var operation = {
		"type": "delete_node",
		"target": target_object
	}
	request_floodgate_operation(operation)
	
	# Clear inspector after deletion
	target_object = null
	_clear_properties()
	hide()

# ================================
# HELPER FUNCTIONS
# ================================

func _humanize_property_name(prop_name: String) -> String:
	# Convert property_name to Property Name
	var words = prop_name.split("_")
	var result = ""
	for word in words:
		if word.length() > 0:
			result += word[0].to_upper() + word.substr(1) + " "
	return result.strip_edges()

func _get_type_name(type: int) -> String:
	match type:
		TYPE_NIL: return "Nil"
		TYPE_BOOL: return "Bool"
		TYPE_INT: return "Int"
		TYPE_FLOAT: return "Float"
		TYPE_STRING: return "String"
		TYPE_VECTOR2: return "Vector2"
		TYPE_VECTOR2I: return "Vector2i"
		TYPE_RECT2: return "Rect2"
		TYPE_RECT2I: return "Rect2i"
		TYPE_VECTOR3: return "Vector3"
		TYPE_VECTOR3I: return "Vector3i"
		TYPE_TRANSFORM2D: return "Transform2D"
		TYPE_VECTOR4: return "Vector4"
		TYPE_VECTOR4I: return "Vector4i"
		TYPE_PLANE: return "Plane"
		TYPE_QUATERNION: return "Quaternion"
		TYPE_AABB: return "AABB"
		TYPE_BASIS: return "Basis"
		TYPE_TRANSFORM3D: return "Transform3D"
		TYPE_PROJECTION: return "Projection"
		TYPE_COLOR: return "Color"
		TYPE_STRING_NAME: return "StringName"
		TYPE_NODE_PATH: return "NodePath"
		TYPE_RID: return "RID"
		TYPE_OBJECT: return "Object"
		TYPE_CALLABLE: return "Callable"
		TYPE_SIGNAL: return "Signal"
		TYPE_DICTIONARY: return "Dictionary"
		TYPE_ARRAY: return "Array"
		_: return "Unknown"

func _setup_range_from_hint(control: Range, hint_string: String) -> void:
	var parts = hint_string.split(",")
	if parts.size() >= 2:
		control.min_value = float(parts[0])
		control.max_value = float(parts[1])
		if parts.size() >= 3:
			control.step = float(parts[2])

func _is_property_modified(_prop_name: String, _value: Variant) -> bool:
	# TODO: Track default values
	return false

func _reset_property(_prop_name: String) -> void:
	# TODO: Reset to default value
	pass

func _add_to_history(object: Node) -> void:
	if not object:
		return
	edit_history.append(object)
	if edit_history.size() > max_history:
		edit_history.pop_front()

func _undo_last_change() -> void:
	# TODO: Implement undo
	pass

func _redo_last_change() -> void:
	# TODO: Implement redo
	pass

func _open_array_editor(_prop_name: String, _array: Array) -> void:
	# TODO: Open array editor dialog
	pass

# ================================
# EVENT HANDLERS
# ================================

func _on_close_pressed() -> void:
	if not is_pinned:
		hide()
		inspector_closed.emit()

func _on_pin_toggled(pressed: bool) -> void:
	is_pinned = pressed
	pin_button.modulate = Color.YELLOW if pressed else Color.WHITE

func _on_menu_item_selected(id: int) -> void:
	match id:
		0: # Show hidden properties
			show_hidden_properties = !show_hidden_properties
			_update_properties_tab()
		1: # Show read-only
			show_read_only = !show_read_only
			_update_properties_tab()
		2: # Export properties
			_export_properties()
		3: # Import properties
			_import_properties()
		4: # Reset all
			_reset_all_properties()

func _on_search_changed(text: String) -> void:
	property_filter = text
	_update_properties_tab()

func _on_global_transform_toggled(_enabled: bool) -> void:
	_update_transform_tab()

func _on_transform_reset() -> void:
	if not target_object or not target_object is Node3D:
		return
	
	var node3d = target_object as Node3D
	node3d.position = Vector3.ZERO
	node3d.rotation = Vector3.ZERO
	node3d.scale = Vector3.ONE
	_update_transform_tab()

func _on_scene_tree_item_selected() -> void:
	var item = scene_tree_view.get_selected()
	if item:
		var node = item.get_metadata(0)
		if node and is_instance_valid(node):
			inspect_object(node)

# ================================
# SIGNAL CONNECTIONS (Enhanced)
# ================================

func _connect_advanced_editor_signal(editor: Control, prop_name: String, prop_type: int) -> void:
	match prop_type:
		TYPE_BOOL:
			editor.toggled.connect(_on_bool_changed.bind(prop_name))
		TYPE_INT, TYPE_FLOAT:
			if editor is HBoxContainer and editor.get_child_count() > 0:
				editor.get_child(0).value_changed.connect(_on_number_changed.bind(prop_name))
			else:
				editor.value_changed.connect(_on_number_changed.bind(prop_name))
		TYPE_STRING:
			if editor is TextEdit:
				editor.text_changed.connect(func(): _on_string_changed(editor.text, prop_name))
			else:
				editor.text_submitted.connect(_on_string_changed.bind(prop_name))
		TYPE_COLOR:
			editor.color_changed.connect(_on_color_changed.bind(prop_name))
		TYPE_VECTOR2:
			var x_spin = editor.get_child(0)
			var y_spin = editor.get_child(1)
			x_spin.value_changed.connect(_on_vector2_changed.bind(prop_name, "x"))
			y_spin.value_changed.connect(_on_vector2_changed.bind(prop_name, "y"))
		TYPE_VECTOR3:
			for i in range(3):
				var spinbox = editor.get_child(i)
				spinbox.value_changed.connect(_on_vector3_component_changed.bind(prop_name, i))

func _on_color_changed(color: Color, prop_name: String) -> void:
	_apply_property_change(prop_name, color)

func _on_vector3_component_changed(value: float, prop_name: String, component: int) -> void:
	var current_vector = target_object.get(prop_name)
	current_vector[component] = value
	_apply_property_change(prop_name, current_vector)

# Reuse existing handlers from base class
func _on_bool_changed(value: bool, prop_name: String) -> void:
	_apply_property_change(prop_name, value)

func _on_number_changed(value: float, prop_name: String) -> void:
	var prop_type = typeof(target_object.get(prop_name))
	if prop_type == TYPE_INT:
		_apply_property_change(prop_name, int(value))
	else:
		_apply_property_change(prop_name, value)

func _on_string_changed(text: String, prop_name: String) -> void:
	_apply_property_change(prop_name, text)

func _on_vector2_changed(value: float, prop_name: String, component: String) -> void:
	var current_vector = target_object.get(prop_name)
	match component:
		"x": current_vector.x = value
		"y": current_vector.y = value
	_apply_property_change(prop_name, current_vector)

func _apply_property_change(prop_name: String, new_value: Variant) -> void:
	if not target_object:
		return
	
	# Store old value for undo
	var _old_value = target_object.get(prop_name)
	
	# Apply change
	target_object.set(prop_name, new_value)
	property_changed.emit(target_object, prop_name, new_value)
	
	print("[AdvancedInspector] %s.%s = %s" % [target_object.name, prop_name, str(new_value)])

func _clear_properties() -> void:
	for child in properties_container.get_children():
		child.queue_free()
	property_editors.clear()

func _should_show_property(property: Dictionary) -> bool:
	var prop_name = property.name
	
	# Filter by search
	if property_filter != "" and not prop_name.to_lower().contains(property_filter.to_lower()):
		return false
	
	# Hidden properties
	if not show_hidden_properties and prop_name.begins_with("_"):
		return false
	
	# Read-only check
	if not show_read_only and property.usage & PROPERTY_USAGE_READ_ONLY:
		return false
	
	# Skip internal properties
	var skip_list = ["script", "owner", "multiplayer"]
	if prop_name in skip_list:
		return false
	
	return true

# ================================
# IMPORT/EXPORT
# ================================

func _export_properties() -> void:
	if not target_object:
		return
	
	var data = {}
	for prop_name in property_editors:
		data[prop_name] = target_object.get(prop_name)
	
	# Save to clipboard as JSON
	var json_text = JSON.stringify(data, "\t")
	DisplayServer.clipboard_set(json_text)
	print("[AdvancedInspector] Properties exported to clipboard")

func _import_properties() -> void:
	if not target_object:
		return
	
	# Get from clipboard
	var json_text = DisplayServer.clipboard_get()
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error == OK:
		var data = json.data
		for prop_name in data:
			if target_object.has_method("set"):
				target_object.set(prop_name, data[prop_name])
		_update_properties_tab()
		print("[AdvancedInspector] Properties imported from clipboard")

func _reset_all_properties() -> void:
	# TODO: Implement reset all
	pass