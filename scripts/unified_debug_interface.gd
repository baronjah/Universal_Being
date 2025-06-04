# Unified Debug Interface - Combines our detailed system with Luminus's elegant contract
# Automatically detects and uses Debuggable interface when available

extends UniversalScriptInspector
class_name UnifiedDebugInterface

# ===== LUMINUS INTEGRATION =====

func inspect_object(object: Node) -> void:
	"""Enhanced inspection that checks for Debuggable interface first"""
	if not object:
		return
	
	print("🔍 Inspecting: %s" % object.name)
	
	inspected_object = object
	update_header_info()
	
	# Check if object implements Debuggable interface (Luminus pattern)
	if has_debuggable_interface(object):
		print("✨ Using Debuggable interface for %s" % object.name)
		refresh_debuggable_inspector(object)
	else:
		print("🔧 Using LogicConnector fallback for %s" % object.name)
		refresh_inspector()  # Our original system
	
	show_inspector()
	inspection_started.emit(object)

func has_debuggable_interface(object: Node) -> bool:
	"""Check if object implements Debuggable interface"""
	return object.has_method("get_debug_payload") and \
		   object.has_method("set_debug_field") and \
		   object.has_method("get_debug_actions")

func refresh_debuggable_inspector(object: Node) -> void:
	"""Refresh inspector using Debuggable interface"""
	if not object or not has_debuggable_interface(object):
		refresh_inspector()  # Fallback to original system
		return
	
	# Clear existing editors
	clear_variable_editors()
	
	# Get debug payload from object
	var debug_payload = object.get_debug_payload()
	var debug_actions = object.get_debug_actions()
	
	# Create editors for payload fields
	create_debuggable_field_editors(debug_payload)
	
	# Create action buttons
	create_debuggable_action_buttons(debug_actions)

func create_debuggable_field_editors(payload: Dictionary) -> void:
	"""Create editors for Debuggable payload fields"""
	if payload.is_empty():
		# Show message that object has Debuggable interface but no debug fields
		var no_fields_label = Label.new()
		no_fields_label.text = "Object implements Debuggable but returns empty payload"
		no_fields_label.modulate = Color.GRAY
		variable_container.add_child(no_fields_label)
		return
	
	for field_name in payload.keys():
		var field_value = payload[field_name]
		create_debuggable_field_editor(field_name, field_value)

func create_debuggable_field_editor(field_name: String, field_value) -> void:
	"""Create editor for a specific Debuggable field"""
	# Container for this field
	var field_container = HBoxContainer.new()
	field_container.custom_minimum_size.y = 30
	variable_container.add_child(field_container)
	
	# Field name label
	var name_label = Label.new()
	name_label.text = field_name + ":"
	name_label.custom_minimum_size.x = 150
	name_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	field_container.add_child(name_label)
	
	# Create editor based on value type
	var editor = create_debuggable_editor_for_value(field_value, field_name)
	if editor:
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		field_container.add_child(editor)
		variable_editors[field_name] = editor
	
	# Type indicator
	var type_label = Label.new()
	type_label.text = get_value_type_name(field_value)
	type_label.custom_minimum_size.x = 80
	type_label.modulate = Color.YELLOW  # Different color for Debuggable fields
	field_container.add_child(type_label)

func create_debuggable_editor_for_value(value, field_name: String) -> Control:
	"""Create appropriate editor for Debuggable field value"""
	match typeof(value):
		TYPE_BOOL:
			return create_debuggable_bool_editor(value, field_name)
		TYPE_INT:
			return create_debuggable_int_editor(value, field_name)
		TYPE_FLOAT:
			return create_debuggable_float_editor(value, field_name)
		TYPE_STRING:
			return create_debuggable_string_editor(value, field_name)
		TYPE_VECTOR2:
			return create_debuggable_vector2_editor(value, field_name)
		TYPE_VECTOR3:
			return create_debuggable_vector3_editor(value, field_name)
		TYPE_VECTOR2I:
			return create_debuggable_vector2i_editor(value, field_name)
		TYPE_VECTOR3I:
			return create_debuggable_vector3i_editor(value, field_name)
		TYPE_COLOR:
			return create_debuggable_color_editor(value, field_name)
		_:
			return create_debuggable_generic_editor(value, field_name)

# ===== DEBUGGABLE EDITORS =====

func create_debuggable_bool_editor(value: bool, field_name: String) -> CheckBox:
	"""Create boolean editor for Debuggable field"""
	var checkbox = CheckBox.new()
	checkbox.button_pressed = value
	checkbox.toggled.connect(func(pressed): _on_debuggable_field_changed(field_name, pressed))
	return checkbox

func create_debuggable_int_editor(value: int, field_name: String) -> SpinBox:
	"""Create integer editor for Debuggable field"""
	var spinbox = SpinBox.new()
	spinbox.value = value
	spinbox.step = 1
	spinbox.allow_greater = true
	spinbox.allow_lesser = true
	spinbox.value_changed.connect(func(new_value): _on_debuggable_field_changed(field_name, int(new_value)))
	return spinbox

func create_debuggable_float_editor(value: float, field_name: String) -> SpinBox:
	"""Create float editor for Debuggable field"""
	var spinbox = SpinBox.new()
	spinbox.value = value
	spinbox.step = 0.1
	spinbox.allow_greater = true
	spinbox.allow_lesser = true
	spinbox.value_changed.connect(func(new_value): _on_debuggable_field_changed(field_name, new_value))
	return spinbox

func create_debuggable_string_editor(value: String, field_name: String) -> LineEdit:
	"""Create string editor for Debuggable field"""
	var line_edit = LineEdit.new()
	line_edit.text = str(value)
	line_edit.text_submitted.connect(func(new_text): _on_debuggable_field_changed(field_name, new_text))
	return line_edit

func create_debuggable_vector3_editor(value: Vector3, field_name: String) -> HBoxContainer:
	"""Create Vector3 editor for Debuggable field"""
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
	
	var update_vector3 = func():
		var new_vector = Vector3(x_spin.value, y_spin.value, z_spin.value)
		_on_debuggable_field_changed(field_name, new_vector)
	
	x_spin.value_changed.connect(func(_val): update_vector3.call())
	y_spin.value_changed.connect(func(_val): update_vector3.call())
	z_spin.value_changed.connect(func(_val): update_vector3.call())
	
	return container

func create_debuggable_vector2_editor(value: Vector2, field_name: String) -> HBoxContainer:
	"""Create Vector2 editor for Debuggable field"""
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
		_on_debuggable_field_changed(field_name, new_vector)
	
	x_spin.value_changed.connect(func(_val): update_vector2.call())
	y_spin.value_changed.connect(func(_val): update_vector2.call())
	
	return container

func create_debuggable_vector3i_editor(value: Vector3i, field_name: String) -> HBoxContainer:
	"""Create Vector3i editor for Debuggable field"""
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
		_on_debuggable_field_changed(field_name, new_vector)
	
	x_spin.value_changed.connect(func(_val): update_vector3i.call())
	y_spin.value_changed.connect(func(_val): update_vector3i.call())
	z_spin.value_changed.connect(func(_val): update_vector3i.call())
	
	return container

func create_debuggable_vector2i_editor(value: Vector2i, field_name: String) -> HBoxContainer:
	"""Create Vector2i editor for Debuggable field"""
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
		_on_debuggable_field_changed(field_name, new_vector)
	
	x_spin.value_changed.connect(func(_val): update_vector2i.call())
	y_spin.value_changed.connect(func(_val): update_vector2i.call())
	
	return container

func create_debuggable_color_editor(value: Color, field_name: String) -> ColorPicker:
	"""Create color editor for Debuggable field"""
	var color_picker = ColorPicker.new()
	color_picker.color = value
	color_picker.custom_minimum_size = Vector2(200, 150)
	color_picker.color_changed.connect(func(new_color): _on_debuggable_field_changed(field_name, new_color))
	return color_picker

func create_debuggable_generic_editor(value, field_name: String) -> LineEdit:
	"""Create generic editor for Debuggable field"""
	var line_edit = LineEdit.new()
	line_edit.text = str(value)
	line_edit.text_submitted.connect(func(new_text): _on_debuggable_field_changed(field_name, new_text))
	return line_edit

# ===== ACTION BUTTONS =====

func create_debuggable_action_buttons(actions: Dictionary) -> void:
	"""Create action buttons from Debuggable interface"""
	if actions.is_empty():
		return
	
	# Add separator
	var separator = HSeparator.new()
	variable_container.add_child(separator)
	
	# Add actions label
	var actions_label = Label.new()
	actions_label.text = "🎯 Debug Actions:"
	actions_label.add_theme_stylebox_override("normal", create_header_style())
	variable_container.add_child(actions_label)
	
	# Create buttons for each action
	for action_name in actions.keys():
		var action_callable = actions[action_name]
		create_debuggable_action_button(action_name, action_callable)

func create_debuggable_action_button(action_name: String, action_callable: Callable) -> void:
	"""Create a single action button"""
	var button_container = HBoxContainer.new()
	variable_container.add_child(button_container)
	
	var button = Button.new()
	button.text = action_name
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func(): execute_debuggable_action(action_name, action_callable))
	button_container.add_child(button)
	
	# Add description if available
	var desc_label = Label.new()
	desc_label.text = "Action"
	desc_label.modulate = Color.GRAY
	desc_label.custom_minimum_size.x = 80
	button_container.add_child(desc_label)

# ===== EVENT HANDLERS =====

func _on_debuggable_field_changed(field_name: String, new_value) -> void:
	"""Handle Debuggable field change"""
	if not inspected_object or not has_debuggable_interface(inspected_object):
		return
	
	print("🔧 Debuggable field changed: %s.%s = %s" % [inspected_object.name, field_name, new_value])
	
	# Call set_debug_field on the object
	inspected_object.set_debug_field(field_name, new_value)
	
	# Show visual feedback
	show_debuggable_change_feedback(field_name, new_value)

func execute_debuggable_action(action_name: String, action_callable: Callable) -> void:
	"""Execute a Debuggable action"""
	if not inspected_object:
		return
	
	print("⚡ Executing Debuggable action: %s on %s" % [action_name, inspected_object.name])
	
	try:
		action_callable.call()
		show_debuggable_action_feedback(action_name, true)
	except:
		print("❌ Failed to execute action: %s" % action_name)
		show_debuggable_action_feedback(action_name, false)

func show_debuggable_change_feedback(field_name: String, new_value) -> void:
	"""Show visual feedback for Debuggable field change"""
	if inspected_object and inspected_object is Node3D:
		create_floating_change_text(inspected_object, "Debuggable: %s = %s" % [field_name, str(new_value)])

func show_debuggable_action_feedback(action_name: String, success: bool) -> void:
	"""Show visual feedback for Debuggable action"""
	if inspected_object and inspected_object is Node3D:
		var text = "✅ %s" % action_name if success else "❌ %s failed" % action_name
		var color = Color.GREEN if success else Color.RED
		
		var label_3d = Label3D.new()
		label_3d.text = text
		label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label_3d.modulate = color
		label_3d.position = Vector3(0, 2.5, 0)
		
		inspected_object.add_child(label_3d)
		
		# Animate and remove
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(label_3d, "position:y", 4.5, 2.0)
		tween.parallel().tween_property(label_3d, "modulate:a", 0.0, 2.0)
		tween.tween_callback(label_3d.queue_free)

# ===== UTILITY FUNCTIONS =====

func get_value_type_name(value) -> String:
	"""Get human readable type name for any value"""
	match typeof(value):
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
	"""Enhanced header that shows debug interface type"""
	if not inspected_object:
		header_label.text = "No object selected"
		return
	
	var obj_name = inspected_object.name
	var obj_type = inspected_object.get_class()
	var debug_type = ""
	
	if has_debuggable_interface(inspected_object):
		debug_type = " [Debuggable]"
	elif inspected_object.has_method("pentagon_init"):
		debug_type = " [Universal Being]"
	else:
		debug_type = " [LogicConnector]"
	
	header_label.text = "🔍 %s (%s)%s" % [obj_name, obj_type, debug_type]