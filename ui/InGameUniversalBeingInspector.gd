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
	add_to_group("inspector")  # Add to inspector group for bridge discovery
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Set high layer but below cursor (1000)
	z_index = 500
	
	create_inspector_ui()
	
	# Create bridge connection
	create_inspector_bridge()
	
	print("🔍 In-Game Universal Being Inspector ready")

func create_inspector_ui() -> void:
	"""Create the inspector interface"""
	
	# Main panel (positioned on right side) - WIDER for better visibility
	main_panel = Panel.new()
	main_panel.size = Vector2(600, 700)  # Increased width from 400 to 600
	main_panel.position = Vector2(get_viewport().get_visible_rect().size.x - 620, 20)
	
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
	header.size = Vector2(580, 30)  # Adjusted for wider panel
	header.position = Vector2(10, 10)
	main_panel.add_child(header)
	
	title_label = Label.new()
	title_label.text = "Universal Being Inspector"
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.add_theme_font_size_override("font_size", 16)
	header.add_child(title_label)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	
	close_button = Button.new()
	close_button.text = "×"
	close_button.size = Vector2(30, 30)
	close_button.add_theme_color_override("font_color", Color.WHITE)
	close_button.add_theme_font_size_override("font_size", 20)
	close_button.pressed.connect(_on_close_pressed)
	header.add_child(close_button)
	
	# Tab container
	tab_container = TabContainer.new()
	tab_container.size = Vector2(580, 640)  # Adjusted for wider panel
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
	
	# Ensure panel is within screen bounds
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = main_panel.size
	var margin = 20
	
	# Adjust position if panel would be off-screen
	if main_panel.position.x + panel_size.x > viewport_size.x - margin:
		main_panel.position.x = viewport_size.x - panel_size.x - margin
	if main_panel.position.y + panel_size.y > viewport_size.y - margin:
		main_panel.position.y = viewport_size.y - panel_size.y - margin
	
	# Ensure minimum position
	main_panel.position.x = max(margin, main_panel.position.x)
	main_panel.position.y = max(margin, main_panel.position.y)
	
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
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 2)
	
	# Create a properly formatted row
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	
	# Label with fixed width
	var label_node = Label.new()
	label_node.text = label + ":"
	label_node.custom_minimum_size.x = 150  # Fixed width for labels
	label_node.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
	label_node.add_theme_font_size_override("font_size", 12)
	hbox.add_child(label_node)
	
	# Value that can expand
	var value_node = Label.new()
	value_node.text = value
	value_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_node.add_theme_color_override("font_color", Color.WHITE)
	value_node.add_theme_font_size_override("font_size", 12)
	value_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Special formatting for different value types
	if value.begins_with("(") and value.ends_with(")"):
		# Vector formatting - make more readable
		value_node.text = format_vector(value)
	elif value.length() > 50:
		# Long values - add tooltip with full value
		value_node.tooltip_text = value
		value_node.text = value.substr(0, 47) + "..."
	
	hbox.add_child(value_node)
	
	container.add_child(hbox)
	
	# Add separator line
	var separator = HSeparator.new()
	separator.modulate = Color(0.3, 0.3, 0.3, 0.5)
	container.add_child(separator)
	
	properties_list.add_child(container)

func format_vector(vector_str: String) -> String:
	"""Format vector strings for better readability"""
	# Remove parentheses and split
	var cleaned = vector_str.strip_edges().trim_prefix("(").trim_suffix(")")
	var parts = cleaned.split(",")
	
	if parts.size() == 2:
		return "X: %s, Y: %s" % [parts[0].strip_edges(), parts[1].strip_edges()]
	elif parts.size() == 3:
		return "X: %s, Y: %s, Z: %s" % [parts[0].strip_edges(), parts[1].strip_edges(), parts[2].strip_edges()]
	
	return vector_str

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
	
	# Add some spacing before separator
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10
	target_list.add_child(spacer)
	
	if not text.is_empty():
		# Section header with background
		var header_container = PanelContainer.new()
		var header_style = StyleBoxFlat.new()
		header_style.bg_color = Color(0.2, 0.3, 0.4, 0.8)
		header_style.corner_radius_top_left = 4
		header_style.corner_radius_top_right = 4
		header_style.corner_radius_bottom_left = 4
		header_style.corner_radius_bottom_right = 4
		header_style.content_margin_left = 10
		header_style.content_margin_right = 10
		header_style.content_margin_top = 5
		header_style.content_margin_bottom = 5
		header_container.add_theme_stylebox_override("panel", header_style)
		
		var label = Label.new()
		label.text = text.to_upper()
		label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.6))
		label.add_theme_font_size_override("font_size", 14)
		# Use bold font style without loading external font
		label.add_theme_constant_override("font_outline_size", 1)
		label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.1))
		header_container.add_child(label)
		
		target_list.add_child(header_container)
	else:
		# Simple separator line
		var separator = HSeparator.new()
		separator.modulate = Color(0.5, 0.5, 0.5, 0.5)
		target_list.add_child(separator)
	
	# Add spacing after separator
	var spacer2 = Control.new()
	spacer2.custom_minimum_size.y = 5
	target_list.add_child(spacer2)

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

func refresh_properties() -> void:
	"""Refresh the properties display"""
	if current_being and properties_list:
		# Clear existing properties
		for child in properties_list.get_children():
			child.queue_free()
		
		# Repopulate with current being's properties
		populate_properties()

func populate_properties_list() -> void:
	"""Populate the properties list with current being data"""
	if not current_being or not properties_list:
		return
	
	# Clear existing
	for child in properties_list.get_children():
		child.queue_free()
	
	# Add properties
	populate_properties()

func create_inspector_bridge() -> void:
	"""Create or connect to the Universal Inspector Bridge"""
	var bridge = get_tree().get_nodes_in_group("inspector_bridge").front()
	if not bridge:
		# Create new bridge
		var BridgeClass = load("res://systems/UniversalInspectorBridge.gd")
		if BridgeClass:
			bridge = BridgeClass.new()
			bridge.name = "UniversalInspectorBridge"
			bridge.add_to_group("inspector_bridge")
			get_tree().current_scene.add_child(bridge)
			print("🔍 Created Universal Inspector Bridge")
	else:
		print("🔍 Connected to existing Inspector Bridge")

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