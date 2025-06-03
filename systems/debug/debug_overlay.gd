# Universal Debug Overlay (autoload UI) - Luminus's elegant debug interface
# Spawns translucent panel only when looking at debuggable object and pressing F4

extends Control

## Current debug target
var target: Object = null

# Scene references
@onready var panel: Panel = $Panel
@onready var tree: Tree = $Panel/MarginContainer/VBox/Tree
@onready var btns: HBoxContainer = $Panel/MarginContainer/VBox/Buttons
@onready var header_label: Label = $Panel/MarginContainer/VBox/Header/Title
@onready var close_button: Button = $Panel/MarginContainer/VBox/Header/CloseButton

# ===== SETUP =====

func _ready():
	name = "DebugOverlay"
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let clicks through when just the overlay
	
	# Set up panel styling
	setup_panel_style()
	
	# Connect UI elements
	if close_button:
		close_button.pressed.connect(hide_overlay)
	
	if tree:
		tree.item_edited.connect(_on_tree_edited)
		tree.set_column_title(0, "Property")
		tree.set_column_title(1, "Value") 
		tree.set_column_titles_visible(true)
	
	# Make panel block mouse events
	if panel:
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
	
	print("🎛️ Debug Overlay ready!")

func setup_panel_style():
	"""Setup the panel visual style"""
	if not panel:
		return
		
	# Make panel semi-transparent
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color.CYAN
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)

# ===== INPUT HANDLING =====

func _gui_input(event):
	"""Handle GUI input for closing overlay"""
	if visible and event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Check if click is outside panel
			var panel_rect = panel.get_global_rect()
			if not panel_rect.has_point(event.global_position):
				hide_overlay()
				get_viewport().set_input_as_handled()

func show_overlay():
	"""Show the debug overlay"""
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP  # Capture clicks when visible
	print("🎛️ Debug overlay shown")

func hide_overlay():
	"""Hide the debug overlay"""
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore clicks when hidden
	target = null
	print("🎛️ Debug overlay hidden")

# ===== PANEL POPULATION =====

func _populate_panel():
	"""Populate the debug panel with target's debug data"""
	if not target:
		print("❌ No target to populate panel!")
		return
	
	# Update header
	var target_name = target.name if target.has_method("get") else "Unknown"
	header_label.text = "🎛️ Debug: %s" % target_name
	print("🎛️ Populating debug panel for: %s" % target_name)
	
	# Clear existing content
	tree.clear()
	clear_buttons()
	
	# Populate tree with debug payload
	populate_tree()
	
	# Populate action buttons
	populate_buttons()

func populate_tree():
	"""Populate tree with debug payload from target"""
	var root = tree.create_item()
	root.set_text(0, "Debug Properties")
	
	var payload = target.get_debug_payload()
	
	# If no manual payload, try reflection
	if payload.is_empty() and target.has_method("reflect_debug_data"):
		print("🔍 Using reflection to get debug data...")
		payload = target.reflect_debug_data()
	
	for key in payload.keys():
		var value = payload[key]
		var item = tree.create_item(root)
		item.set_text(0, str(key))
		item.set_editable(1, true)
		item.set_text(1, str(value))
		
		# Set different colors based on value type
		set_item_color_by_type(item, value)
	
	# Expand root by default
	root.set_collapsed(false)

func set_item_color_by_type(item: TreeItem, value):
	"""Set item color based on value type"""
	var color = Color.WHITE
	
	match typeof(value):
		TYPE_BOOL:
			color = Color.CYAN if value else Color.GRAY
		TYPE_INT, TYPE_FLOAT:
			color = Color.YELLOW
		TYPE_STRING:
			color = Color.GREEN
		TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR2I, TYPE_VECTOR3I:
			color = Color.MAGENTA
		TYPE_COLOR:
			color = value
	
	item.set_custom_color(1, color)

func populate_buttons():
	"""Populate action buttons from target's debug actions"""
	var actions = target.get_debug_actions()
	
	if actions.is_empty():
		var no_actions_label = Label.new()
		no_actions_label.text = "No debug actions available"
		no_actions_label.modulate = Color.GRAY
		btns.add_child(no_actions_label)
		return
	
	for label in actions.keys():
		var callable = actions[label]
		var button = Button.new()
		button.text = str(label)
		button.pressed.connect(func(): execute_debug_action(label, callable))
		btns.add_child(button)

func clear_buttons():
	"""Clear all existing buttons"""
	for child in btns.get_children():
		child.queue_free()

# ===== EVENT HANDLERS =====

func _on_tree_edited():
	"""Handle tree item editing"""
	var edited_item = tree.get_edited()
	if not edited_item or not target:
		return
	
	var key = edited_item.get_text(0)
	var new_value_str = edited_item.get_text(1)
	
	# Try to convert string to appropriate type
	var converted_value = convert_string_to_value(new_value_str, key)
	
	# Update target through set_debug_field
	target.set_debug_field(key, converted_value)
	
	# Update display with converted value
	edited_item.set_text(1, str(converted_value))
	
	print("🎛️ Debug field edited: %s.%s = %s" % [target.name if target.has_method("get") else "Unknown", key, converted_value])

func convert_string_to_value(value_str: String, key: String):
	"""Convert string input to appropriate value type"""
	# Try to infer type from original payload
	var payload = target.get_debug_payload()
	var original_value = payload.get(key)
	
	if original_value != null:
		match typeof(original_value):
			TYPE_BOOL:
				return value_str.to_lower() in ["true", "1", "yes", "on"]
			TYPE_INT:
				return value_str.to_int()
			TYPE_FLOAT:
				return value_str.to_float()
			TYPE_VECTOR2:
				return parse_vector2(value_str)
			TYPE_VECTOR3:
				return parse_vector3(value_str)
			TYPE_VECTOR2I:
				return parse_vector2i(value_str)
			TYPE_VECTOR3I:
				return parse_vector3i(value_str)
			TYPE_COLOR:
				return parse_color(value_str)
	
	# Default to string if type can't be determined
	return value_str

func parse_vector2(value_str: String) -> Vector2:
	"""Parse Vector2 from string"""
	var parts = value_str.replace("(", "").replace(")", "").split(",")
	if parts.size() >= 2:
		return Vector2(parts[0].to_float(), parts[1].to_float())
	return Vector2.ZERO

func parse_vector3(value_str: String) -> Vector3:
	"""Parse Vector3 from string"""
	var parts = value_str.replace("(", "").replace(")", "").split(",")
	if parts.size() >= 3:
		return Vector3(parts[0].to_float(), parts[1].to_float(), parts[2].to_float())
	return Vector3.ZERO

func parse_vector2i(value_str: String) -> Vector2i:
	"""Parse Vector2i from string"""
	var parts = value_str.replace("(", "").replace(")", "").split(",")
	if parts.size() >= 2:
		return Vector2i(parts[0].to_int(), parts[1].to_int())
	return Vector2i.ZERO

func parse_vector3i(value_str: String) -> Vector3i:
	"""Parse Vector3i from string"""
	var parts = value_str.replace("(", "").replace(")", "").split(",")
	if parts.size() >= 3:
		return Vector3i(parts[0].to_int(), parts[1].to_int(), parts[2].to_int())
	return Vector3i.ZERO

func parse_color(value_str: String) -> Color:
	"""Parse Color from string"""
	# Handle common color names
	match value_str.to_lower():
		"red": return Color.RED
		"green": return Color.GREEN
		"blue": return Color.BLUE
		"white": return Color.WHITE
		"black": return Color.BLACK
		"yellow": return Color.YELLOW
		"cyan": return Color.CYAN
		"magenta": return Color.MAGENTA
	
	# Try to parse as hex color
	if value_str.begins_with("#"):
		return Color.html(value_str)
	
	# Try to parse as RGB values
	var parts = value_str.replace("(", "").replace(")", "").split(",")
	if parts.size() >= 3:
		return Color(parts[0].to_float(), parts[1].to_float(), parts[2].to_float())
	
	return Color.WHITE

func execute_debug_action(action_name: String, action_callable: Callable):
	"""Execute a debug action"""
	print("⚡ Executing debug action: %s" % action_name)
	
	if action_callable.is_valid():
		action_callable.call()
		show_action_feedback(action_name, true)
		
		# Refresh panel after action execution
		_populate_panel()
	else:
		print("❌ Failed to execute debug action: %s (Invalid callable)" % action_name)
		show_action_feedback(action_name, false)

func show_action_feedback(action_name: String, success: bool):
	"""Show visual feedback for action execution"""
	var feedback_label = Label.new()
	feedback_label.text = "✅ %s" % action_name if success else "❌ %s failed" % action_name
	feedback_label.modulate = Color.GREEN if success else Color.RED
	feedback_label.position = Vector2(panel.size.x + 10, 50)
	
	add_child(feedback_label)
	
	# Fade out and remove
	var tween = create_tween()
	tween.parallel().tween_property(feedback_label, "position:x", feedback_label.position.x + 100, 2.0)
	tween.parallel().tween_property(feedback_label, "modulate:a", 0.0, 2.0)
	tween.tween_callback(feedback_label.queue_free)

# ===== UTILITY FUNCTIONS =====

func is_overlay_visible() -> bool:
	"""Check if overlay is currently visible"""
	return visible

func get_current_target() -> Object:
	"""Get currently debugged target"""
	return target

func refresh_panel():
	"""Manually refresh the debug panel"""
	if target and visible:
		_populate_panel()

func set_position_smart(pos: Vector2):
	"""Set overlay position with screen bounds checking"""
	var viewport_size = get_viewport().get_visible_rect().size
	var clamped_pos = Vector2(
		clampf(pos.x, 0, viewport_size.x - panel.size.x),
		clampf(pos.y, 0, viewport_size.y - panel.size.y)
	)
	panel.position = clamped_pos