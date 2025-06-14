# 🏛️ Enhanced Object Inspector - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: enhanced_object_inspector.gd
# DESCRIPTION: Perfect object inspector with live editing
# PURPOSE: Click any object to inspect and edit ALL properties
# CREATED: 2025-05-27
# ==================================================

extends UniversalBeingBase
signal object_selected(object: Node)
signal property_changed(object: Node, property: String, value: Variant)

# UI References
var panel: Panel
var title_label: Label
var properties_container: VBoxContainer
var scroll_container: ScrollContainer

# Inspection state
var current_object: Node = null
var current_uuid: String = ""
var property_editors: Dictionary = {}
var update_timer: Timer

# Layout settings
var panel_width: float = 400
var panel_margin: float = 20

func _ready() -> void:
	name = "EnhancedObjectInspector"
	
	# Create UI
	_create_inspector_ui()
	
	# Setup update timer for live values
	update_timer = TimerManager.get_timer()
	update_timer.wait_time = 0.1  # 10 FPS update
	update_timer.timeout.connect(_update_live_values)
	add_child(update_timer)
	
	# Start hidden
	visible = false
	
	print("✨ [ObjectInspector] Enhanced inspector ready!")

func _position_panel() -> void:
	"""Position the panel on the right side of the screen"""
	if panel:
		var viewport_size = get_viewport().size
		if viewport_size.x > 0:
			panel.position = Vector2(viewport_size.x - panel_width - panel_margin, panel_margin)
		else:
			panel.position = Vector2(1920 - panel_width - panel_margin, panel_margin)  # Fallback

func _create_inspector_ui() -> void:
	"""Create the inspector panel UI"""
	
	# Main panel
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(panel_width, 600)
	panel.size = Vector2(panel_width, 600)
	add_child(panel)
	
	# Defer positioning to ensure viewport is ready
	call_deferred("_position_panel")
	
	# Main container
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	FloodgateController.universal_add_child(vbox, panel)
	
	# Title
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.text = "Object Inspector"
	FloodgateController.universal_add_child(title_label, vbox)
	
	# Separator
	var sep = HSeparator.new()
	FloodgateController.universal_add_child(sep, vbox)
	
	# Scroll container for properties
	scroll_container = ScrollContainer.new()
	scroll_container.custom_minimum_size = Vector2(0, 500)
	FloodgateController.universal_add_child(scroll_container, vbox)
	
	# Properties container
	properties_container = VBoxContainer.new()
	properties_container.add_theme_constant_override("separation", 5)
	FloodgateController.universal_add_child(properties_container, scroll_container)
	
	# Close button
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(_on_close_pressed)
	FloodgateController.universal_add_child(close_btn, vbox)


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
func inspect_object(obj: Node) -> void:
	"""Inspect a specific object"""
	if not is_instance_valid(obj):
		return
	
	current_object = obj
	current_uuid = obj.get_meta("uuid", "")
	
	# Update title
	if title_label:
		title_label.text = "Inspecting: " + obj.name
	else:
		print("[ObjectInspector] Warning: title_label not ready yet")
	
	# Clear old properties
	if properties_container:
		for child in properties_container.get_children():
			child.queue_free()
		property_editors.clear()
	else:
		print("[ObjectInspector] Warning: properties_container not ready yet")
		return
	
	# Add properties
	_add_basic_properties()
	_add_transform_properties()
	_add_physics_properties()
	_add_metadata_properties()
	_add_custom_properties()
	
	# Show panel
	visible = true
	update_timer.start()
	
	# Emit signal
	object_selected.emit(obj)

func _add_basic_properties() -> void:
	"""Add basic object properties"""
	_add_section_header("Basic Properties")
	
	# Name
	_add_string_property("Name", "name", current_object.name)
	
	# Type
	_add_label_property("Type", current_object.get_class())
	
	# UUID
	if current_uuid:
		_add_label_property("UUID", current_uuid)
	
	# Groups
	var groups = current_object.get_groups()
	if groups.size() > 0:
		_add_label_property("Groups", ", ".join(groups))

func _add_transform_properties() -> void:
	"""Add transform properties for Node3D"""
	if not current_object is Node3D:
		return
	
	_add_section_header("Transform")
	
	# Position
	_add_vector3_property("Position", "position", current_object.position)
	
	# Rotation
	_add_vector3_property("Rotation", "rotation_degrees", current_object.rotation_degrees)
	
	# Scale
	_add_vector3_property("Scale", "scale", current_object.scale)

func _add_physics_properties() -> void:
	"""Add physics properties if applicable"""
	if current_object is RigidBody3D:
		_add_section_header("Physics")
		
		_add_float_property("Mass", "mass", current_object.mass)
		_add_float_property("Gravity Scale", "gravity_scale", current_object.gravity_scale)
		_add_bool_property("Freeze", "freeze", current_object.freeze)
		_add_vector3_property("Linear Velocity", "linear_velocity", current_object.linear_velocity)

func _add_metadata_properties() -> void:
	"""Add all metadata"""
	var meta_list = current_object.get_meta_list()
	if meta_list.size() == 0:
		return
	
	_add_section_header("Metadata")
	
	for meta_name in meta_list:
		var value = current_object.get_meta(meta_name)
		if value is String:
			_add_label_property(meta_name, value)
		elif value is bool:
			_add_bool_property(meta_name, "", value, true)  # true = is metadata
		elif value is int or value is float:
			_add_label_property(meta_name, str(value))
		else:
			_add_label_property(meta_name, str(value))

func _add_custom_properties() -> void:
	"""Add any custom properties from StandardizedObjects"""
	_add_section_header("Actions & Features")
	
	# Object type
	var obj_type = current_object.get_meta("object_type", "")
	if obj_type:
		_add_label_property("Object Type", obj_type)
	
	# Actions
	var actions = current_object.get_meta("actions", [])
	if actions.size() > 0:
		_add_label_property("Actions", ", ".join(actions))
	
	# Add action buttons
	for action in actions:
		_add_action_button(action)

# ========== PROPERTY EDITORS ==========

func _add_section_header(text: String) -> void:
	"""Add a section header"""
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	FloodgateController.universal_add_child(label, properties_container)
	
	var sep = HSeparator.new()
	FloodgateController.universal_add_child(sep, properties_container)

func _add_label_property(label: String, value: String) -> void:
	"""Add a read-only label"""
	var hbox = HBoxContainer.new()
	FloodgateController.universal_add_child(hbox, properties_container)
	
	var name_label = Label.new()
	name_label.text = label + ":"
	name_label.custom_minimum_size.x = 120
	FloodgateController.universal_add_child(name_label, hbox)
	
	var value_label = Label.new()
	value_label.text = value
	value_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	FloodgateController.universal_add_child(value_label, hbox)

func _add_string_property(label: String, property: String, value: String) -> void:
	"""Add an editable string property"""
	var hbox = HBoxContainer.new()
	FloodgateController.universal_add_child(hbox, properties_container)
	
	var name_label = Label.new()
	name_label.text = label + ":"
	name_label.custom_minimum_size.x = 120
	FloodgateController.universal_add_child(name_label, hbox)
	
	var line_edit = LineEdit.new()
	line_edit.text = value
	line_edit.custom_minimum_size.x = 200
	line_edit.text_changed.connect(func(new_text): _on_property_changed(property, new_text))
	FloodgateController.universal_add_child(line_edit, hbox)
	
	property_editors[property] = line_edit

func _add_float_property(label: String, property: String, value: float) -> void:
	"""Add an editable float property"""
	var hbox = HBoxContainer.new()
	FloodgateController.universal_add_child(hbox, properties_container)
	
	var name_label = Label.new()
	name_label.text = label + ":"
	name_label.custom_minimum_size.x = 120
	FloodgateController.universal_add_child(name_label, hbox)
	
	var spin_box = SpinBox.new()
	spin_box.value = value
	spin_box.step = 0.01
	spin_box.custom_minimum_size.x = 200
	spin_box.value_changed.connect(func(new_val): _on_property_changed(property, new_val))
	FloodgateController.universal_add_child(spin_box, hbox)
	
	property_editors[property] = spin_box

func _add_bool_property(label: String, property: String, value: bool, is_metadata: bool = false) -> void:
	"""Add an editable boolean property"""
	var hbox = HBoxContainer.new()
	FloodgateController.universal_add_child(hbox, properties_container)
	
	var name_label = Label.new()
	name_label.text = label + ":"
	name_label.custom_minimum_size.x = 120
	FloodgateController.universal_add_child(name_label, hbox)
	
	var check_box = CheckBox.new()
	check_box.button_pressed = value
	if not is_metadata:
		check_box.toggled.connect(func(pressed): _on_property_changed(property, pressed))
	else:
		check_box.disabled = true
	FloodgateController.universal_add_child(check_box, hbox)
	
	if not is_metadata:
		property_editors[property] = check_box

func _add_vector3_property(label: String, property: String, value: Vector3) -> void:
	"""Add an editable Vector3 property"""
	var hbox = HBoxContainer.new()
	FloodgateController.universal_add_child(hbox, properties_container)
	
	var name_label = Label.new()
	name_label.text = label + ":"
	name_label.custom_minimum_size.x = 120
	FloodgateController.universal_add_child(name_label, hbox)
	
	# X
	var x_spin = SpinBox.new()
	x_spin.value = value.x
	x_spin.step = 0.01
	x_spin.custom_minimum_size.x = 60
	x_spin.value_changed.connect(func(val): _on_vector3_component_changed(property, "x", val))
	FloodgateController.universal_add_child(x_spin, hbox)
	
	# Y
	var y_spin = SpinBox.new()
	y_spin.value = value.y
	y_spin.step = 0.01
	y_spin.custom_minimum_size.x = 60
	y_spin.value_changed.connect(func(val): _on_vector3_component_changed(property, "y", val))
	FloodgateController.universal_add_child(y_spin, hbox)
	
	# Z
	var z_spin = SpinBox.new()
	z_spin.value = value.z
	z_spin.step = 0.01
	z_spin.custom_minimum_size.x = 60
	z_spin.value_changed.connect(func(val): _on_vector3_component_changed(property, "z", val))
	FloodgateController.universal_add_child(z_spin, hbox)
	
	property_editors[property] = {"x": x_spin, "y": y_spin, "z": z_spin}

func _add_action_button(action: String) -> void:
	"""Add a button to trigger an action"""
	var btn = Button.new()
	btn.text = "▶ " + action.capitalize()
	btn.pressed.connect(func(): _trigger_action(action))
	FloodgateController.universal_add_child(btn, properties_container)

# ========== PROPERTY CHANGES ==========

func _on_property_changed(property: String, value: Variant) -> void:
	"""Handle property change"""
	if not is_instance_valid(current_object):
		return
	
	# Apply the change
	current_object.set(property, value)
	
	# If using UniversalObjectManager, notify it
	var uom = get_node_or_null("/root/UniversalObjectManager")
	if uom and current_uuid:
		uom.modify_object(current_uuid, {property: value})
	
	# Emit signal
	property_changed.emit(current_object, property, value)
	
	print("📝 [Inspector] Changed " + property + " to " + str(value))

func _on_vector3_component_changed(property: String, component: String, value: float) -> void:
	"""Handle Vector3 component change"""
	if not is_instance_valid(current_object):
		return
	
	var vec = current_object.get(property)
	match component:
		"x": vec.x = value
		"y": vec.y = value
		"z": vec.z = value
	
	_on_property_changed(property, vec)

func _trigger_action(action: String) -> void:
	"""Trigger an action on the object"""
	print("🎬 [Inspector] Triggering action: " + action)
	
	# TODO: Implement action system
	match action:
		"walk":
			if current_object.has_method("start_walking"):
				current_object.start_walking()
		"talk":
			if current_object.has_method("say_something"):
				current_object.say_something("Hello from inspector!")
		"float":
			if current_object is RigidBody3D:
				current_object.gravity_scale = -0.5
		_:
			print("⚠️ [Inspector] Action not implemented: " + action)

# ========== LIVE UPDATES ==========

func _update_live_values() -> void:
	"""Update values that change over time"""
	if not is_instance_valid(current_object):
		_on_close_pressed()
		return
	
	# Update position if it's changing
	if current_object is Node3D and "position" in property_editors:
		var editors = property_editors["position"]
		if editors is Dictionary:
			editors["x"].set_value_no_signal(current_object.position.x)
			editors["y"].set_value_no_signal(current_object.position.y)
			editors["z"].set_value_no_signal(current_object.position.z)
	
	# Update velocity for physics objects
	if current_object is RigidBody3D and "linear_velocity" in property_editors:
		var editors = property_editors["linear_velocity"]
		if editors is Dictionary:
			editors["x"].set_value_no_signal(current_object.linear_velocity.x)
			editors["y"].set_value_no_signal(current_object.linear_velocity.y)
			editors["z"].set_value_no_signal(current_object.linear_velocity.z)

func _on_close_pressed() -> void:
	"""Close the inspector"""
	visible = false
	update_timer.stop()
	current_object = null
	current_uuid = ""

# ========== INTEGRATION ==========

func setup_mouse_integration() -> void:
	"""Setup click-to-inspect functionality"""
	# This would be called by MouseInteractionSystem
	pass

func get_inspected_object() -> Node:
	"""Get currently inspected object"""
	return current_object