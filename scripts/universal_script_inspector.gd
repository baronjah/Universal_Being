# Universal Script Inspector - In-game variable debugging and live editing
# Click any Universal Being to inspect and modify its variables in real-time

extends Control
class_name UniversalScriptInspector

# ===== INSPECTOR PROPERTIES =====
@export var show_all_variables: bool = true
@export var show_private_variables: bool = false
@export var auto_refresh: bool = true
@export var refresh_rate: float = 0.5

# Inspector State
var inspected_object: Node = null
var variable_editors: Dictionary = {}
var property_list: Array = []
var inspector_window: Window = null
var variable_container: VBoxContainer = null

# Visual Components
var header_label: Label = null
var refresh_button: Button = null
var close_button: Button = null
var search_field: LineEdit = null

# Signals
signal variable_changed(object: Node, property: String, old_value, new_value)
signal inspection_started(object: Node)
signal inspection_ended(object: Node)

# ===== SETUP =====

func _ready() -> void:
	if not inspector_window:
		create_inspector_window()
	
	# Hide initially
	hide_inspector()
	
	print("🔍 Universal Script Inspector ready - click any Universal Being to inspect!")

func create_inspector_window() -> void:
	"""Create the floating inspector window"""
	inspector_window = Window.new()
	inspector_window.title = "🔍 Universal Script Inspector"
	inspector_window.size = Vector2(400, 600)
	inspector_window.position = Vector2(100, 100)
	inspector_window.min_size = Vector2(350, 400)
	
	# Make it always on top but not modal
	inspector_window.always_on_top = true
	inspector_window.unresizable = false
	
	# Create main container
	var main_container = VBoxContainer.new()
	inspector_window.add_child(main_container)
	
	# Header section
	create_header_section(main_container)
	
	# Search section
	create_search_section(main_container)
	
	# Scrollable variables section
	create_variables_section(main_container)
	
	# Control buttons
	create_control_buttons(main_container)
	
	# Add to scene
	get_tree().root.add_child(inspector_window)
	inspector_window.close_requested.connect(hide_inspector)

func create_header_section(parent: VBoxContainer) -> void:
	"""Create header with object info"""
	header_label = Label.new()
	header_label.text = "No object selected"
	header_label.add_theme_stylebox_override("normal", create_header_style())
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_label.custom_minimum_size.y = 40
	parent.add_child(header_label)

func create_search_section(parent: VBoxContainer) -> void:
	"""Create search field for filtering variables"""
	var search_container = HBoxContainer.new()
	parent.add_child(search_container)
	
	var search_label = Label.new()
	search_label.text = "Filter:"
	search_container.add_child(search_label)
	
	search_field = LineEdit.new()
	search_field.placeholder_text = "Search variables..."
	search_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_field.text_changed.connect(_on_search_changed)
	search_container.add_child(search_field)

func create_variables_section(parent: VBoxContainer) -> void:
	"""Create scrollable section for variables"""
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.custom_minimum_size.y = 400
	parent.add_child(scroll_container)
	
	variable_container = VBoxContainer.new()
	variable_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(variable_container)

func create_control_buttons(parent: VBoxContainer) -> void:
	"""Create control buttons"""
	var button_container = HBoxContainer.new()
	parent.add_child(button_container)
	
	refresh_button = Button.new()
	refresh_button.text = "🔄 Refresh"
	refresh_button.pressed.connect(refresh_inspector)
	button_container.add_child(refresh_button)
	
	var auto_refresh_check = CheckBox.new()
	auto_refresh_check.text = "Auto"
	auto_refresh_check.button_pressed = auto_refresh
	auto_refresh_check.toggled.connect(_on_auto_refresh_toggled)
	button_container.add_child(auto_refresh_check)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.add_child(spacer)
	
	close_button = Button.new()
	close_button.text = "❌ Close"
	close_button.pressed.connect(hide_inspector)
	button_container.add_child(close_button)

func create_header_style() -> StyleBox:
	"""Create header background style"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.3, 0.4, 0.8)
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color.WHITE
	return style

# ===== INSPECTION INTERFACE =====

func inspect_object(object: Node) -> void:
	"""Start inspecting a Universal Being or any Node"""
	if not object:
		return
	
	print("🔍 Inspecting: %s (%s)" % [object.name, object.get_script().get_path() if object.get_script() else "No script"])
	
	inspected_object = object
	update_header_info()
	refresh_inspector()
	show_inspector()
	
	inspection_started.emit(object)

func refresh_inspector() -> void:
	"""Refresh the variable list and values"""
	if not inspected_object or not is_instance_valid(inspected_object):
		hide_inspector()
		return
	
	# Clear existing editors
	clear_variable_editors()
	
	# Get current property list
	property_list = get_object_properties(inspected_object)
	
	# Create editors for each variable
	create_variable_editors()

func get_object_properties(object: Node) -> Array:
	"""Get all inspectable properties from an object"""
	var properties = []
	
	# Get script properties
	if object.get_script():
		var script_properties = object.get_property_list()
		for prop in script_properties:
			if should_show_property(prop):
				properties.append(prop)
	
	# Add special Universal Being properties
	if object.has_method("get_being_type"):
		properties.append({
			"name": "being_type",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			"custom": true
		})
	
	if object.has_method("get_consciousness_level"):
		properties.append({
			"name": "consciousness_level", 
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
			"custom": true
		})
	
	# Add position for spatial objects
	if object is Node3D:
		properties.append({
			"name": "global_position",
			"type": TYPE_VECTOR3,
			"usage": PROPERTY_USAGE_DEFAULT,
			"custom": true
		})
		
		properties.append({
			"name": "rotation",
			"type": TYPE_VECTOR3,
			"usage": PROPERTY_USAGE_DEFAULT,
			"custom": true
		})
	
	return properties

func should_show_property(prop: Dictionary) -> bool:
	"""Determine if a property should be shown"""
	var name = prop.name
	
	# Skip private unless enabled
	if name.begins_with("_") and not show_private_variables:
		return false
	
	# Skip built-in Godot internals
	if name in ["script", "get_script", "set_script"]:
		return false
	
	# Apply search filter
	if search_field and search_field.text.length() > 0:
		if not name.to_lower().contains(search_field.text.to_lower()):
			return false
	
	return true

# ===== VARIABLE EDITORS =====

func clear_variable_editors() -> void:
	"""Clear all existing variable editors"""
	for child in variable_container.get_children():
		child.queue_free()
	variable_editors.clear()

func create_variable_editors() -> void:
	"""Create editors for all variables"""
	for prop in property_list:
		create_variable_editor(prop)

func create_variable_editor(prop: Dictionary) -> void:
	"""Create an editor for a specific variable"""
	var prop_name = prop.name
	var prop_type = prop.get("type", TYPE_NIL)
	
	# Container for this property
	var prop_container = HBoxContainer.new()
	prop_container.custom_minimum_size.y = 30
	variable_container.add_child(prop_container)
	
	# Property name label
	var name_label = Label.new()
	name_label.text = prop_name + ":"
	name_label.custom_minimum_size.x = 150
	name_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	prop_container.add_child(name_label)
	
	# Get current value
	var current_value = get_property_value(inspected_object, prop_name, prop)
	
	# Create appropriate editor based on type
	var editor = create_editor_for_type(prop_type, current_value, prop_name)
	if editor:
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		prop_container.add_child(editor)
		variable_editors[prop_name] = editor
	
	# Type indicator
	var type_label = Label.new()
	type_label.text = get_type_name(prop_type)
	type_label.custom_minimum_size.x = 80
	type_label.modulate = Color.GRAY
	prop_container.add_child(type_label)

func create_editor_for_type(type: int, current_value, prop_name: String) -> Control:
	"""Create appropriate editor widget for variable type"""
	match type:
		TYPE_BOOL:
			return create_bool_editor(current_value, prop_name)
		TYPE_INT:
			return create_int_editor(current_value, prop_name)
		TYPE_FLOAT:
			return create_float_editor(current_value, prop_name)
		TYPE_STRING:
			return create_string_editor(current_value, prop_name)
		TYPE_VECTOR2:
			return create_vector2_editor(current_value, prop_name)
		TYPE_VECTOR3:
			return create_vector3_editor(current_value, prop_name)
		TYPE_VECTOR2I:
			return create_vector2i_editor(current_value, prop_name)
		TYPE_VECTOR3I:
			return create_vector3i_editor(current_value, prop_name)
		TYPE_COLOR:
			return create_color_editor(current_value, prop_name)
		_:
			return create_generic_editor(current_value, prop_name)

func create_bool_editor(value: bool, prop_name: String) -> CheckBox:
	"""Create boolean editor"""
	var checkbox = CheckBox.new()
	checkbox.button_pressed = value
	checkbox.toggled.connect(func(pressed): _on_variable_changed(prop_name, pressed))
	return checkbox

func create_int_editor(value: int, prop_name: String) -> SpinBox:
	"""Create integer editor"""
	var spinbox = SpinBox.new()
	spinbox.value = value
	spinbox.step = 1
	spinbox.allow_greater = true
	spinbox.allow_lesser = true
	spinbox.value_changed.connect(func(new_value): _on_variable_changed(prop_name, int(new_value)))
	return spinbox

func create_float_editor(value: float, prop_name: String) -> SpinBox:
	"""Create float editor"""
	var spinbox = SpinBox.new()
	spinbox.value = value
	spinbox.step = 0.1
	spinbox.allow_greater = true
	spinbox.allow_lesser = true
	spinbox.value_changed.connect(func(new_value): _on_variable_changed(prop_name, new_value))
	return spinbox

func create_string_editor(value: String, prop_name: String) -> LineEdit:
	"""Create string editor"""
	var line_edit = LineEdit.new()
	line_edit.text = str(value)
	line_edit.text_submitted.connect(func(new_text): _on_variable_changed(prop_name, new_text))
	return line_edit

func create_vector3_editor(value: Vector3, prop_name: String) -> HBoxContainer:
	"""Create Vector3 editor with X, Y, Z fields"""
	var container = HBoxContainer.new()
	
	var x_spin = SpinBox.new()
	x_spin.value = value.x
	x_spin.step = 0.1
	x_spin.allow_greater = true
	x_spin.allow_lesser = true
	x_spin.custom_minimum_size.x = 60
	container.add_child(x_spin)
	
	var y_spin = SpinBox.new()
	y_spin.value = value.y
	y_spin.step = 0.1
	y_spin.allow_greater = true
	y_spin.allow_lesser = true
	y_spin.custom_minimum_size.x = 60
	container.add_child(y_spin)
	
	var z_spin = SpinBox.new()
	z_spin.value = value.z
	z_spin.step = 0.1
	z_spin.allow_greater = true
	z_spin.allow_lesser = true
	z_spin.custom_minimum_size.x = 60
	container.add_child(z_spin)
	
	# Connect all three to update the Vector3
	var update_vector3 = func():
		var new_vector = Vector3(x_spin.value, y_spin.value, z_spin.value)
		_on_variable_changed(prop_name, new_vector)
	
	x_spin.value_changed.connect(func(_val): update_vector3.call())
	y_spin.value_changed.connect(func(_val): update_vector3.call())
	z_spin.value_changed.connect(func(_val): update_vector3.call())
	
	return container

func create_vector2_editor(value: Vector2, prop_name: String) -> HBoxContainer:
	"""Create Vector2 editor"""
	var container = HBoxContainer.new()
	
	var x_spin = SpinBox.new()
	x_spin.value = value.x
	x_spin.step = 0.1
	x_spin.allow_greater = true
	x_spin.allow_lesser = true
	container.add_child(x_spin)
	
	var y_spin = SpinBox.new()
	y_spin.value = value.y
	y_spin.step = 0.1
	y_spin.allow_greater = true
	y_spin.allow_lesser = true
	container.add_child(y_spin)
	
	var update_vector2 = func():
		var new_vector = Vector2(x_spin.value, y_spin.value)
		_on_variable_changed(prop_name, new_vector)
	
	x_spin.value_changed.connect(func(_val): update_vector2.call())
	y_spin.value_changed.connect(func(_val): update_vector2.call())
	
	return container

func create_vector3i_editor(value: Vector3i, prop_name: String) -> HBoxContainer:
	"""Create Vector3i editor"""
	var container = HBoxContainer.new()
	
	var x_spin = SpinBox.new()
	x_spin.value = value.x
	x_spin.step = 1
	x_spin.allow_greater = true
	x_spin.allow_lesser = true
	container.add_child(x_spin)
	
	var y_spin = SpinBox.new()
	y_spin.value = value.y
	y_spin.step = 1
	y_spin.allow_greater = true
	y_spin.allow_lesser = true
	container.add_child(y_spin)
	
	var z_spin = SpinBox.new()
	z_spin.value = value.z
	z_spin.step = 1
	z_spin.allow_greater = true
	z_spin.allow_lesser = true
	container.add_child(z_spin)
	
	var update_vector3i = func():
		var new_vector = Vector3i(int(x_spin.value), int(y_spin.value), int(z_spin.value))
		_on_variable_changed(prop_name, new_vector)
	
	x_spin.value_changed.connect(func(_val): update_vector3i.call())
	y_spin.value_changed.connect(func(_val): update_vector3i.call())
	z_spin.value_changed.connect(func(_val): update_vector3i.call())
	
	return container

func create_vector2i_editor(value: Vector2i, prop_name: String) -> HBoxContainer:
	"""Create Vector2i editor"""
	var container = HBoxContainer.new()
	
	var x_spin = SpinBox.new()
	x_spin.value = value.x
	x_spin.step = 1
	x_spin.allow_greater = true
	x_spin.allow_lesser = true
	container.add_child(x_spin)
	
	var y_spin = SpinBox.new()
	y_spin.value = value.y
	y_spin.step = 1
	y_spin.allow_greater = true
	y_spin.allow_lesser = true
	container.add_child(y_spin)
	
	var update_vector2i = func():
		var new_vector = Vector2i(int(x_spin.value), int(y_spin.value))
		_on_variable_changed(prop_name, new_vector)
	
	x_spin.value_changed.connect(func(_val): update_vector2i.call())
	y_spin.value_changed.connect(func(_val): update_vector2i.call())
	
	return container

func create_color_editor(value: Color, prop_name: String) -> ColorPicker:
	"""Create color editor"""
	var color_picker = ColorPicker.new()
	color_picker.color = value
	color_picker.custom_minimum_size = Vector2(200, 150)
	color_picker.color_changed.connect(func(new_color): _on_variable_changed(prop_name, new_color))
	return color_picker

func create_generic_editor(value, prop_name: String) -> LineEdit:
	"""Create generic text editor for unknown types"""
	var line_edit = LineEdit.new()
	line_edit.text = str(value)
	line_edit.text_submitted.connect(func(new_text): _on_variable_changed(prop_name, new_text))
	return line_edit

# ===== VALUE HANDLING =====

func get_property_value(object: Node, prop_name: String, prop: Dictionary):
	"""Get current value of a property"""
	if prop.get("custom", false):
		# Handle custom Universal Being properties
		match prop_name:
			"being_type":
				return object.being_type if object.has_method("get") else "unknown"
			"consciousness_level":
				return object.consciousness_level if object.has_method("get") else 0
			"global_position":
				return object.global_position if object is Node3D else Vector3.ZERO
			"rotation":
				return object.rotation if object is Node3D else Vector3.ZERO
	
	# Regular property
	if object.has_method("get"):
		return object.get(prop_name)
	else:
		return object.get(prop_name) if prop_name in object else null

func _on_variable_changed(prop_name: String, new_value) -> void:
	"""Handle variable change from editor"""
	if not inspected_object or not is_instance_valid(inspected_object):
		return
	
	var old_value = get_property_value(inspected_object, prop_name, {})
	
	# Set the new value
	set_property_value(inspected_object, prop_name, new_value)
	
	print("🔧 Changed %s.%s: %s → %s" % [inspected_object.name, prop_name, old_value, new_value])
	
	variable_changed.emit(inspected_object, prop_name, old_value, new_value)

func set_property_value(object: Node, prop_name: String, value) -> void:
	"""Set a property value on the object"""
	try:
		if object.has_method("set"):
			object.set(prop_name, value)
		else:
			object.set(prop_name, value)
	except:
		print("❌ Failed to set %s.%s = %s" % [object.name, prop_name, value])

# ===== UTILITY FUNCTIONS =====

func get_type_name(type: int) -> String:
	"""Get human readable type name"""
	match type:
		TYPE_BOOL: return "bool"
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "string"
		TYPE_VECTOR2: return "Vector2"
		TYPE_VECTOR3: return "Vector3"
		TYPE_VECTOR2I: return "Vector2i"
		TYPE_VECTOR3I: return "Vector3i"
		TYPE_COLOR: return "Color"
		TYPE_ARRAY: return "Array"
		TYPE_DICTIONARY: return "Dictionary"
		_: return "unknown"

func update_header_info() -> void:
	"""Update header with object information"""
	if not inspected_object:
		header_label.text = "No object selected"
		return
	
	var obj_name = inspected_object.name
	var obj_type = inspected_object.get_class()
	
	if inspected_object.has_method("get") and inspected_object.get("being_type"):
		obj_type = inspected_object.get("being_type")
	
	header_label.text = "🔍 %s (%s)" % [obj_name, obj_type]

func show_inspector() -> void:
	"""Show the inspector window"""
	if inspector_window:
		inspector_window.show()

func hide_inspector() -> void:
	"""Hide the inspector window"""
	if inspector_window:
		inspector_window.hide()
	
	if inspected_object:
		inspection_ended.emit(inspected_object)
		inspected_object = null

# ===== EVENT HANDLERS =====

func _on_search_changed(new_text: String) -> void:
	"""Handle search text change"""
	refresh_inspector()

func _on_auto_refresh_toggled(pressed: bool) -> void:
	"""Handle auto refresh toggle"""
	auto_refresh = pressed

func _process(delta: float) -> void:
	"""Auto refresh if enabled"""
	if auto_refresh and inspected_object and inspector_window and inspector_window.visible:
		refresh_inspector()
		await get_tree().create_timer(refresh_rate).timeout