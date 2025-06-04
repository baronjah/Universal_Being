# ==================================================
# SCRIPT NAME: UniversalBeingInterface.gd
# DESCRIPTION: Base class for all interface Universal Beings
# PURPOSE: Normalize all UI elements as Universal Beings with common interface behaviors
# CREATED: 2025-06-04 - Universal Interface Revolution
# AUTHOR: JSH + Claude Code
# ==================================================

extends UniversalBeing
class_name UniversalBeingInterface

# ===== INTERFACE PROPERTIES =====

@export var interface_title: String = "Universal Interface"
@export var is_resizable: bool = true
@export var is_movable: bool = true
@export var is_closable: bool = true
@export var is_minimizable: bool = true

@export var min_size: Vector2 = Vector2(200, 100)
@export var max_size: Vector2 = Vector2(2000, 1500)
@export var default_size: Vector2 = Vector2(400, 300)

@export var interface_layer: int = 100  # UI layer
@export var interface_theme: String = "default"

# ===== INTERFACE STATE =====

enum InterfaceState {
	NORMAL,
	MINIMIZED,
	MAXIMIZED,
	HIDDEN,
	DOCKED
}

var current_interface_state: InterfaceState = InterfaceState.NORMAL
var is_being_dragged: bool = false
var is_being_resized: bool = false
var drag_offset: Vector2
var interface_id: String

# ===== INTERFACE COMPONENTS =====

var interface_container: Control
var title_bar: Control
var title_label: Label
var close_button: Button
var minimize_button: Button
var maximize_button: Button
var resize_handle: Control
var content_area: Control

# ===== INTERFACE SIGNALS =====

signal interface_closed(interface: UniversalBeingInterface)
signal interface_minimized(interface: UniversalBeingInterface)
signal interface_maximized(interface: UniversalBeingInterface)
signal interface_moved(interface: UniversalBeingInterface, new_position: Vector2)
signal interface_resized(interface: UniversalBeingInterface, new_size: Vector2)
signal interface_docked(interface: UniversalBeingInterface, dock_zone: String)
signal interface_logic_connected(from_socket: String, to_socket: String)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "interface"
	consciousness_level = 3  # Interface consciousness
	being_name = interface_title
	interface_id = generate_interface_id()
	
	# Create interface components
	_create_interface_structure()
	_setup_interface_signals()
	_apply_interface_theme()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_initialize_interface_position()
	_setup_interface_sockets()
	print("🖼️ Interface Universal Being ready: %s" % interface_title)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_handle_interface_updates(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	_handle_interface_input(event)

func pentagon_sewers() -> void:
	_cleanup_interface()
	super.pentagon_sewers()

# ===== INTERFACE STRUCTURE =====

func _create_interface_structure() -> void:
	"""Create the interface UI structure"""
	# Main container
	interface_container = Control.new()
	interface_container.name = "InterfaceContainer"
	interface_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	interface_container.size = default_size
	interface_container.z_index = interface_layer
	add_child(interface_container)
	
	# Title bar
	title_bar = Panel.new()
	title_bar.name = "TitleBar"
	title_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title_bar.size = Vector2(default_size.x, 30)
	title_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	interface_container.add_child(title_bar)
	
	# Title label
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = interface_title
	title_label.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	title_label.position = Vector2(10, 0)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_bar.add_child(title_label)
	
	# Window buttons container
	var button_container = HBoxContainer.new()
	button_container.name = "ButtonContainer"
	button_container.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	button_container.position = Vector2(-80, 0)
	title_bar.add_child(button_container)
	
	# Minimize button
	if is_minimizable:
		minimize_button = Button.new()
		minimize_button.name = "MinimizeButton"
		minimize_button.text = "_"
		minimize_button.size = Vector2(20, 20)
		button_container.add_child(minimize_button)
	
	# Maximize button
	maximize_button = Button.new()
	maximize_button.name = "MaximizeButton"
	maximize_button.text = "□"
	maximize_button.size = Vector2(20, 20)
	button_container.add_child(maximize_button)
	
	# Close button
	if is_closable:
		close_button = Button.new()
		close_button.name = "CloseButton"
		close_button.text = "×"
		close_button.size = Vector2(20, 20)
		close_button.add_theme_color_override("font_color", Color.RED)
		button_container.add_child(close_button)
	
	# Content area
	content_area = Panel.new()
	content_area.name = "ContentArea"
	content_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_area.offset_top = 30  # Below title bar
	content_area.mouse_filter = Control.MOUSE_FILTER_PASS
	interface_container.add_child(content_area)
	
	# Resize handle
	if is_resizable:
		resize_handle = Control.new()
		resize_handle.name = "ResizeHandle"
		resize_handle.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		resize_handle.size = Vector2(16, 16)
		resize_handle.mouse_filter = Control.MOUSE_FILTER_PASS
		interface_container.add_child(resize_handle)

func _setup_interface_signals() -> void:
	"""Connect interface signals"""
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if minimize_button:
		minimize_button.pressed.connect(_on_minimize_pressed)
	if maximize_button:
		maximize_button.pressed.connect(_on_maximize_pressed)
	
	# Drag and resize handling
	if title_bar:
		title_bar.gui_input.connect(_on_title_bar_input)
	if resize_handle:
		resize_handle.gui_input.connect(_on_resize_handle_input)

# ===== INTERFACE INTERACTIONS =====

func _on_close_pressed() -> void:
	"""Handle close button press"""
	close_interface()

func _on_minimize_pressed() -> void:
	"""Handle minimize button press"""
	minimize_interface()

func _on_maximize_pressed() -> void:
	"""Handle maximize button press"""
	if current_interface_state == InterfaceState.MAXIMIZED:
		restore_interface()
	else:
		maximize_interface()

func _on_title_bar_input(event: InputEvent) -> void:
	"""Handle title bar input for dragging"""
	if not is_movable:
		return
		
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				is_being_dragged = true
				drag_offset = interface_container.global_position - mouse_event.global_position
				Input.set_default_cursor_shape(Input.CURSOR_MOVE)
			else:
				is_being_dragged = false
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	elif event is InputEventMouseMotion and is_being_dragged:
		var mouse_motion = event as InputEventMouseMotion
		var new_position = mouse_motion.global_position + drag_offset
		move_interface_to(new_position)

func _on_resize_handle_input(event: InputEvent) -> void:
	"""Handle resize handle input"""
	if not is_resizable:
		return
		
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				is_being_resized = true
				Input.set_default_cursor_shape(Input.CURSOR_FDIAGSIZE)
			else:
				is_being_resized = false
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	elif event is InputEventMouseMotion and is_being_resized:
		var mouse_motion = event as InputEventMouseMotion
		var current_size = interface_container.size
		var new_size = current_size + mouse_motion.relative
		resize_interface_to(new_size)

# ===== INTERFACE CONTROL METHODS =====

func close_interface() -> void:
	"""Close the interface"""
	current_interface_state = InterfaceState.HIDDEN
	interface_container.visible = false
	interface_closed.emit(self)
	print("🖼️ Interface closed: %s" % interface_title)

func minimize_interface() -> void:
	"""Minimize the interface"""
	current_interface_state = InterfaceState.MINIMIZED
	content_area.visible = false
	interface_container.size = Vector2(interface_container.size.x, 30)  # Just title bar
	interface_minimized.emit(self)
	print("🖼️ Interface minimized: %s" % interface_title)

func maximize_interface() -> void:
	"""Maximize the interface"""
	current_interface_state = InterfaceState.MAXIMIZED
	var viewport_size = get_viewport().get_visible_rect().size
	interface_container.position = Vector2.ZERO
	interface_container.size = viewport_size
	interface_maximized.emit(self)
	print("🖼️ Interface maximized: %s" % interface_title)

func restore_interface() -> void:
	"""Restore interface to normal size"""
	current_interface_state = InterfaceState.NORMAL
	content_area.visible = true
	interface_container.size = default_size
	_center_interface()
	print("🖼️ Interface restored: %s" % interface_title)

func move_interface_to(new_position: Vector2) -> void:
	"""Move interface to new position"""
	interface_container.global_position = new_position
	interface_moved.emit(self, new_position)

func resize_interface_to(new_size: Vector2) -> void:
	"""Resize interface to new size"""
	# Clamp to min/max size
	new_size.x = clamp(new_size.x, min_size.x, max_size.x)
	new_size.y = clamp(new_size.y, min_size.y, max_size.y)
	
	interface_container.size = new_size
	interface_resized.emit(self, new_size)

func _center_interface() -> void:
	"""Center the interface in viewport"""
	var viewport_size = get_viewport().get_visible_rect().size
	var centered_pos = (viewport_size - interface_container.size) / 2
	interface_container.position = centered_pos

# ===== INTERFACE LOGIC SYSTEM =====

func _setup_interface_sockets() -> void:
	"""Setup sockets for logic connections"""
	if has_method("add_socket"):
		# Input sockets
		add_socket("position_in", "input", "Vector2")
		add_socket("size_in", "input", "Vector2") 
		add_socket("visible_in", "input", "bool")
		add_socket("data_in", "input", "Variant")
		
		# Output sockets
		add_socket("position_out", "output", "Vector2")
		add_socket("size_out", "output", "Vector2")
		add_socket("clicked_out", "output", "bool")
		add_socket("data_out", "output", "Variant")
		
		print("🔌 Interface sockets created for %s" % interface_title)

func connect_logic(from_interface: UniversalBeingInterface, from_socket: String, to_socket: String) -> bool:
	"""Connect logic between interfaces"""
	if has_method("connect_socket"):
		var success = connect_socket(from_interface, from_socket, to_socket)
		if success:
			interface_logic_connected.emit(from_socket, to_socket)
			print("🔌 Logic connected: %s.%s -> %s.%s" % [from_interface.interface_title, from_socket, interface_title, to_socket])
		return success
	return false

# ===== INTERFACE THEME SYSTEM =====

func _apply_interface_theme() -> void:
	"""Apply theme to interface"""
	match interface_theme:
		"default":
			_apply_default_theme()
		"dark":
			_apply_dark_theme()
		"cosmic":
			_apply_cosmic_theme()

func _apply_default_theme() -> void:
	"""Apply default interface theme"""
	if title_bar:
		title_bar.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2, 0.9))
	if content_area:
		content_area.add_theme_color_override("bg_color", Color(0.1, 0.1, 0.1, 0.8))

func _apply_dark_theme() -> void:
	"""Apply dark interface theme"""
	if title_bar:
		title_bar.add_theme_color_override("bg_color", Color(0.05, 0.05, 0.05, 0.95))
	if content_area:
		content_area.add_theme_color_override("bg_color", Color(0.02, 0.02, 0.02, 0.9))

func _apply_cosmic_theme() -> void:
	"""Apply cosmic interface theme"""
	if title_bar:
		title_bar.add_theme_color_override("bg_color", Color(0.1, 0.05, 0.2, 0.9))
	if content_area:
		content_area.add_theme_color_override("bg_color", Color(0.05, 0.02, 0.1, 0.8))

# ===== UTILITIES =====

func generate_interface_id() -> String:
	"""Generate unique interface ID"""
	return "interface_%s_%d" % [interface_title.to_lower().replace(" ", "_"), Time.get_ticks_msec()]

func _initialize_interface_position() -> void:
	"""Initialize interface position"""
	_center_interface()

func _handle_interface_updates(delta: float) -> void:
	"""Handle per-frame interface updates"""
	# Update socket outputs
	if has_method("set_socket_value"):
		set_socket_value("position_out", interface_container.global_position)
		set_socket_value("size_out", interface_container.size)

func _handle_interface_input(event: InputEvent) -> void:
	"""Handle interface-specific input"""
	# Override in subclasses for specific interface behavior
	pass

func _cleanup_interface() -> void:
	"""Cleanup interface resources"""
	print("🖼️ Cleaning up interface: %s" % interface_title)

# ===== PUBLIC API =====

func get_content_area() -> Control:
	"""Get the content area for adding interface-specific content"""
	return content_area

func set_interface_title(new_title: String) -> void:
	"""Set interface title"""
	interface_title = new_title
	being_name = new_title
	if title_label:
		title_label.text = new_title

func show_interface() -> void:
	"""Show the interface"""
	current_interface_state = InterfaceState.NORMAL
	interface_container.visible = true

func hide_interface() -> void:
	"""Hide the interface"""
	current_interface_state = InterfaceState.HIDDEN
	interface_container.visible = false

func is_interface_visible() -> bool:
	"""Check if interface is visible"""
	return interface_container.visible if interface_container else false

func get_interface_state() -> InterfaceState:
	"""Get current interface state"""
	return current_interface_state

# ===== SOCKET STUB METHODS =====
# TODO: Integrate with UniversalBeingSocketManager

func add_socket(name: String, direction: String, type: String) -> void:
	"""Stub method for socket creation"""
	pass

func connect_socket(from_socket: String, other_interface: Node, to_socket: String) -> bool:
	"""Stub method for socket connection"""
	return false

func set_socket_value(socket_name: String, value: Variant) -> void:
	"""Stub method for setting socket values"""
	pass
