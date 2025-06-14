# ==================================================
# SCRIPT NAME: object_inspector.gd
# DESCRIPTION: Object inspector interface for editing node properties
# PURPOSE: Allow runtime inspection and modification of scene objects
# CREATED: 2025-05-25 - Object property editor
# ==================================================

extends UniversalBeingBase
signal property_changed(object: Node, property: String, new_value: Variant)
signal inspector_closed()

# UI Components
var inspector_panel: PanelContainer
var title_bar: HBoxContainer
var title_label: Label
var close_button: Button
var content_scroll: ScrollContainer
var properties_container: VBoxContainer
var search_field: LineEdit

# Current target
var target_object: Node = null
var property_editors: Dictionary = {}

# Inspector settings
var show_hidden_properties: bool = false
var show_read_only_properties: bool = true
var property_filter: String = ""

# Property categories
var property_categories = {
	"Transform": ["position", "rotation", "scale", "global_position", "global_rotation"],
	"Node": ["name", "visible", "modulate", "process_mode"],
	"Physics": ["mass", "gravity_scale", "linear_damp", "angular_damp", "freeze"],
	"Collision": ["collision_layer", "collision_mask", "disabled"],
	"Material": ["albedo_color", "metallic", "roughness", "emission"],
	"Light": ["light_energy", "light_color", "shadow_enabled"],
	"Mesh": ["mesh", "material_override", "cast_shadow"]
}

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	hide()  # Start hidden
	print("[ObjectInspector] Inspector interface ready")

func _setup_ui() -> void:
	# Main panel
	inspector_panel = PanelContainer.new()
	inspector_panel.name = "InspectorPanel"
	inspector_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	inspector_panel.custom_minimum_size = Vector2(400, 600)
	add_child(inspector_panel)
	
	# Main container
	var main_vbox = VBoxContainer.new()
	FloodgateController.universal_add_child(main_vbox, inspector_panel)
	
	# Title bar
	title_bar = HBoxContainer.new()
	FloodgateController.universal_add_child(title_bar, main_vbox)
	
	title_label = Label.new()
	title_label.text = "Object Inspector"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(title_label, title_bar)
	
	close_button = Button.new()
	close_button.text = "✕"
	close_button.custom_minimum_size = Vector2(30, 30)
	FloodgateController.universal_add_child(close_button, title_bar)
	
	# Search field
	search_field = LineEdit.new()
	search_field.placeholder_text = "Filter properties..."
	FloodgateController.universal_add_child(search_field, main_vbox)
	
	# Scroll container for properties
	content_scroll = ScrollContainer.new()
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(content_scroll, main_vbox)
	
	# Properties container
	properties_container = VBoxContainer.new()
	properties_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(properties_container, content_scroll)
	
	# Style the panel
	_apply_inspector_style()

func _apply_inspector_style() -> void:
	# Create dark theme for inspector
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.2, 0.2, 0.25, 0.95)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.4, 0.6, 1.0, 0.8)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	
	inspector_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Style title
	title_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Style close button
	close_button.add_theme_color_override("font_color", Color.WHITE)

func _connect_signals() -> void:
	close_button.pressed.connect(_on_close_pressed)
	search_field.text_changed.connect(_on_search_changed)


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
		print("[ObjectInspector] Warning: Cannot inspect null object")
		return
	
	target_object = object
	title_label.text = "Inspector: " + object.name + " (" + object.get_class() + ")"
	
	_clear_properties()
	_populate_properties()
	
	show()
	print("[ObjectInspector] Inspecting object: " + object.name)

func _clear_properties() -> void:
	# Clear existing property editors
	for child in properties_container.get_children():
		child.queue_free()
	property_editors.clear()

func _populate_properties() -> void:
	if not target_object:
		return
	
	# Get all properties of the object
	var property_list = target_object.get_property_list()
	
	# Group properties by category
	var categorized_properties = {}
	for category in property_categories:
		categorized_properties[category] = []
	categorized_properties["Other"] = []
	
	for property in property_list:
		var prop_name = property.name
		var category_found = false
		
		for category in property_categories:
			if prop_name in property_categories[category]:
				categorized_properties[category].append(property)
				category_found = true
				break
		
		if not category_found:
			categorized_properties["Other"].append(property)
	
	# Create UI for each category
	for category in categorized_properties:
		var props = categorized_properties[category]
		if props.size() > 0:
			_create_category_section(category, props)

func _create_category_section(category_name: String, properties: Array) -> void:
	# Category header
	var category_label = Label.new()
	category_label.text = "▼ " + category_name
	category_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	FloodgateController.universal_add_child(category_label, properties_container)
	
	# Properties in this category
	for property in properties:
		_create_property_editor(property)

func _create_property_editor(property: Dictionary) -> void:
	var prop_name = property.name
	var prop_type = property.type
	
	# Skip properties that should be hidden
	if not _should_show_property(property):
		return
	
	# Property container
	var prop_container = HBoxContainer.new()
	FloodgateController.universal_add_child(prop_container, properties_container)
	
	# Property label
	var prop_label = Label.new()
	prop_label.text = prop_name + ":"
	prop_label.custom_minimum_size.x = 120
	FloodgateController.universal_add_child(prop_label, prop_container)
	
	# Get current value
	var current_value = target_object.get(prop_name)
	
	# Create appropriate editor based on type
	var editor = _create_editor_for_type(prop_type, current_value)
	if editor:
		FloodgateController.universal_add_child(editor, prop_container)
		property_editors[prop_name] = editor
		
		# Connect value change signal
		_connect_editor_signal(editor, prop_name, prop_type)

func _create_editor_for_type(type: int, current_value: Variant) -> Control:
	match type:
		TYPE_BOOL:
			var checkbox = CheckBox.new()
			checkbox.button_pressed = current_value
			return checkbox
		
		TYPE_INT:
			var spinbox = SpinBox.new()
			spinbox.value = current_value
			spinbox.step = 1
			spinbox.allow_greater = true
			spinbox.allow_lesser = true
			return spinbox
		
		TYPE_FLOAT:
			var spinbox = SpinBox.new()
			spinbox.value = current_value
			spinbox.step = 0.01
			spinbox.allow_greater = true
			spinbox.allow_lesser = true
			return spinbox
		
		TYPE_STRING:
			var line_edit = LineEdit.new()
			line_edit.text = str(current_value)
			line_edit.custom_minimum_size.x = 150
			return line_edit
		
		TYPE_VECTOR2:
			var container = HBoxContainer.new()
			var x_spin = SpinBox.new()
			var y_spin = SpinBox.new()
			x_spin.value = current_value.x
			y_spin.value = current_value.y
			x_spin.step = 0.01
			y_spin.step = 0.01
			x_spin.custom_minimum_size.x = 80
			y_spin.custom_minimum_size.x = 80
			FloodgateController.universal_add_child(x_spin, container)
			FloodgateController.universal_add_child(y_spin, container)
			return container
		
		TYPE_VECTOR3:
			var container = HBoxContainer.new()
			var x_spin = SpinBox.new()
			var y_spin = SpinBox.new()
			var z_spin = SpinBox.new()
			x_spin.value = current_value.x
			y_spin.value = current_value.y
			z_spin.value = current_value.z
			x_spin.step = 0.01
			y_spin.step = 0.01
			z_spin.step = 0.01
			x_spin.custom_minimum_size.x = 60
			y_spin.custom_minimum_size.x = 60
			z_spin.custom_minimum_size.x = 60
			FloodgateController.universal_add_child(x_spin, container)
			FloodgateController.universal_add_child(y_spin, container)
			FloodgateController.universal_add_child(z_spin, container)
			return container
		
		TYPE_OBJECT:
			var label = Label.new()
			if current_value:
				label.text = str(current_value.get_class()) + " (" + str(current_value) + ")"
			else:
				label.text = "null"
			label.add_theme_color_override("font_color", Color.GRAY)
			return label
		
		_:
			var label = Label.new()
			label.text = str(current_value)
			label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
			return label

func _connect_editor_signal(editor: Control, prop_name: String, prop_type: int) -> void:
	match prop_type:
		TYPE_BOOL:
			editor.toggled.connect(_on_bool_changed.bind(prop_name))
		TYPE_INT, TYPE_FLOAT:
			editor.value_changed.connect(_on_number_changed.bind(prop_name))
		TYPE_STRING:
			editor.text_submitted.connect(_on_string_changed.bind(prop_name))
		TYPE_VECTOR2:
			var x_spin = editor.get_child(0)
			var y_spin = editor.get_child(1)
			x_spin.value_changed.connect(_on_vector2_changed.bind(prop_name, "x"))
			y_spin.value_changed.connect(_on_vector2_changed.bind(prop_name, "y"))
		TYPE_VECTOR3:
			var x_spin = editor.get_child(0)
			var y_spin = editor.get_child(1)
			var z_spin = editor.get_child(2)
			x_spin.value_changed.connect(_on_vector3_changed.bind(prop_name, "x"))
			y_spin.value_changed.connect(_on_vector3_changed.bind(prop_name, "y"))
			z_spin.value_changed.connect(_on_vector3_changed.bind(prop_name, "z"))

func _should_show_property(property: Dictionary) -> bool:
	var prop_name = property.name
	
	# Filter by search text
	if property_filter != "" and not prop_name.to_lower().contains(property_filter.to_lower()):
		return false
	
	# Skip hidden properties unless requested
	if not show_hidden_properties and prop_name.begins_with("_"):
		return false
	
	# Skip some internal properties
	var skip_properties = ["script", "owner", "multiplayer", "tree_entered", "tree_exited"]
	if prop_name in skip_properties:
		return false
	
	return true

# Value change handlers
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
		"x":
			current_vector.x = value
		"y":
			current_vector.y = value
	_apply_property_change(prop_name, current_vector)

func _on_vector3_changed(value: float, prop_name: String, component: String) -> void:
	var current_vector = target_object.get(prop_name)
	match component:
		"x":
			current_vector.x = value
		"y":
			current_vector.y = value
		"z":
			current_vector.z = value
	_apply_property_change(prop_name, current_vector)

func _apply_property_change(prop_name: String, new_value: Variant) -> void:
	if not target_object:
		return
	
	# Try to set the property
	if target_object.has_method("set"):
		target_object.set(prop_name, new_value)
		property_changed.emit(target_object, prop_name, new_value)
		print("[ObjectInspector] Changed " + prop_name + " to " + str(new_value))
	else:
		print("[ObjectInspector] Error: Could not set property " + prop_name)

func _on_close_pressed() -> void:
	hide()
	inspector_closed.emit()

func _on_search_changed(text: String) -> void:
	property_filter = text
	if target_object:
		_clear_properties()
		_populate_properties()

# Public API
func toggle_hidden_properties() -> void:
	show_hidden_properties = !show_hidden_properties
	if target_object:
		_clear_properties()
		_populate_properties()

func set_target_object(object: Node) -> void:
	inspect_object(object)

func close_inspector() -> void:
	hide()
	target_object = null
	_clear_properties()

func is_inspecting() -> bool:
	return target_object != null and visible