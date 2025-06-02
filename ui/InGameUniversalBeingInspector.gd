# ==================================================
# SCRIPT NAME: InGameUniversalBeingInspector.gd
# DESCRIPTION: In-game visual inspector for Universal Beings
# PURPOSE: Click on beings to inspect their properties, sockets, and components
# CREATED: 2025-06-03 - Claude Code Universal Being Inspector
# ==================================================

extends Control
class_name InGameUniversalBeingInspector

# Inspector state
var current_being: UniversalBeing = null
var is_visible_inspector: bool = false

# UI components
var main_panel: Panel
var title_label: Label
var close_button: Button
var tab_container: TabContainer

# Tabs
var properties_tab: ScrollContainer
var sockets_tab: ScrollContainer
var components_tab: ScrollContainer
var actions_tab: ScrollContainer

# Content containers
var properties_list: VBoxContainer
var sockets_list: VBoxContainer
var components_list: VBoxContainer
var actions_list: VBoxContainer

func _ready() -> void:
	name = "InGameUniversalBeingInspector"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Set high layer but below cursor (1000)
	z_index = 500
	
	create_inspector_ui()
	print("🔍 In-Game Universal Being Inspector ready")

func create_inspector_ui() -> void:
	"""Create the inspector interface"""
	
	# Main panel (positioned on right side)
	main_panel = Panel.new()
	main_panel.size = Vector2(400, 600)
	main_panel.position = Vector2(get_viewport().get_visible_rect().size.x - 420, 20)
	
	# Style the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	panel_style.border_color = Color(0.3, 0.7, 1.0, 1.0)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	main_panel.add_theme_stylebox_override("panel", panel_style)
	
	add_child(main_panel)
	
	# Title and close button
	var header = HBoxContainer.new()
	header.size = Vector2(380, 30)
	header.position = Vector2(10, 10)
	main_panel.add_child(header)
	
	title_label = Label.new()
	title_label.text = "Universal Being Inspector"
	title_label.add_theme_color_override("font_color", Color.WHITE)
	header.add_child(title_label)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	
	close_button = Button.new()
	close_button.text = "×"
	close_button.size = Vector2(30, 30)
	close_button.add_theme_color_override("font_color", Color.WHITE)
	close_button.pressed.connect(_on_close_pressed)
	header.add_child(close_button)
	
	# Tab container
	tab_container = TabContainer.new()
	tab_container.size = Vector2(380, 540)
	tab_container.position = Vector2(10, 50)
	main_panel.add_child(tab_container)
	
	# Create tabs
	create_properties_tab()
	create_sockets_tab()
	create_components_tab()
	create_actions_tab()

func create_properties_tab() -> void:
	"""Create properties inspection tab"""
	properties_tab = ScrollContainer.new()
	properties_tab.name = "🔍 Properties"
	tab_container.add_child(properties_tab)
	
	properties_list = VBoxContainer.new()
	properties_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	properties_tab.add_child(properties_list)

func create_sockets_tab() -> void:
	"""Create sockets inspection tab"""
	sockets_tab = ScrollContainer.new()
	sockets_tab.name = "🔌 Sockets"
	tab_container.add_child(sockets_tab)
	
	sockets_list = VBoxContainer.new()
	sockets_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sockets_tab.add_child(sockets_list)

func create_components_tab() -> void:
	"""Create components inspection tab"""
	components_tab = ScrollContainer.new()
	components_tab.name = "📦 Components"
	tab_container.add_child(components_tab)
	
	components_list = VBoxContainer.new()
	components_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	components_tab.add_child(components_list)

func create_actions_tab() -> void:
	"""Create actions inspection tab"""
	actions_tab = ScrollContainer.new()
	actions_tab.name = "⚡ Actions"
	tab_container.add_child(actions_tab)
	
	actions_list = VBoxContainer.new()
	actions_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions_tab.add_child(actions_list)

func inspect_being(being: UniversalBeing) -> void:
	"""Open inspector for a specific Universal Being"""
	if not being:
		return
		
	current_being = being
	title_label.text = "Inspecting: %s" % being.being_name
	
	# Populate all tabs
	populate_properties()
	populate_sockets()
	populate_components()
	populate_actions()
	
	# Show inspector
	show_inspector()
	
	print("🔍 Inspecting: %s (%s)" % [being.being_name, being.being_type])

func show_inspector() -> void:
	"""Show the inspector interface"""
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	is_visible_inspector = true
	
	# Animate in
	var tween = create_tween()
	main_panel.modulate.a = 0.0
	main_panel.scale = Vector2(0.8, 0.8)
	tween.parallel().tween_property(main_panel, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(main_panel, "scale", Vector2.ONE, 0.3)

func hide_inspector() -> void:
	"""Hide the inspector interface"""
	var tween = create_tween()
	tween.tween_property(main_panel, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): 
		visible = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		is_visible_inspector = false
	)

func populate_properties() -> void:
	"""Populate properties tab"""
	# Clear existing
	for child in properties_list.get_children():
		child.queue_free()
	
	if not current_being:
		return
	
	# Basic properties
	add_property_row("UUID", current_being.being_uuid)
	add_property_row("Name", current_being.being_name)
	add_property_row("Type", current_being.being_type)
	add_property_row("Consciousness", str(current_being.consciousness_level))
	add_property_row("Visual Layer", str(current_being.visual_layer))
	add_property_row("Pentagon Ready", str(current_being.pentagon_is_ready))
	add_property_row("Pentagon Active", str(current_being.pentagon_active))
	
	# Position information
	add_property_row("Position", str(current_being.position))
	add_property_row("Rotation", str(current_being.rotation))
	add_property_row("Scale", str(current_being.scale))
	
	# Evolution state
	if current_being.evolution_state:
		add_separator("Evolution State")
		add_property_row("Current Form", current_being.evolution_state.get("current_form", "unknown"))
		add_property_row("Evolution Count", str(current_being.evolution_state.get("evolution_count", 0)))
		var can_become = current_being.evolution_state.get("can_become", [])
		add_property_row("Can Become", str(can_become.size()) + " forms")

func populate_sockets() -> void:
	"""Populate sockets tab"""
	# Clear existing
	for child in sockets_list.get_children():
		child.queue_free()
	
	if not current_being or not current_being.socket_manager:
		add_info_label("No socket manager found")
		return
	
	var socket_config = current_being.get_socket_configuration()
	
	add_info_label("Total Sockets: %d" % socket_config.get("total_sockets", 0))
	add_separator("")
	
	# Group sockets by type
	var socket_types = {}
	for socket_id in socket_config.get("sockets", {}):
		var socket_data = socket_config.sockets[socket_id]
		var socket_type = socket_data.get("type", "unknown")
		
		if not socket_types.has(socket_type):
			socket_types[socket_type] = []
		socket_types[socket_type].append(socket_data)
	
	# Display by type
	for socket_type in socket_types:
		add_separator(socket_type.capitalize() + " Sockets")
		for socket_data in socket_types[socket_type]:
			add_socket_row(socket_data)

func populate_components() -> void:
	"""Populate components tab"""
	# Clear existing
	for child in components_list.get_children():
		child.queue_free()
	
	if not current_being:
		return
	
	var components = current_being.components
	add_info_label("Total Components: %d" % components.size())
	add_separator("")
	
	if components.is_empty():
		add_info_label("No components loaded")
		return
	
	for component_path in components:
		add_component_row(component_path)

func populate_actions() -> void:
	"""Populate actions tab"""
	# Clear existing
	for child in actions_list.get_children():
		child.queue_free()
	
	if not current_being:
		return
	
	# Available methods
	add_separator("Available Methods")
	var methods = current_being.get_all_methods()
	for method in methods:
		if method.begins_with("pentagon_") or method.begins_with("ai_"):
			add_action_button(method)
	
	# AI Interface
	add_separator("AI Interface")
	var ai_interface = current_being.ai_interface()
	for key in ai_interface:
		add_property_row(key, str(ai_interface[key]))

func add_property_row(label: String, value: String) -> void:
	"""Add a property row to properties list"""
	var hbox = HBoxContainer.new()
	
	var label_node = Label.new()
	label_node.text = label + ":"
	label_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_node.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
	hbox.add_child(label_node)
	
	var value_node = Label.new()
	value_node.text = value
	value_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_node.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(value_node)
	
	properties_list.add_child(hbox)

func add_socket_row(socket_data: Dictionary) -> void:
	"""Add a socket row to sockets list"""
	var hbox = HBoxContainer.new()
	
	var name_label = Label.new()
	name_label.text = socket_data.get("name", "Unknown")
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_color_override("font_color", Color(0.8, 1.0, 0.8))
	hbox.add_child(name_label)
	
	var status_label = Label.new()
	var is_occupied = socket_data.get("occupied", false)
	status_label.text = "OCCUPIED" if is_occupied else "EMPTY"
	status_label.add_theme_color_override("font_color", Color.GREEN if is_occupied else Color.GRAY)
	hbox.add_child(status_label)
	
	sockets_list.add_child(hbox)

func add_component_row(component_path: String) -> void:
	"""Add a component row to components list"""
	var label = Label.new()
	label.text = component_path.get_file()
	label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	components_list.add_child(label)

func add_action_button(method_name: String) -> void:
	"""Add an action button to actions list"""
	var button = Button.new()
	button.text = method_name
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func(): _invoke_method(method_name))
	actions_list.add_child(button)

func add_separator(text: String) -> void:
	"""Add a separator with text"""
	var target_list = get_current_tab_list()
	if not target_list:
		return
	
	var separator = HSeparator.new()
	target_list.add_child(separator)
	
	if not text.is_empty():
		var label = Label.new()
		label.text = text
		label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.6))
		target_list.add_child(label)

func add_info_label(text: String) -> void:
	"""Add an info label to current tab"""
	var target_list = get_current_tab_list()
	if not target_list:
		return
	
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	target_list.add_child(label)

func get_current_tab_list() -> VBoxContainer:
	"""Get the current tab's content list"""
	var current_tab = tab_container.get_current_tab_control()
	if current_tab == properties_tab:
		return properties_list
	elif current_tab == sockets_tab:
		return sockets_list
	elif current_tab == components_tab:
		return components_list
	elif current_tab == actions_tab:
		return actions_list
	return null

func _invoke_method(method_name: String) -> void:
	"""Invoke a method on the current being"""
	if not current_being or not current_being.has_method(method_name):
		print("❌ Method %s not found on %s" % [method_name, current_being.being_name])
		return
	
	print("⚡ Invoking %s on %s" % [method_name, current_being.being_name])
	current_being.call(method_name)

func _on_close_pressed() -> void:
	"""Close button pressed"""
	hide_inspector()

func _input(event: InputEvent) -> void:
	"""Handle input events"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				if is_visible_inspector:
					hide_inspector()
					get_viewport().set_input_as_handled()

# Static function to get or create inspector
static func get_inspector(parent: Node) -> InGameUniversalBeingInspector:
	"""Get existing inspector or create new one"""
	var existing = parent.get_node_or_null("InGameUniversalBeingInspector")
	if existing:
		return existing
	
	var inspector = InGameUniversalBeingInspector.new()
	parent.add_child(inspector)
	return inspector