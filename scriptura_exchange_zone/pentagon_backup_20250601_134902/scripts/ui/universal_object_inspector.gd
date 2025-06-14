# ==================================================
# SCRIPT NAME: universal_object_inspector.gd
# DESCRIPTION: Enhanced object inspector with Universal Being integration
# PURPOSE: Inspect and edit any object with transform gizmo controls
# CREATED: 2025-05-29 - Fixed version with proper UI initialization
# ==================================================

extends UniversalBeingBase
class_name UniversalObjectInspector

signal property_changed(object: Node, property: String, new_value: Variant)
signal inspector_closed()
signal gizmo_requested(target: Node)  # Request gizmo for selected object

# UI Components
var inspector_panel: PanelContainer
var title_bar: HBoxContainer
var title_label: Label = null  # Initialize as null for safety
var close_button: Button
var content_container: VBoxContainer
var transform_section: VBoxContainer
var properties_section: VBoxContainer

# Transform controls
var position_controls: Dictionary = {}
var rotation_controls: Dictionary = {}
var scale_controls: Dictionary = {}

# Current target
var target_object: Node = null
var is_ui_ready: bool = false

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "UniversalObjectInspector"
	_setup_ui()
	hide()  # Start hidden
	is_ui_ready = true
	print("[UniversalObjectInspector] Enhanced inspector ready")

func _setup_ui() -> void:
	# Main panel - positioned on the right side of screen
	inspector_panel = PanelContainer.new()
	inspector_panel.name = "InspectorPanel"
	inspector_panel.size = Vector2(400, 700)
	inspector_panel.position = Vector2(1920 - 420, 50)  # Right side with margin
	add_child(inspector_panel)
	
	# Main container
	var main_vbox = VBoxContainer.new()
	FloodgateController.universal_add_child(main_vbox, inspector_panel)
	
	# Title bar
	title_bar = HBoxContainer.new()
	FloodgateController.universal_add_child(title_bar, main_vbox)
	
	# Create and configure title label
	title_label = Label.new()
	title_label.text = "Universal Object Inspector"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(title_label, title_bar)
	
	close_button = Button.new()
	close_button.text = "✕"
	close_button.custom_minimum_size = Vector2(30, 30)
	close_button.pressed.connect(_on_close_pressed)
	FloodgateController.universal_add_child(close_button, title_bar)
	
	# Separator
	FloodgateController.universal_add_child(HSeparator.new(, main_vbox))
	
	# Scroll container
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(scroll, main_vbox)
	
	content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(content_container, scroll)
	
	# Create sections
	_create_transform_section()
	_create_gizmo_section()
	_create_properties_section()
	
	# Apply styling
	_apply_inspector_style()

func _create_transform_section() -> void:
	"""Create transform controls section with sliders"""
	
	# Transform header
	var transform_header = Label.new()
	transform_header.text = "Transform"
	transform_header.add_theme_font_size_override("font_size", 18)
	FloodgateController.universal_add_child(transform_header, content_container)
	
	transform_section = VBoxContainer.new()
	FloodgateController.universal_add_child(transform_section, content_container)
	
	# Position controls
	var pos_label = Label.new()
	pos_label.text = "Position"
	pos_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	FloodgateController.universal_add_child(pos_label, transform_section)
	
	for axis in ["x", "y", "z"]:
		var control = _create_axis_control("Position " + axis.to_upper(), axis, Color.RED if axis == "x" else (Color.GREEN if axis == "y" else Color.BLUE))
		position_controls[axis] = control
		FloodgateController.universal_add_child(control.container, transform_section)
	
	FloodgateController.universal_add_child(HSeparator.new(, transform_section))
	
	# Rotation controls
	var rot_label = Label.new()
	rot_label.text = "Rotation (degrees)"
	rot_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	FloodgateController.universal_add_child(rot_label, transform_section)
	
	for axis in ["x", "y", "z"]:
		var control = _create_axis_control("Rotation " + axis.to_upper(), axis, Color(0.8, 0.4, 0.4) if axis == "x" else (Color(0.4, 0.8, 0.4) if axis == "y" else Color(0.4, 0.4, 0.8)))
		rotation_controls[axis] = control
		FloodgateController.universal_add_child(control.container, transform_section)
	
	FloodgateController.universal_add_child(HSeparator.new(, transform_section))
	
	# Scale controls
	var scale_label = Label.new()
	scale_label.text = "Scale"
	scale_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	FloodgateController.universal_add_child(scale_label, transform_section)
	
	# Uniform scale
	var uniform_scale = _create_axis_control("Uniform Scale", "uniform", Color.WHITE)
	scale_controls["uniform"] = uniform_scale
	FloodgateController.universal_add_child(uniform_scale.container, transform_section)
	
	# Per-axis scale
	for axis in ["x", "y", "z"]:
		var control = _create_axis_control("Scale " + axis.to_upper(), axis, Color(0.6, 0.6, 0.6))
		scale_controls[axis] = control
		FloodgateController.universal_add_child(control.container, transform_section)
	
	FloodgateController.universal_add_child(HSeparator.new(, transform_section))
	
	# Gizmo button
	var gizmo_button = Button.new()
	gizmo_button.text = "Show 3D Gizmo"
	gizmo_button.pressed.connect(_on_gizmo_requested)
	FloodgateController.universal_add_child(gizmo_button, transform_section)

func _create_axis_control(label_text: String, axis: String, color: Color) -> Dictionary:
	"""Create a single axis control with slider and spinbox"""
	
	var container = HBoxContainer.new()
	
	# Colored axis indicator
	var color_rect = ColorRect.new()
	color_rect.color = color
	color_rect.custom_minimum_size = Vector2(4, 20)
	FloodgateController.universal_add_child(color_rect, container)
	
	# Label
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(80, 0)
	FloodgateController.universal_add_child(label, container)
	
	# Slider
	var slider = HSlider.new()
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = -100.0
	slider.max_value = 100.0
	slider.value = 0.0
	slider.step = 0.01
	FloodgateController.universal_add_child(slider, container)
	
	# SpinBox for precise input
	var spinbox = SpinBox.new()
	spinbox.min_value = -9999.0
	spinbox.max_value = 9999.0
	spinbox.value = 0.0
	spinbox.step = 0.01
	spinbox.custom_minimum_size = Vector2(80, 0)
	FloodgateController.universal_add_child(spinbox, container)
	
	# Connect controls
	slider.value_changed.connect(func(value): 
		spinbox.set_value_no_signal(value)
		_on_transform_changed(label_text.to_lower(), axis, value)
	)
	spinbox.value_changed.connect(func(value):
		slider.set_value_no_signal(value)
		_on_transform_changed(label_text.to_lower(), axis, value)
	)
	
	return {
		"container": container,
		"slider": slider,
		"spinbox": spinbox,
		"label": label
	}

func _create_gizmo_section() -> void:
	"""Create gizmo control section"""
	
	# Gizmo header
	var gizmo_header = Label.new()
	gizmo_header.text = "Gizmo Controls"
	gizmo_header.add_theme_font_size_override("font_size", 18)
	FloodgateController.universal_add_child(gizmo_header, content_container)
	
	# Gizmo buttons container
	var gizmo_container = VBoxContainer.new()
	FloodgateController.universal_add_child(gizmo_container, content_container)
	
	# Attach Gizmo button
	var attach_gizmo_btn = Button.new()
	attach_gizmo_btn.text = "🎯 Attach Gizmo"
	attach_gizmo_btn.pressed.connect(_on_attach_gizmo_pressed)
	FloodgateController.universal_add_child(attach_gizmo_btn, gizmo_container)
	
	# Gizmo mode buttons
	var mode_container = HBoxContainer.new()
	FloodgateController.universal_add_child(mode_container, gizmo_container)
	
	var translate_btn = Button.new()
	translate_btn.text = "Move"
	translate_btn.pressed.connect(func(): _set_gizmo_mode("translate"))
	FloodgateController.universal_add_child(translate_btn, mode_container)
	
	var rotate_btn = Button.new()
	rotate_btn.text = "Rotate"
	rotate_btn.pressed.connect(func(): _set_gizmo_mode("rotate"))
	FloodgateController.universal_add_child(rotate_btn, mode_container)
	
	var scale_btn = Button.new()
	scale_btn.text = "Scale"
	scale_btn.pressed.connect(func(): _set_gizmo_mode("scale"))
	FloodgateController.universal_add_child(scale_btn, mode_container)

func _create_properties_section() -> void:
	"""Create section for other properties"""
	
	# Properties header
	var props_header = Label.new()
	props_header.text = "Properties"
	props_header.add_theme_font_size_override("font_size", 18)
	FloodgateController.universal_add_child(props_header, content_container)
	
	properties_section = VBoxContainer.new()
	FloodgateController.universal_add_child(properties_section, content_container)
	
	# This will be populated when inspecting an object
	var placeholder = Label.new()
	placeholder.text = "Select an object to inspect"
	placeholder.modulate = Color(0.6, 0.6, 0.6)
	FloodgateController.universal_add_child(placeholder, properties_section)

func _apply_inspector_style() -> void:
	"""Apply dark theme styling"""
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.18, 0.95)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.4, 0.6, 1.0)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	
	inspector_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Title styling
	if title_label:
		title_label.add_theme_color_override("font_color", Color.WHITE)
		title_label.add_theme_font_size_override("font_size", 16)


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
	"""Inspect a node and populate controls"""
	
	if not is_ui_ready:
		print("[UniversalObjectInspector] UI not ready yet")
		return
		
	if not object:
		print("[UniversalObjectInspector] Cannot inspect null object")
		return
	
	target_object = object
	
	# Update title safely
	if title_label:
		title_label.text = "Inspector: " + object.name + " (" + object.get_class() + ")"
	
	# Update transform controls
	_update_transform_controls()
	
	# Update properties
	_update_properties()
	
	show()
	print("[UniversalObjectInspector] Inspecting: ", object.name)

func _update_transform_controls() -> void:
	"""Update transform sliders with current object values"""
	
	if not target_object:
		return
	
	# Update position
	if target_object is Node3D:
		var pos = target_object.position
		position_controls["x"].slider.set_value_no_signal(pos.x)
		position_controls["x"].spinbox.set_value_no_signal(pos.x)
		position_controls["y"].slider.set_value_no_signal(pos.y)
		position_controls["y"].spinbox.set_value_no_signal(pos.y)
		position_controls["z"].slider.set_value_no_signal(pos.z)
		position_controls["z"].spinbox.set_value_no_signal(pos.z)
		
		# Update rotation (convert to degrees)
		var rot = target_object.rotation_degrees
		rotation_controls["x"].slider.set_value_no_signal(rot.x)
		rotation_controls["x"].spinbox.set_value_no_signal(rot.x)
		rotation_controls["y"].slider.set_value_no_signal(rot.y)
		rotation_controls["y"].spinbox.set_value_no_signal(rot.y)
		rotation_controls["z"].slider.set_value_no_signal(rot.z)
		rotation_controls["z"].spinbox.set_value_no_signal(rot.z)
		
		# Update scale
		var scale = target_object.scale
		var uniform = (scale.x + scale.y + scale.z) / 3.0
		scale_controls["uniform"].slider.set_value_no_signal(uniform)
		scale_controls["uniform"].spinbox.set_value_no_signal(uniform)
		scale_controls["x"].slider.set_value_no_signal(scale.x)
		scale_controls["x"].spinbox.set_value_no_signal(scale.x)
		scale_controls["y"].slider.set_value_no_signal(scale.y)
		scale_controls["y"].spinbox.set_value_no_signal(scale.y)
		scale_controls["z"].slider.set_value_no_signal(scale.z)
		scale_controls["z"].spinbox.set_value_no_signal(scale.z)

func _update_properties() -> void:
	"""Update other properties section"""
	
	# Clear existing
	for child in properties_section.get_children():
		child.queue_free()
	
	if not target_object:
		return
	
	# Add basic properties
	if target_object is Node3D:
		_add_property_control("Visible", "visible", target_object.visible)
		
		if target_object is RigidBody3D:
			_add_property_control("Mass", "mass", target_object.mass)
			_add_property_control("Gravity Scale", "gravity_scale", target_object.gravity_scale)
			_add_property_control("Freeze", "freeze", target_object.freeze)

func _add_property_control(label: String, property: String, value: Variant) -> void:
	"""Add a property control to the properties section"""
	
	var container = HBoxContainer.new()
	FloodgateController.universal_add_child(container, properties_section)
	
	var prop_label = Label.new()
	prop_label.text = label
	prop_label.custom_minimum_size = Vector2(120, 0)
	FloodgateController.universal_add_child(prop_label, container)
	
	# Create appropriate control based on type
	if value is bool:
		var checkbox = CheckBox.new()
		checkbox.button_pressed = value
		checkbox.toggled.connect(func(pressed): _on_property_changed(property, pressed))
		FloodgateController.universal_add_child(checkbox, container)
	elif value is float or value is int:
		var spinbox = SpinBox.new()
		spinbox.value = value
		spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spinbox.value_changed.connect(func(new_val): _on_property_changed(property, new_val))
		FloodgateController.universal_add_child(spinbox, container)

func _on_transform_changed(transform_type: String, axis: String, value: float) -> void:
	"""Handle transform value changes"""
	
	if not target_object or not target_object is Node3D:
		return
	
	if transform_type.begins_with("position"):
		var pos = target_object.position
		match axis:
			"x": pos.x = value
			"y": pos.y = value
			"z": pos.z = value
		target_object.position = pos
		emit_signal("property_changed", target_object, "position", pos)
		
	elif transform_type.begins_with("rotation"):
		var rot = target_object.rotation_degrees
		match axis:
			"x": rot.x = value
			"y": rot.y = value
			"z": rot.z = value
		target_object.rotation_degrees = rot
		emit_signal("property_changed", target_object, "rotation_degrees", rot)
		
	elif transform_type.begins_with("scale"):
		var scale = target_object.scale
		if axis == "uniform":
			scale = Vector3(value, value, value)
			# Update individual controls
			scale_controls["x"].slider.set_value_no_signal(value)
			scale_controls["x"].spinbox.set_value_no_signal(value)
			scale_controls["y"].slider.set_value_no_signal(value)
			scale_controls["y"].spinbox.set_value_no_signal(value)
			scale_controls["z"].slider.set_value_no_signal(value)
			scale_controls["z"].spinbox.set_value_no_signal(value)
		else:
			match axis:
				"x": scale.x = value
				"y": scale.y = value
				"z": scale.z = value
		target_object.scale = scale
		emit_signal("property_changed", target_object, "scale", scale)

func _on_property_changed(property: String, value: Variant) -> void:
	"""Handle non-transform property changes"""
	
	if not target_object:
		return
	
	target_object.set(property, value)
	emit_signal("property_changed", target_object, property, value)

func _on_gizmo_requested() -> void:
	"""Request gizmo for current object"""
	
	if not target_object:
		print("[UniversalObjectInspector] No object selected for gizmo")
		return
	
	# Get or create Universal Gizmo System
	var gizmo_system = get_tree().get_first_node_in_group("universal_gizmo_system")
	if not gizmo_system:
		# Create the gizmo system
		var gizmo_script = load("res://scripts/core/universal_gizmo_system.gd")
		if gizmo_script:
			gizmo_system = Node3D.new()
			gizmo_system.set_script(gizmo_script)
			gizmo_system.name = "UniversalGizmoSystem"
			gizmo_system.add_to_group("universal_gizmo_system")
			
			# Add to scene
			var main_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
			FloodgateController.universal_add_child(gizmo_system, main_scene)
			
			print("[UniversalObjectInspector] Created Universal Gizmo System")
	
	if gizmo_system and gizmo_system.has_method("attach_to_object"):
		# Toggle gizmo
		if gizmo_system.target_object == target_object and gizmo_system.is_active:
			# Already attached to this object, detach
			gizmo_system.detach()
			_update_gizmo_button_text(false)
		else:
			# Attach to new object
			gizmo_system.attach_to_object(target_object)
			_update_gizmo_button_text(true)
	
	# Still emit signal for compatibility
	emit_signal("gizmo_requested", target_object)
	print("[UniversalObjectInspector] Gizmo toggled for: ", target_object.name)

func _update_gizmo_button_text(is_active: bool) -> void:
	"""Update gizmo button text based on state"""
	
	# Find the gizmo button
	var gizmo_button = null
	for child in transform_section.get_children():
		if child is Button and child.text.contains("Gizmo"):
			gizmo_button = child
			break
	
	if gizmo_button:
		gizmo_button.text = "Hide 3D Gizmo" if is_active else "Show 3D Gizmo"

func _on_close_pressed() -> void:
	"""Handle close button"""
	
	hide()
	emit_signal("inspector_closed")

# Console integration
func handle_command(command: String, args: Array) -> String:
	"""Handle inspector-related console commands"""
	
	match command:
		"inspect":
			if args.is_empty():
				return "Usage: inspect <object_name>"
			var obj = get_node_or_null("/root/MainGame/" + args[0])
			if obj:
				inspect_object(obj)
				return "Inspecting: " + obj.name
			return "Object not found: " + args[0]
		
		"inspector":
			if args.is_empty():
				toggle()
				return "Inspector toggled"
			match args[0]:
				"show": show(); return "Inspector shown"
				"hide": hide(); return "Inspector hidden"
				"toggle": toggle(); return "Inspector toggled"
		
		_:
			return "Unknown inspector command"
	
	return ""  # Default return for safety

func toggle() -> void:
	"""Toggle visibility"""
	visible = !visible

func _on_attach_gizmo_pressed() -> void:
	"""Handle attach gizmo button press"""
	_on_gizmo_requested()

func _set_gizmo_mode(mode: String) -> void:
	"""Set gizmo mode (translate, rotate, scale)"""
	var gizmo_system = get_tree().get_first_node_in_group("universal_gizmo_system")
	if gizmo_system and gizmo_system.has_method("set_mode"):
		gizmo_system.set_mode(mode)
		print("[UniversalObjectInspector] Set gizmo mode to: ", mode)
	else:
		print("[UniversalObjectInspector] Gizmo system not found or attached")