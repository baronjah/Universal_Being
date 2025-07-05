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

		var success = connect_socket(from_socket, from_interface, to_socket)
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

# ===== SOCKET INTEGRATION METHODS =====
# Integrated with UniversalBeingSocketManager

var socket_manager: UniversalBeingSocketManager

func _initialize_socket_system():
	"""Initialize socket system for this interface"""
	if not socket_manager:
		socket_manager = UniversalBeingSocketManager.new(parent_being)
		add_child(socket_manager)
		
		# Connect socket signals
		socket_manager.socket_added.connect(_on_socket_added)
		socket_manager.socket_removed.connect(_on_socket_removed)
		socket_manager.component_mounted.connect(_on_component_mounted)
		socket_manager.component_unmounted.connect(_on_component_unmounted)

func add_socket(name: String, direction: String, type: String) -> void:
	"""Create a new socket for the interface"""
	if not socket_manager:
		_initialize_socket_system()
	
	# Convert string type to SocketType enum
	var socket_type = _string_to_socket_type(type)
	if socket_type == -1:
		show_ub_visual("❌ Invalid socket type: %s" % type)
		return
	
	var socket = socket_manager.add_typed_socket(socket_type, name)
	if socket:
		show_ub_visual("🔌 Socket created: %s (%s)" % [name, type])
		_create_socket_visual(socket, direction)

func connect_socket(from_socket: String, other_interface: Node, to_socket: String) -> bool:
	"""Connect this socket to another interface's socket"""
	if not socket_manager:
		_initialize_socket_system()
		return false
	
	# Find the socket
	var socket = socket_manager.get_socket_by_name(from_socket)
	if not socket:
		show_ub_visual("❌ Socket not found: %s" % from_socket)
		return false
	
	# Check if other interface has socket manager
	var other_socket_manager = null
	if other_interface.has_method("get_socket_manager"):
		other_socket_manager = other_interface.get_socket_manager()
	elif other_interface.find_child("UniversalBeingSocketManager"):
		other_socket_manager = other_interface.find_child("UniversalBeingSocketManager")
	
	if not other_socket_manager:
		show_ub_visual("❌ Target interface has no socket manager")
		return false
	
	var target_socket = other_socket_manager.get_socket_by_name(to_socket)
	if not target_socket:
		show_ub_visual("❌ Target socket not found: %s" % to_socket)
		return false
	
	# Create connection
	var connection_success = socket_manager.connect_sockets(socket, target_socket)
	if connection_success:
		show_ub_visual("🔗 Sockets connected: %s → %s" % [from_socket, to_socket])
		_create_connection_visual(socket, target_socket)
	
	return connection_success

func set_socket_value(socket_name: String, value: Variant) -> void:
	"""Set value on a socket"""
	if not socket_manager:
		_initialize_socket_system()
		return
	
	var socket = socket_manager.get_socket_by_name(socket_name)
	if not socket:
		show_ub_visual("❌ Socket not found: %s" % socket_name)
		return
	
	socket.set_value(value)
	show_ub_visual("📡 Socket value set: %s = %s" % [socket_name, str(value)])
	_update_socket_visual(socket, value)

func get_socket_manager() -> UniversalBeingSocketManager:
	"""Get the socket manager for this interface"""
	if not socket_manager:
		_initialize_socket_system()
	return socket_manager

# ===== SOCKET HELPER METHODS =====

func _string_to_socket_type(type_string: String) -> int:
	"""Convert string to SocketType enum"""
	match type_string.to_lower():
		"visual":
			return UniversalBeingSocket.SocketType.VISUAL
		"script":
			return UniversalBeingSocket.SocketType.SCRIPT
		"shader":
			return UniversalBeingSocket.SocketType.SHADER
		"action":
			return UniversalBeingSocket.SocketType.ACTION
		"memory":
			return UniversalBeingSocket.SocketType.MEMORY
		"interface":
			return UniversalBeingSocket.SocketType.INTERFACE
		_:
			return -1

func _create_socket_visual(socket: UniversalBeingSocket, direction: String):
	"""Create visual representation of socket"""
	var socket_visual = MeshInstance3D.new()
	socket_visual.name = "SocketVisual_" + socket.socket_name
	
	# Create socket geometry
	var socket_mesh = SphereMesh.new()
	socket_mesh.radius = 0.1
	socket_visual.mesh = socket_mesh
	
	# Socket material based on type
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_socket_type_color(socket.socket_type)
	material.emission_enabled = true
	material.emission_color = material.albedo_color * 0.5
	socket_visual.material_override = material
	
	# Position based on direction
	var offset = Vector3.ZERO
	match direction.to_lower():
		"left":
			offset = Vector3(-1.5, 0, 0)
		"right":
			offset = Vector3(1.5, 0, 0)
		"top":
			offset = Vector3(0, 1.5, 0)
		"bottom":
			offset = Vector3(0, -1.5, 0)
		"front":
			offset = Vector3(0, 0, 1.5)
		"back":
			offset = Vector3(0, 0, -1.5)
	
	socket_visual.position = offset
	interface_container.add_child(socket_visual)

func _get_socket_type_color(socket_type: int) -> Color:
	"""Get color for socket type"""
	match socket_type:
		UniversalBeingSocket.SocketType.VISUAL:
			return Color.CYAN
		UniversalBeingSocket.SocketType.SCRIPT:
			return Color.GREEN
		UniversalBeingSocket.SocketType.SHADER:
			return Color.MAGENTA
		UniversalBeingSocket.SocketType.ACTION:
			return Color.ORANGE
		UniversalBeingSocket.SocketType.MEMORY:
			return Color.YELLOW
		UniversalBeingSocket.SocketType.INTERFACE:
			return Color.WHITE
		_:
			return Color.GRAY

func _create_connection_visual(from_socket: UniversalBeingSocket, to_socket: UniversalBeingSocket):
	"""Create visual connection line between sockets"""
	var connection_line = MeshInstance3D.new()
	connection_line.name = "Connection_%s_to_%s" % [from_socket.socket_name, to_socket.socket_name]
	
	# Create line mesh (simplified - would need proper line rendering)
	var line_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertices = PackedVector3Array()
	vertices.append(Vector3.ZERO)
	vertices.append(Vector3(0, 0, 5))  # Placeholder - would calculate actual target position
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	line_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	connection_line.mesh = line_mesh
	interface_container.add_child(connection_line)

func _update_socket_visual(socket: UniversalBeingSocket, value: Variant):
	"""Update socket visual based on value"""
	var socket_visual = interface_container.find_child("SocketVisual_" + socket.socket_name)
	if socket_visual and socket_visual is MeshInstance3D:
		var material = socket_visual.material_override
		if material is StandardMaterial3D:
			# Pulse effect when value changes
			var pulse_tween = create_tween()
			pulse_tween.tween_property(material, "emission_energy", 2.0, 0.2)
			pulse_tween.tween_property(material, "emission_energy", 0.5, 0.3)

# ===== SOCKET SIGNAL HANDLERS =====

func _on_socket_added(socket: UniversalBeingSocket):
	"""Handle socket added signal"""
	show_ub_visual("🔌 Socket system: %s added" % socket.socket_name)

func _on_socket_removed(socket: UniversalBeingSocket):
	"""Handle socket removed signal"""
	show_ub_visual("🔌 Socket system: %s removed" % socket.socket_name)
	
	# Remove visual
	var socket_visual = interface_container.find_child("SocketVisual_" + socket.socket_name)
	if socket_visual:
		socket_visual.queue_free()

func _on_component_mounted(socket: UniversalBeingSocket, component: Resource):
	"""Handle component mounted to socket"""
	show_ub_visual("🔧 Component mounted: %s → %s" % [component.get_class(), socket.socket_name])

func _on_component_unmounted(socket: UniversalBeingSocket, component: Resource):
	"""Handle component unmounted from socket"""
	show_ub_visual("🔧 Component unmounted: %s ← %s" % [component.get_class(), socket.socket_name])
