extends Node3D
## Interactive 3D UI System
## Based on Luminus research: Flat 2D shapes in 3D space with hover/click interactions
class_name Interactive3DUISystem

# UI Configuration
const UI_LAYER_DISTANCE = 2.0
const UI_SCALE_NORMAL = Vector3(1.0, 1.0, 1.0)
const UI_SCALE_HOVER = Vector3(1.1, 1.1, 1.1)
const UI_SCALE_PRESSED = Vector3(0.95, 0.95, 0.95)

# UI Elements tracking
var ui_elements: Array[Dictionary] = []
var hovered_element: Dictionary = {}
var camera_ref: Camera3D

# Animation system
var tween: Tween

signal ui_element_clicked(element_id: String, element_data: Dictionary)
signal ui_element_hovered(element_id: String, element_data: Dictionary)
signal ui_element_unhovered(element_id: String)

func _ready() -> void:
	_setup_animation_system()
	print("Interactive 3D UI System initialized")

func initialize(camera: Camera3D) -> void:
	camera_ref = camera
	print("3D UI System connected to camera: ", camera.name)

func _setup_animation_system() -> void:
	tween = create_tween()
	tween.set_loops()  # Allow multiple animations

## Create Interactive 3D UI Button
## Based on Luminus pattern: Sprite3D with collision detection
func create_ui_button(config: Dictionary) -> Dictionary:
	var button_id = config.get("id", "button_" + str(randi()))
	var button_position = config.get("position", Vector3.ZERO)
	var size = config.get("size", Vector2(4.0, 2.0))
	var text = config.get("text", "Button")
	var color = config.get("color", Color.CYAN)
	
	# Create button container
	var button_container = Node3D.new()
	button_container.name = "UIButton_" + button_id
	button_container.position = button_position
	add_child(button_container)
	
	# Create visual element (Sprite3D with procedural material)
	var sprite_3d = Sprite3D.new()
	sprite_3d.name = "ButtonSprite"
	sprite_3d.pixel_size = 0.01  # High resolution
	sprite_3d.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y  # Face camera on Y-axis
	button_container.add_child(sprite_3d)
	
	# Create procedural button texture
	var button_texture = _create_procedural_button_texture(size, text, color)
	sprite_3d.texture = button_texture
	
	# Create collision area for interaction
	var area_3d = Area3D.new()
	area_3d.name = "ButtonCollision"
	button_container.add_child(area_3d)
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(size.x, size.y, 0.1)
	collision_shape.shape = box_shape
	area_3d.add_child(collision_shape)
	
	# Enable input picking
	area_3d.input_ray_pickable = true
	area_3d.monitoring = true
	
	# Connect signals
	area_3d.mouse_entered.connect(_on_button_mouse_entered.bind(button_id))
	area_3d.mouse_exited.connect(_on_button_mouse_exited.bind(button_id))
	area_3d.input_event.connect(_on_button_input_event.bind(button_id))
	
	# Store button data
	var button_data = {
		"id": button_id,
		"container": button_container,
		"sprite": sprite_3d,
		"area": area_3d,
		"config": config,
		"state": "normal"
	}
	
	ui_elements.append(button_data)
	
	print("Created 3D UI Button: ", button_id, " at ", position)
	return button_data

## Create Procedural Button Texture
## Based on Luminus shader research: Rounded corners and gradients
func _create_procedural_button_texture(size: Vector2, text: String, color: Color) -> ImageTexture:
	var image_size = Vector2i(int(size.x * 100), int(size.y * 100))  # High res
	var image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	
	# Fill with gradient background
	for y in range(image_size.y):
		for x in range(image_size.x):
			var uv = Vector2(float(x) / image_size.x, float(y) / image_size.y)
			var corner_radius = 0.1
			
			# Create rounded rectangle mask
			var is_inside = _is_inside_rounded_rect(uv, corner_radius)
			
			if is_inside:
				# Gradient from top to bottom
				var gradient_factor = 1.0 - uv.y
				var final_color = color.lerp(color.darkened(0.3), gradient_factor)
				final_color.a = 0.9
				image.set_pixel(x, y, final_color)
			else:
				image.set_pixel(x, y, Color.TRANSPARENT)
	
	# Add text overlay (simplified - in real implementation use proper font rendering)
	# Calculate contrasted color manually since contrasted() doesn't exist in Godot 4.5
	var text_color = _get_contrasted_color(color)
	_add_text_to_image(image, text, text_color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

## Rounded rectangle function (from Luminus shader research)
func _is_inside_rounded_rect(uv: Vector2, radius: float) -> bool:
	var rect_inset = Vector2(radius, radius)
	var dist = Vector2.ZERO
	
	if uv.x < radius:
		dist.x = radius - uv.x
	elif uv.x > 1.0 - radius:
		dist.x = uv.x - (1.0 - radius)
	else:
		dist.x = 0.0
	
	if uv.y < radius:
		dist.y = radius - uv.y
	elif uv.y > 1.0 - radius:
		dist.y = uv.y - (1.0 - radius)
	else:
		dist.y = 0.0
	
	var corner_dist = dist.length()
	return corner_dist <= radius

## Simple text rendering to image
func _add_text_to_image(image: Image, text: String, text_color: Color) -> void:
	# Simplified text rendering - draw basic characters
	var center_x = image.get_width() / 2
	var center_y = image.get_height() / 2
	
	# Draw simple text blocks (placeholder for actual font rendering)
	var char_width = 8
	var char_height = 12
	var text_width = text.length() * char_width
	var start_x = center_x - text_width / 2
	
	for i in range(text.length()):
		var char_x = start_x + i * char_width
		_draw_simple_char(image, text[i], char_x, center_y - char_height / 2, text_color)

## Draw simplified character shapes
func _draw_simple_char(image: Image, character: String, x: int, y: int, color: Color) -> void:
	# Very basic character shapes - replace with proper font system
	var char_size = 8
	for dy in range(char_size):
		for dx in range(char_size):
			if x + dx < image.get_width() and y + dy < image.get_height():
				# Simple block character for now
				if dx > 1 and dx < char_size - 1 and dy > 1 and dy < char_size - 1:
					image.set_pixel(x + dx, y + dy, color)

## Create 3D Panel (larger UI container)
func create_ui_panel(config: Dictionary) -> Dictionary:
	var panel_id = config.get("id", "panel_" + str(randi()))
	var panel_position = config.get("position", Vector3.ZERO)
	var size = config.get("size", Vector2(8.0, 6.0))
	var color = config.get("color", Color(0.1, 0.2, 0.4, 0.8))
	
	# Create panel container
	var panel_container = Node3D.new()
	panel_container.name = "UIPanel_" + panel_id
	panel_container.position = panel_position
	add_child(panel_container)
	
	# Create mesh for panel background
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "PanelMesh"
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = size
	mesh_instance.mesh = quad_mesh
	panel_container.add_child(mesh_instance)
	
	# Create panel material with transparency
	var material = StandardMaterial3D.new()
	material.flags_unshaded = true  # No lighting for UI
	material.flags_transparent = true
	material.albedo_color = color
	material.emission = color * 0.2  # Slight glow
	mesh_instance.material_override = material
	
	# Add collision for interaction
	var area_3d = Area3D.new()
	area_3d.name = "PanelCollision"
	panel_container.add_child(area_3d)
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(size.x, size.y, 0.1)
	collision_shape.shape = box_shape
	area_3d.add_child(collision_shape)
	
	area_3d.input_ray_pickable = true
	
	# Store panel data
	var panel_data = {
		"id": panel_id,
		"container": panel_container,
		"mesh": mesh_instance,
		"area": area_3d,
		"config": config,
		"type": "panel"
	}
	
	ui_elements.append(panel_data)
	print("Created 3D UI Panel: ", panel_id, " at ", position)
	return panel_data

## Animation handlers for hover effects
func _on_button_mouse_entered(button_id: String) -> void:
	var button_data = _get_ui_element_by_id(button_id)
	if button_data.is_empty():
		return
	
	button_data.state = "hovered"
	hovered_element = button_data
	
	# Animate scale up
	var container = button_data.container
	tween.tween_property(container, "scale", UI_SCALE_HOVER, 0.2)
	
	# Emit signal
	ui_element_hovered.emit(button_id, button_data)
	print("Button hovered: ", button_id)

func _on_button_mouse_exited(button_id: String) -> void:
	var button_data = _get_ui_element_by_id(button_id)
	if button_data.is_empty():
		return
	
	button_data.state = "normal"
	hovered_element = {}
	
	# Animate scale back to normal
	var container = button_data.container
	tween.tween_property(container, "scale", UI_SCALE_NORMAL, 0.2)
	
	# Emit signal
	ui_element_unhovered.emit(button_id)
	print("Button unhovered: ", button_id)

func _on_button_input_event(button_id: String, camera: Camera3D, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Button pressed animation
			var button_data = _get_ui_element_by_id(button_id)
			if not button_data.is_empty():
				var container = button_data.container
				
				# Quick press animation
				tween.tween_property(container, "scale", UI_SCALE_PRESSED, 0.1)
				await tween.tween_property(container, "scale", UI_SCALE_HOVER, 0.1).finished
				
				# Emit click signal
				ui_element_clicked.emit(button_id, button_data)
				print("Button clicked: ", button_id)

## Helper functions
func _get_ui_element_by_id(element_id: String) -> Dictionary:
	for element in ui_elements:
		if element.id == element_id:
			return element
	return {}

func remove_ui_element(element_id: String) -> void:
	var element = _get_ui_element_by_id(element_id)
	if not element.is_empty():
		element.container.queue_free()
		ui_elements.erase(element)
		print("Removed UI element: ", element_id)

func clear_all_ui_elements() -> void:
	for element in ui_elements:
		element.container.queue_free()
	ui_elements.clear()
	print("Cleared all 3D UI elements")

## Position UI elements relative to camera for always-visible interface
func position_ui_relative_to_camera(element_id: String, relative_position: Vector3) -> void:
	if not camera_ref:
		print("Warning: No camera reference set for UI positioning")
		return
	
	var element = _get_ui_element_by_id(element_id)
	if not element.is_empty():
		var camera_forward = -camera_ref.global_basis.z
		var camera_right = camera_ref.global_basis.x
		var camera_up = camera_ref.global_basis.y
		
		var world_position = camera_ref.global_position + \
			camera_forward * UI_LAYER_DISTANCE + \
			camera_right * relative_position.x + \
			camera_up * relative_position.y + \
			camera_forward * relative_position.z
		
		element.container.global_position = world_position

## Create demo UI layout
func create_demo_interface() -> void:
	print("Creating demo 3D UI interface...")
	
	# Create main panel
	var main_panel = create_ui_panel({
		"id": "main_panel",
		"position": Vector3(0, 0, 5),
		"size": Vector2(12, 8),
		"color": Color(0.05, 0.1, 0.2, 0.7)
	})
	
	# Create action buttons
	var buttons_config = [
		{
			"id": "toggle_layers",
			"position": Vector3(-4, 2, 4.5),
			"text": "Layers",
			"color": Color.CYAN
		},
		{
			"id": "save_notepad",
			"position": Vector3(0, 2, 4.5),
			"text": "Save",
			"color": Color.GREEN
		},
		{
			"id": "load_file",
			"position": Vector3(4, 2, 4.5),
			"text": "Load",
			"color": Color.ORANGE
		},
		{
			"id": "settings",
			"position": Vector3(-4, -2, 4.5),
			"text": "Settings",
			"color": Color.PURPLE
		},
		{
			"id": "help",
			"position": Vector3(0, -2, 4.5),
			"text": "Help",
			"color": Color.YELLOW
		},
		{
			"id": "exit",
			"position": Vector3(4, -2, 4.5),
			"text": "Exit",
			"color": Color.RED
		}
	]
	
	for button_config in buttons_config:
		create_ui_button(button_config)
	
	# Connect to UI signals for demo functionality
	ui_element_clicked.connect(_on_demo_ui_clicked)

func _on_demo_ui_clicked(element_id: String, element_data: Dictionary) -> void:
	print("Demo UI action: ", element_id)
	
	match element_id:
		"toggle_layers":
			print("Toggling Notepad 3D layers...")
		"save_notepad":
			print("Saving notepad content...")
		"load_file":
			print("Loading file...")
		"settings":
			print("Opening settings...")
		"help":
			print("Showing help...")
		"exit":
			print("Exiting application...")

# ─────────────────────────────────────────────────────────────────────────────────
# 🎨 GET CONTRASTED COLOR - ACCESSIBILITY ENHANCEMENT
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Base color to contrast against
# PROCESS: Calculates readable text color based on luminance
# OUTPUT: Black or white color for optimal readability
# CHANGES: None - pure calculation
# CONNECTION: Used by button text generation for visual accessibility
# ─────────────────────────────────────────────────────────────────────────────────
func _get_contrasted_color(base_color: Color) -> Color:
	# Calculate luminance using the relative luminance formula
	var luminance = 0.299 * base_color.r + 0.587 * base_color.g + 0.114 * base_color.b
	
	# Return white text on dark backgrounds, black text on light backgrounds
	if luminance > 0.5:
		return Color.BLACK
	else:
		return Color.WHITE