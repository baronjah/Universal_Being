# ==================================================
# UNIVERSAL BEING: Universal Interface Being
# TYPE: interface
# PURPOSE: Perfect in-game interface that can be moved, resized, closed, edited
# FEATURES: 3D interface in game world, grabbable, resizable, editable
# CREATED: 2025-06-04
# ==================================================

extends UniversalBeing
class_name UniversalInterfaceBeing

# ===== INTERFACE PROPERTIES =====
@export var interface_title: String = "Universal Interface"
@export var interface_size: Vector2 = Vector2(400, 300)
@export var interface_scale: float = 0.01  # Scale for 3D display
@export var always_face_camera: bool = true
@export var is_moveable: bool = true
@export var is_resizable: bool = true
@export var is_closeable: bool = true

# Interface state
var is_grabbed: bool = false
var is_resizing: bool = false
var is_editing: bool = false
var grab_offset: Vector3 = Vector3.ZERO
var original_size: Vector2

# Visual components
var interface_panel: Control
var title_bar: Panel
var title_label: Label
var close_button: Button
var resize_handle: Control
var content_area: Control
var background_mesh: MeshInstance3D

# Interface content
var loaded_interface: Node = null
var interface_type: String = "generic"

# Interaction
var interaction_area: Area3D
var interface_collision_shape: CollisionShape3D

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "interface"
	being_name = interface_title
	consciousness_level = 2  # Aware interface
	
	# Interface can evolve into specialized forms
	evolution_state.can_become = ["console_interface", "editor_interface", "game_interface", "ai_interface"]
	
	print("🖥️ %s: Pentagon Init - Interface consciousness awakens" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Create the 3D interface
	_create_3d_interface()
	
	# Set up interaction
	_setup_interaction()
	
	# Connect to cursor for manipulation
	_connect_to_cursor()
	
	print("🖥️ %s: Pentagon Ready - Interface ready for interaction" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Always face camera if enabled
	if always_face_camera:
		_face_camera()
	
	# Update interface based on state
	_update_interface_state(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle interface-specific input
	_handle_interface_input(event)

func pentagon_sewers() -> void:
	print("🖥️ %s: Interface fading from reality..." % being_name)
	super.pentagon_sewers()

# ===== 3D INTERFACE CREATION =====

func _create_3d_interface() -> void:
	"""Create the 3D interface in game world"""
	
	# Create background mesh for the interface
	background_mesh = MeshInstance3D.new()
	background_mesh.name = "InterfaceBackground"
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = interface_size * interface_scale
	background_mesh.mesh = quad_mesh
	
	# Create material for the interface background
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.1, 0.15, 0.9)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_unshaded = true
	material.no_depth_test = false
	background_mesh.material_override = material
	
	add_child(background_mesh)
	
	# Create SubViewport for UI content
	var viewport = SubViewport.new()
	viewport.name = "InterfaceViewport"
	viewport.size = Vector2i(interface_size)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	
	# Create main interface panel
	interface_panel = Control.new()
	interface_panel.name = "InterfacePanel"
	interface_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport.add_child(interface_panel)
	
	# Create title bar
	_create_title_bar()
	
	# Create content area
	_create_content_area()
	
	# Create resize handle
	_create_resize_handle()
	
	# Apply viewport texture to mesh
	var viewport_material = StandardMaterial3D.new()
	viewport_material.albedo_texture = viewport.get_texture()
	viewport_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	viewport_material.flags_unshaded = true
	background_mesh.material_override = viewport_material

func _create_title_bar() -> void:
	"""Create title bar with title and close button"""
	title_bar = Panel.new()
	title_bar.name = "TitleBar"
	title_bar.custom_minimum_size.y = 30
	title_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	
	# Dark title bar background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.3, 1)
	title_bar.add_theme_stylebox_override("panel", style)
	
	interface_panel.add_child(title_bar)
	
	# Title label
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = interface_title
	title_label.position = Vector2(10, 5)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_bar.add_child(title_label)
	
	# Close button
	if is_closeable:
		close_button = Button.new()
		close_button.name = "CloseButton"
		close_button.text = "✕"
		close_button.size = Vector2(25, 25)
		close_button.position = Vector2(interface_size.x - 30, 2.5)
		close_button.pressed.connect(_on_close_pressed)
		title_bar.add_child(close_button)

func _create_content_area() -> void:
	"""Create the main content area"""
	content_area = Control.new()
	content_area.name = "ContentArea"
	content_area.position = Vector2(5, 35)
	content_area.size = Vector2(interface_size.x - 10, interface_size.y - 40)
	content_area.clip_contents = true
	
	# Content background
	var content_style = StyleBoxFlat.new()
	content_style.bg_color = Color(0.05, 0.05, 0.1, 0.8)
	content_area.add_theme_stylebox_override("panel", content_style)
	
	interface_panel.add_child(content_area)

func _create_resize_handle() -> void:
	"""Create resize handle for resizable interfaces"""
	if not is_resizable:
		return
	
	resize_handle = Control.new()
	resize_handle.name = "ResizeHandle"
	resize_handle.size = Vector2(15, 15)
	resize_handle.position = Vector2(interface_size.x - 15, interface_size.y - 15)
	resize_handle.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Visual indicator
	var handle_style = StyleBoxFlat.new()
	handle_style.bg_color = Color(0.5, 0.5, 0.5, 0.7)
	resize_handle.add_theme_stylebox_override("panel", handle_style)
	
	interface_panel.add_child(resize_handle)

# ===== INTERACTION SYSTEM =====

func _setup_interaction() -> void:
	"""Set up interaction area for grabbing and manipulating"""
	interaction_area = Area3D.new()
	interaction_area.name = "InteractionArea"
	add_child(interaction_area)
	
	interface_collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(interface_size.x * interface_scale, interface_size.y * interface_scale, 0.1)
	interface_collision_shape.shape = box_shape
	interaction_area.add_child(interface_collision_shape)
	
	# Connect interaction signals
	interaction_area.input_event.connect(_on_interaction_area_input)

func _connect_to_cursor() -> void:
	"""Connect to cursor for grab/move operations"""
	var cursor = get_tree().get_first_node_in_group("cursor")
	if cursor:
		# Interface is cursor-aware
		set_meta("cursor_interactable", true)

func _on_interaction_area_input(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	"""Handle interaction area input"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_grab(position)
			else:
				_stop_grab()

func _start_grab(grab_position: Vector3) -> void:
	"""Start grabbing the interface"""
	if not is_moveable:
		return
	
	is_grabbed = true
	grab_offset = global_position - grab_position
	
	# Visual feedback
	if background_mesh and background_mesh.material_override:
		background_mesh.material_override.albedo_color = Color(0.2, 0.3, 0.4, 0.9)
	
	print("🖥️ Grabbed interface: %s" % interface_title)

func _stop_grab() -> void:
	"""Stop grabbing the interface"""
	is_grabbed = false
	
	# Reset visual feedback
	if background_mesh and background_mesh.material_override:
		background_mesh.material_override.albedo_color = Color(0.1, 0.1, 0.15, 0.9)
	
	print("🖥️ Released interface: %s" % interface_title)

# ===== INTERFACE MANIPULATION =====

func _update_interface_state(delta: float) -> void:
	"""Update interface based on current state"""
	if is_grabbed:
		_update_grab_movement()
	
	if is_resizing:
		pass  # Resize functionality would be implemented here

func _update_grab_movement() -> void:
	"""Update position while being grabbed"""
	var cursor = get_tree().get_first_node_in_group("cursor")
	if cursor and cursor.has_method("get_world_position_3d"):
		var cursor_pos = cursor.get_world_position_3d()
		global_position = cursor_pos + grab_offset

func _face_camera() -> void:
	"""Make interface always face the camera"""
	var camera = get_viewport().get_camera_3d()
	if camera:
		look_at(camera.global_position, Vector3.UP)

func resize_interface(new_size: Vector2) -> void:
	"""Resize the interface"""
	if not is_resizable:
		return
	
	interface_size = new_size
	
	# Update background mesh
	if background_mesh and background_mesh.mesh:
		background_mesh.mesh.size = new_size * interface_scale
	
	# Update viewport
	var viewport = get_node("InterfaceViewport")
	if viewport:
		viewport.size = Vector2i(new_size)
	
	# Update content area
	if content_area:
		content_area.size = Vector2(new_size.x - 10, new_size.y - 40)
	
	# Update resize handle position
	if resize_handle:
		resize_handle.position = Vector2(new_size.x - 15, new_size.y - 15)
	
	# Update close button position
	if close_button:
		close_button.position = Vector2(new_size.x - 30, 2.5)
	
	print("🖥️ Resized interface to: %s" % new_size)

# ===== INTERFACE CONTENT =====

func load_interface_content(interface_path: String) -> bool:
	"""Load content into the interface"""
	var resource = load(interface_path)
	if not resource:
		print("❌ Failed to load interface: %s" % interface_path)
		return false
	
	# Clear existing content
	if loaded_interface:
		loaded_interface.queue_free()
	
	# Load new content
	if resource is PackedScene:
		loaded_interface = resource.instantiate()
	elif resource is GDScript:
		loaded_interface = Node.new()
		loaded_interface.set_script(resource)
	
	if loaded_interface:
		content_area.add_child(loaded_interface)
		interface_type = interface_path.get_file().get_basename()
		
		# Connect to Gemma vision
		_connect_to_gemma_vision()
		
		print("🖥️ Loaded interface content: %s" % interface_path)
		return true
	
	return false

func _connect_to_gemma_vision() -> void:
	"""Connect interface to Gemma's vision system"""
	var gemma = get_node_or_null("/root/GemmaAI")
	if gemma and gemma.has_method("observe_interface"):
		gemma.observe_interface(self)
		print("👁️ Interface connected to Gemma vision")

# ===== EVENT HANDLERS =====

func _on_close_pressed() -> void:
	"""Handle close button press"""
	print("🖥️ Closing interface: %s" % interface_title)
	
	# Emit signal for observers
	if has_signal("interface_closed"):
		interface_closed.emit(self)
	
	# Close with animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
	tween.tween_callback(queue_free)

func _handle_interface_input(event: InputEvent) -> void:
	"""Handle interface-specific input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F11:
				# Toggle fullscreen equivalent (larger size)
				if interface_size.x < 600:
					resize_interface(Vector2(800, 600))
				else:
					resize_interface(Vector2(400, 300))
			KEY_ESCAPE:
				if is_closeable:
					_on_close_pressed()

# ===== INTERFACE API =====

func set_title(new_title: String) -> void:
	"""Set interface title"""
	interface_title = new_title
	being_name = new_title
	if title_label:
		title_label.text = new_title

func set_content_text(text: String) -> void:
	"""Set simple text content"""
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	if content_area:
		# Clear existing content
		for child in content_area.get_children():
			child.queue_free()
		content_area.add_child(label)

func get_content_area() -> Control:
	"""Get the content area for custom content"""
	return content_area

# ===== SOCKET INTEGRATION =====

func mount_to_socket(socket_being: UniversalBeing, socket_name: String) -> bool:
	"""Mount this interface to a Universal Being's socket"""
	if socket_being.has_method("attach_to_socket"):
		return socket_being.attach_to_socket(socket_name, self)
	return false

# ===== INTERACTION OVERRIDES =====

func on_interaction(interactor: UniversalBeing) -> void:
	"""When someone interacts with the interface"""
	print("🖥️ %s: Interface activated by %s" % [interface_title, interactor.being_name])
	
	# Bring to front (increase layer)
	visual_layer += 1

func set_highlighted(highlighted: bool) -> void:
	"""Visual feedback when highlighted by cursor"""
	if background_mesh and background_mesh.material_override:
		if highlighted:
			background_mesh.material_override.albedo_color = Color(0.2, 0.2, 0.3, 0.9)
		else:
			background_mesh.material_override.albedo_color = Color(0.1, 0.1, 0.15, 0.9)

# Signal definitions
signal interface_closed(interface: UniversalInterfaceBeing)
signal interface_resized(new_size: Vector2)
signal content_changed(content_type: String)