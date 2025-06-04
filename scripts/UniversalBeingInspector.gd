# ==================================================
# SCRIPT NAME: UniversalBeingInspector.gd
# DESCRIPTION: Inspector/Editor system for Universal Beings
# PURPOSE: Enable real-time inspection and modification of all Universal Being aspects
# CREATED: 2025-06-02 - Inspector Revolution
# AUTHOR: JSH + Claude Code - Universal Being Inspector Architects
# ==================================================

extends Control
class_name UniversalBeingInspector

# ===== INSPECTOR PROPERTIES =====
@export var auto_refresh: bool = true
@export var refresh_interval: float = 0.5
@export var show_socket_details: bool = true
@export var enable_hot_swap: bool = true

# --- Folding/Unfolding state for socket sections ---
var fold_states: Dictionary = {}  # type_name -> bool (true = expanded, false = folded)

# ===== UI COMPONENTS =====
var inspector_tabs: TabContainer = null
var socket_panel: Control = null
var property_panel: Control = null
var component_panel: Control = null
var action_panel: Control = null
var memory_panel: Control = null
var timeline_panel: Control = null
var logic_panel: Control = null

# ===== INSPECTOR STATE =====
var current_being: UniversalBeing = null
var refresh_timer: Timer = null
var socket_displays: Dictionary = {}
var property_editors: Dictionary = {}

# ===== SIGNALS =====
signal being_selected(being: UniversalBeing)
signal socket_modified(socket_id: String, component: Resource)
signal property_changed(property_name: String, value: Variant)
signal inspector_closed()

# ===== INITIALIZATION =====

func _ready() -> void:
	name = "UniversalBeingInspector"
	_create_inspector_ui()
	_setup_refresh_timer()

func _create_inspector_ui() -> void:
	"""Create the inspector interface"""
	# Main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_container)
	
	# Header
	var header = _create_header()
	main_container.add_child(header)
	
	# Tab container for different aspects
	inspector_tabs = TabContainer.new()
	inspector_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(inspector_tabs)
	
	# Create tabs
	_create_socket_tab()
	_create_property_tab()
	_create_component_tab()
	_create_action_tab()
	_create_memory_tab()
	_create_timeline_tab()
	_create_logic_tab()

func _create_header() -> Control:
	"""Create inspector header with being info"""
	var header = HBoxContainer.new()
	header.custom_minimum_size.y = 40
	
	# Being name label
	var name_label = Label.new()
	name_label.name = "BeingNameLabel"
	name_label.text = "No Being Selected"
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name_label)
	
	# Refresh button
	var refresh_btn = Button.new()
	refresh_btn.text = "🔄 Refresh"
	refresh_btn.pressed.connect(_refresh_inspector)
	header.add_child(refresh_btn)
	
	# Close button
	var close_btn = Button.new()
	close_btn.text = "✖"
	close_btn.pressed.connect(_close_inspector)
	header.add_child(close_btn)
	
	return header

func _create_socket_tab() -> void:
	"""Create socket inspection and editing tab"""
	socket_panel = VBoxContainer.new()
	socket_panel.name = "🔌 Sockets"
	inspector_tabs.add_child(socket_panel)
	
	# Socket type sections
	for socket_type in UniversalBeingSocket.SocketType.values():
		var type_name = UniversalBeingSocket.SocketType.keys()[socket_type]
		var section = _create_socket_section(type_name, socket_type)
		socket_panel.add_child(section)

func _create_socket_section(type_name: String, socket_type: UniversalBeingSocket.SocketType) -> Control:
	"""Create a section for a specific socket type with folding/unfolding support"""
	var section = VBoxContainer.new()
	section.name = type_name + "_Section"

	# Header (HBoxContainer) with fold button (Label) and title
	var header = HBoxContainer.new()
	var fold_label = Label.new()
	fold_label.name = type_name + "_FoldLabel"
	fold_label.text = "▼" if fold_states.get(type_name, true) else "▶"
	fold_label.custom_minimum_size.x = 20
	fold_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	fold_label.gui_input.connect(_on_fold_label_gui_input.bind(type_name))
	header.add_child(fold_label)

	var title = Label.new()
	title.text = "📌 %s Sockets" % type_name
	title.add_theme_font_size_override("font_size", 14)
	header.add_child(title)

	# Add socket button (if needed)
	var add_btn = Button.new()
	add_btn.text = "+"
	add_btn.pressed.connect(_add_socket.bind(socket_type))
	header.add_child(add_btn)

	section.add_child(header)

	# Socket list container (VBoxContainer) for folding/unfolding
	var socket_list_container = VBoxContainer.new()
	socket_list_container.name = type_name + "_List_Container"
	section.add_child(socket_list_container)

	# Socket list (VBoxContainer) inside the container
	var socket_list = VBoxContainer.new()
	socket_list.name = type_name + "_List"
	socket_list_container.add_child(socket_list)

	# If fold state is false, hide the socket list container
	if fold_states.get(type_name, true) == false:
		socket_list_container.hide()

	return section

func _create_property_tab() -> void:
	"""Create property inspection and editing tab"""
	property_panel = ScrollContainer.new()
	property_panel.name = "⚙️ Properties"
	inspector_tabs.add_child(property_panel)
	
	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	property_panel.add_child(content)

func _create_component_tab() -> void:
	"""Create component management tab"""
	component_panel = VBoxContainer.new()
	component_panel.name = "📦 Components"
	inspector_tabs.add_child(component_panel)

func _create_action_tab() -> void:
	"""Create action sequence management tab"""
	action_panel = VBoxContainer.new()
	action_panel.name = "🎬 Actions (Legacy)"
	inspector_tabs.add_child(action_panel)

func _create_memory_tab() -> void:
	"""Create memory inspection tab"""
	memory_panel = VBoxContainer.new()
	memory_panel.name = "🧠 Memory"
	inspector_tabs.add_child(memory_panel)

func _create_timeline_tab() -> void:
	"""Create (placeholder) Timeline tab for scenario, evolution, and event editing"""
	timeline_panel = VBoxContainer.new()
	timeline_panel.name = "⏱️ Timeline"
	inspector_tabs.add_child(timeline_panel)
	# (Placeholder: later integrate with AkashicCompactSystem for scenario branches, evolution chains, etc.)

func _create_logic_tab() -> void:
	"""Create (placeholder) Logic tab for editing logic connectors, triggers, and event–action pairs"""
	logic_panel = VBoxContainer.new()
	logic_panel.name = "🔗 Logic"
	inspector_tabs.add_child(logic_panel)
	# (Placeholder: later integrate with UniversalCommandProcessor for logic connectors.)

func _setup_refresh_timer() -> void:
	"""Setup automatic refresh timer"""
	refresh_timer = Timer.new()
	refresh_timer.wait_time = refresh_interval
	refresh_timer.autostart = auto_refresh
	refresh_timer.timeout.connect(_refresh_inspector)
	add_child(refresh_timer)

# ===== BEING INSPECTION =====

func inspect_being(being: UniversalBeing) -> void:
	"""Set the being to inspect"""
	current_being = being
	being_selected.emit(being)
	
	# Update header
	var name_label = get_node_or_null("VBoxContainer/HBoxContainer/BeingNameLabel")
	if name_label:
		name_label.text = "%s (%s)" % [being.being_name, being.being_type]
	
	# Refresh all panels
	_refresh_inspector()
	
	print("🔍 Inspecting Universal Being: %s" % being.being_name)

func _refresh_inspector() -> void:
	"""Refresh all inspector panels"""
	if not current_being:
		return
	
	_refresh_socket_panel()
	_refresh_property_panel()
	_refresh_component_panel()
	_refresh_action_panel()
	_refresh_memory_panel()
	_refresh_timeline_panel()
	_refresh_logic_panel()

func _refresh_socket_panel() -> void:
	"""Refresh socket inspection panel"""
	if not current_being or not current_being.socket_manager:
		return
	
	# Clear existing displays
	socket_displays.clear()
	
	# Update each socket type section
	for socket_type in UniversalBeingSocket.SocketType.values():
		var type_name = UniversalBeingSocket.SocketType.keys()[socket_type]
		var section = socket_panel.get_node_or_null(type_name + "_Section")
		if not section:
			continue
		
		var socket_list_container = section.get_node_or_null(type_name + "_List_Container")
		if not socket_list_container:
			continue
		
		# Re-apply fold state visibility
		socket_list_container.visible = fold_states.get(type_name, true)
		
		var socket_list = socket_list_container.get_node_or_null(type_name + "_List")
		if not socket_list:
			continue
		
		# Clear existing socket displays
		for child in socket_list.get_children():
			child.queue_free()
		
		# Add socket displays
		var sockets = current_being.get_sockets_by_type(socket_type)
		for socket in sockets:
			var socket_display = _create_socket_display(socket)
			socket_list.add_child(socket_display)
			socket_displays[socket.socket_id] = socket_display

func _create_socket_display(socket: UniversalBeingSocket) -> Control:
	"""Create display widget for a socket"""
	var container = HBoxContainer.new()
	container.name = socket.socket_id
	
	# Socket info
	var level := 0
	if socket.has("consciousness_level"):
		level = clamp(socket.consciousness_level, 0, 7)
	else:
		level = clamp(current_being.consciousness_level, 0, 7)
	var icon = TextureRect.new()
	icon.texture = lod_icons[level]
	icon.tooltip_text = lod_tooltips[level]
	icon.custom_minimum_size = Vector2(24, 24)
	container.add_child(icon)
	
	var status_icon = "🔴" if socket.is_occupied else "⚪"
	var lock_icon = "🔒" if socket.is_locked else ""
	var info_label = Label.new()
	info_label.text = "%s %s %s" % [status_icon, lock_icon, socket.socket_name]
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(info_label)
	
	# Component path
	if socket.is_occupied:
		var path_label = Label.new()
		path_label.text = socket.component_path.get_file()
		path_label.modulate = Color.CYAN
		container.add_child(path_label)
	
	# Action buttons
	var actions = HBoxContainer.new()
	
	# Mount/Unmount button
	var mount_btn = Button.new()
	mount_btn.text = "Unmount" if socket.is_occupied else "Mount"
	mount_btn.pressed.connect(_toggle_socket_component.bind(socket))
	actions.add_child(mount_btn)
	
	# Hot-swap button (if occupied and enabled)
	if socket.is_occupied and enable_hot_swap:
		var swap_btn = Button.new()
		swap_btn.text = "🔄"
		swap_btn.pressed.connect(_hot_swap_socket.bind(socket))
		actions.add_child(swap_btn)
	
	# Lock/Unlock button
	var lock_btn = Button.new()
	lock_btn.text = "🔓" if socket.is_locked else "🔒"
	lock_btn.pressed.connect(_toggle_socket_lock.bind(socket))
	actions.add_child(lock_btn)
	
	container.add_child(actions)
	return container

func _refresh_property_panel() -> void:
	"""Refresh property inspection panel"""
	if not current_being:
		return
	
	var content = property_panel.get_child(0)
	
	# Clear existing editors
	for child in content.get_children():
		child.queue_free()
	
	property_editors.clear()
	
	# Core properties
	_add_property_editor(content, "being_name", current_being.being_name, "String")
	_add_property_editor(content, "being_type", current_being.being_type, "String")
	_add_property_editor(content, "consciousness_level", current_being.consciousness_level, "int")
	_add_property_editor(content, "socket_hot_swap_enabled", current_being.socket_hot_swap_enabled, "bool")
	_add_property_editor(content, "visual_layer", current_being.visual_layer, "int")
	
	# Socket configuration
	if current_being.socket_manager:
		var config = current_being.socket_manager.get_socket_configuration()
		for key in config:
			if key != "sockets":  # Skip detailed socket data
				_add_property_editor(content, "socket_" + key, config[key], str(typeof(config[key])))

func _add_property_editor(parent: Control, property_name: String, value: Variant, type_hint: String) -> void:
	"""Add property editor widget"""
	var container = HBoxContainer.new()
	
	# Property name
	var name_label = Label.new()
	name_label.text = property_name + ":"
	name_label.custom_minimum_size.x = 150
	container.add_child(name_label)
	
	# Property editor
	var editor = _create_property_editor(property_name, value, type_hint)
	container.add_child(editor)
	
	parent.add_child(container)
	property_editors[property_name] = editor

func _create_property_editor(property_name: String, value: Variant, type_hint: String) -> Control:
	"""Create appropriate editor for property type"""
	match type_hint:
		"bool":
			var checkbox = CheckBox.new()
			checkbox.button_pressed = value
			checkbox.toggled.connect(_on_property_changed.bind(property_name))
			return checkbox
		"int":
			var spinbox = SpinBox.new()
			spinbox.value = value
			spinbox.step = 1
			spinbox.value_changed.connect(_on_property_changed.bind(property_name))
			return spinbox
		"float":
			var spinbox = SpinBox.new()
			spinbox.value = value
			spinbox.step = 0.1
			spinbox.value_changed.connect(_on_property_changed.bind(property_name))
			return spinbox
		_:
			var line_edit = LineEdit.new()
			line_edit.text = str(value)
			line_edit.text_submitted.connect(_on_property_changed.bind(property_name))
			return line_edit

func _refresh_component_panel() -> void:
	"""Refresh component management panel"""
	# Clear existing content
	for child in component_panel.get_children():
		child.queue_free()
	
	if not current_being:
		return
	
	# Component list
	var title = Label.new()
	title.text = "Loaded Components:"
	component_panel.add_child(title)
	
	for component_path in current_being.components:
		var item = HBoxContainer.new()
		
		var path_label = Label.new()
		path_label.text = component_path.get_file()
		path_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item.add_child(path_label)
		
		var remove_btn = Button.new()
		remove_btn.text = "Remove"
		remove_btn.pressed.connect(_remove_component.bind(component_path))
		item.add_child(remove_btn)
		
		component_panel.add_child(item)

func _refresh_action_panel() -> void:
	"""Refresh action sequence panel"""
	# Implementation for action management
	pass

func _refresh_memory_panel() -> void:
	"""Refresh memory inspection panel"""
	# Clear existing content
	for child in memory_panel.get_children():
		child.queue_free()
	
	if not current_being:
		return
	
	# Memory sockets
	var memory_sockets = current_being.get_sockets_by_type(UniversalBeingSocket.SocketType.MEMORY)
	for socket in memory_sockets:
		if socket.is_occupied and socket.mounted_component:
			var data = socket.get_component_data()
			_display_memory_data(socket.socket_name, data)

func _display_memory_data(memory_name: String, data: Dictionary) -> void:
	"""Display memory data in inspector"""
	var section = VBoxContainer.new()
	
	var title = Label.new()
	title.text = "Memory: " + memory_name
	section.add_child(title)
	
	var tree = Tree.new()
	tree.custom_minimum_size.y = 100
	var root = tree.create_item()
	root.set_text(0, "Root")
	
	_populate_tree_with_data(tree, root, data)
	section.add_child(tree)
	
	memory_panel.add_child(section)

func _populate_tree_with_data(tree: Tree, parent: TreeItem, data: Dictionary) -> void:
	"""Populate tree with dictionary data"""
	for key in data:
		var item = tree.create_item(parent)
		item.set_text(0, str(key))
		item.set_text(1, str(data[key]))

func _refresh_timeline_panel() -> void:
	"""Refresh (placeholder) Timeline panel"""
	# (Placeholder: later integrate with AkashicCompactSystem.)
	pass

func _refresh_logic_panel() -> void:
	"""Refresh (placeholder) Logic panel"""
	# (Placeholder: later integrate with UniversalCommandProcessor.)
	pass

# ===== EVENT HANDLERS =====

func _add_socket(socket_type: UniversalBeingSocket.SocketType) -> void:
	"""Add new socket of specified type"""
	if not current_being:
		return
	
	var type_name = UniversalBeingSocket.SocketType.keys()[socket_type]
	var socket_name = type_name.to_lower() + "_" + str(randi())
	current_being.socket_manager.add_socket(socket_type, socket_name)
	_refresh_socket_panel()

func _toggle_socket_component(socket: UniversalBeingSocket) -> void:
	"""Toggle socket component mount/unmount"""
	if socket.is_occupied:
		socket.unmount_component()
	else:
		# Show file dialog to select component
		_show_component_selector(socket)

func _show_component_selector(socket: UniversalBeingSocket) -> void:
	"""Show file dialog to select component for socket"""
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	
	# Set filters based on socket type
	match socket.socket_type:
		UniversalBeingSocket.SocketType.VISUAL:
			file_dialog.add_filter("*.tres", "Visual Resources")
			file_dialog.add_filter("*.res", "Binary Resources")
		UniversalBeingSocket.SocketType.SCRIPT:
			file_dialog.add_filter("*.gd", "GDScript Files")
		UniversalBeingSocket.SocketType.SHADER:
			file_dialog.add_filter("*.gdshader", "Shader Files")
			file_dialog.add_filter("*.tres", "Material Resources")
		_:
			file_dialog.add_filter("*", "All Files")
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))
	
	# Connect file selected
	file_dialog.file_selected.connect(_on_component_file_selected.bind(socket, file_dialog))

func _on_component_file_selected(socket: UniversalBeingSocket, dialog: FileDialog, file_path: String) -> void:
	"""Handle component file selection"""
	var component = load(file_path)
	if component:
		socket.mount_component(component)
		_refresh_socket_panel()
		socket_modified.emit(socket.socket_id, component)
	
	dialog.queue_free()

func _hot_swap_socket(socket: UniversalBeingSocket) -> void:
	"""Hot-swap component in socket"""
	_show_component_selector(socket)

func _toggle_socket_lock(socket: UniversalBeingSocket) -> void:
	"""Toggle socket lock state"""
	if socket.is_locked:
		socket.unlock_socket()
	else:
		socket.lock_socket("Inspector lock")
	_refresh_socket_panel()

func _on_property_changed(property_name: String, value: Variant) -> void:
	"""Handle property value change"""
	if not current_being:
		return
	
	# Apply property change
	if property_name.begins_with("socket_"):
		# Socket manager property
		pass
	else:
		# Core being property
		current_being.set(property_name, value)
	
	property_changed.emit(property_name, value)
	print("🔧 Property changed: %s = %s" % [property_name, str(value)])

	if property_name == "visual_layer":
		current_being.visual_layer = int(value)
		update_visual_layer_order(current_being)

func _remove_component(component_path: String) -> void:
	"""Remove component from being"""
	if current_being:
		current_being.components.erase(component_path)
		_refresh_component_panel()

func _close_inspector() -> void:
	"""Close the inspector"""
	inspector_closed.emit()
	queue_free()

# ===== AI INTEGRATION =====

# --- AI interface for inspector control ---
# Returns a dictionary describing the current being and all available AI commands with descriptions.
# TODO: Expand for NobodyWho/advanced agent integration and poetic Akashic logging (AkashicLoggerComponent).
func get_ai_interface() -> Dictionary:
	"""AI interface for inspector control. All commands are available to Gemma, NobodyWho, and other agents."""
	return {
		"current_being": current_being.being_name if current_being else null,
		"available_commands": [
			{"name": "inspect_being", "desc": "Select and inspect a Universal Being."},
			{"name": "mount_component", "desc": "Mount a component (.ub.zip) to a socket."},
			{"name": "unmount_component", "desc": "Unmount a component from a socket."},
			{"name": "hot_swap_component", "desc": "Hot-swap a component in a socket."},
			{"name": "set_property", "desc": "Set a property on the current being."},
			{"name": "get_socket_info", "desc": "Get info about all sockets and their components."},
			{"name": "add_logic_connection", "desc": "Add a logic connection (event-action) between beings."},
			{"name": "remove_logic_connection", "desc": "Remove a logic connection."},
			{"name": "list_logic_connections", "desc": "List all logic connections for the current being."},
			{"name": "edit_timeline", "desc": "Edit the scenario/timeline for the current being."},
			{"name": "refresh_inspector", "desc": "Force refresh the inspector UI."}
		]
	}

# --- AI method invocation handler ---
# Handles all AI/agent commands. Returns true/false or data as appropriate.
# TODO: Add NobodyWho/advanced agent hooks and Akashic poetic logging for all actions.
func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	"""Handle AI method invocation for inspector actions."""
	match method_name:
		"inspect_being":
			if args.size() > 0 and args[0] is UniversalBeing:
				inspect_being(args[0])
				return true
		"mount_component":
			if args.size() >= 2:
				return _ai_mount_component(args[0], args[1])
		"unmount_component":
			if args.size() >= 1:
				return _ai_unmount_component(args[0])
		"hot_swap_component":
			if args.size() >= 2:
				return _ai_hot_swap_component(args[0], args[1])
		"set_property":
			if args.size() >= 2:
				_on_property_changed(args[0], args[1])
				return true
		"get_socket_info":
			return _ai_get_socket_info()
		"add_logic_connection":
			if args.size() >= 3:
				return _ai_add_logic_connection(args[0], args[1], args[2])
		"remove_logic_connection":
			if args.size() >= 1:
				return _ai_remove_logic_connection(args[0])
		"list_logic_connections":
			return _ai_list_logic_connections()
		"edit_timeline":
			if args.size() >= 1:
				return _ai_edit_timeline(args[0])
		"refresh_inspector":
			_refresh_inspector()
			return true
		_:
			return false
	return false

# --- AI helper methods for new commands ---
func _ai_unmount_component(socket_id: String) -> bool:
	if not current_being:
		return false
	return current_being.unmount_component(socket_id)

func _ai_hot_swap_component(socket_id: String, component_path: String) -> bool:
	if not current_being:
		return false
	var component = load(component_path)
	if not component:
		return false
	return current_being.hot_swap_component(socket_id, component)

func _ai_get_socket_info() -> Dictionary:
	if not current_being:
		return {}
	return current_being.socket_manager.get_all_socket_info()

func _ai_add_logic_connection(event: String, target_being: UniversalBeing, action: String) -> bool:
	# TODO: Integrate with LogicConnector system
	return false

func _ai_remove_logic_connection(connection_id: String) -> bool:
	# TODO: Integrate with LogicConnector system
	return false

func _ai_list_logic_connections() -> Array:
	# TODO: Integrate with LogicConnector system
	return []

func _ai_edit_timeline(timeline_data: Dictionary) -> bool:
	# TODO: Integrate with AkashicCompactSystem for scenario/timeline editing
	return false

# --- Insert new AI helper for mount component ---
func _ai_mount_component(socket_id: String, component_path: String) -> bool:
	"""AI helper to mount a component (loaded from component_path) into the socket (socket_id) on the current being."""
	if not current_being:
		return false
	var component = load(component_path)
	if not component:
		return false
	return current_being.mount_component(socket_id, component)

# --- DESIGN RATIONALE ---
# This AI interface is designed for multi-agent collaboration (Gemma, NobodyWho, Cursor, Claude, etc.).
# All actions should be logged poetically to the Akashic Library (see AkashicLoggerComponent).
# TODO: Expand with advanced agent consensus, task assignment, and poetic logging for every action.

# Insert new event handler (_on_fold_label_gui_input) to toggle fold state and update fold label and socket list container visibility.
func _on_fold_label_gui_input(event: InputEvent, type_name: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		fold_states[type_name] = !fold_states.get(type_name, true)
		var fold_label = get_node_or_null("VBoxContainer/TabContainer/🔌 Sockets/" + type_name + "_Section/" + type_name + "_FoldLabel")
		if fold_label:
			fold_label.text = "▼" if fold_states[type_name] else "▶"
		var socket_list_container = get_node_or_null("VBoxContainer/TabContainer/🔌 Sockets/" + type_name + "_Section/" + type_name + "_List_Container")
		if socket_list_container:
			socket_list_container.visible = fold_states[type_name]

func update_visual_layer_order(being: UniversalBeing) -> void:
	"""Update draw/sort order for the being based on visual_layer (to be implemented for 2D/3D/UI)"""
	# TODO: Implement sorting logic for 2D, 3D, and UI based on being.visual_layer
	pass

var lod_mode: String = "full" # Options: 'icon', 'icon_label', 'full'. TODO: Make dynamic based on player gaze/focus.
var lod_icons := [
	preload("res://assets/icons/consciousness/level_0.png"),
	preload("res://assets/icons/consciousness/level_1.png"),
	preload("res://assets/icons/consciousness/level_2.png"),
	preload("res://assets/icons/consciousness/level_3.png"),
	preload("res://assets/icons/consciousness/level_4.png"),
	preload("res://assets/icons/consciousness/level_5.png"),
	preload("res://assets/icons/consciousness/level_6.png"),
	preload("res://assets/icons/consciousness/level_7.png")
]
var lod_tooltips := [
	"Level 0: Dormant",
	"Level 1: Spark",
	"Level 2: Drop",
	"Level 3: Leaf",
	"Level 4: Star",
	"Level 5: Pearl",
	"Level 6: Flame",
	"Level 7: Infinity"
]