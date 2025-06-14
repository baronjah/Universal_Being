extends Control

class_name PaintCanvas

# Signals
signal stroke_completed(stroke_id)
signal canvas_painted()
signal brush_changed(settings)

# Canvas properties
var canvas_size: Vector2
var background_color: Color = Color(0, 0, 0, 0)
var show_grid: bool = false
var grid_size: float = 20.0
var grid_color: Color = Color(0.3, 0.3, 0.3, 0.3)

# Painting state
var painting: bool = false
var last_position: Vector2
var current_pressure: float = 1.0
var current_texture_id: String = ""

# References to other systems
var paint_system: PaintSystem
var dimensional_color_system: DimensionalColorSystem
var turn_cycle_manager: TurnCycleManager

# UI elements - to be assigned in the scene
@onready var canvas_texture_rect = $CanvasTextureRect
@onready var shape_overlay = $ShapeOverlay
@onready var grid_overlay = $GridOverlay
@onready var stroke_overlay = $StrokeOverlay
@onready var canvas_background = $CanvasBackground

# Current texture being edited
var texture_image: Image
var texture: ImageTexture

func _ready():
	# Get references to systems
	paint_system = get_node_or_null("/root/PaintSystem")
	if not paint_system:
		paint_system = PaintSystem.new()
		add_child(paint_system)
	
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	turn_cycle_manager = get_node_or_null("/root/TurnCycleManager")
	
	# Connect signals
	paint_system.texture_created.connect(_on_texture_created)
	
	# Initial canvas size based on parent container
	canvas_size = size
	_create_new_canvas()
	
	# Update color based on current turn
	_update_brush_color()

func _update_brush_color():
	if turn_cycle_manager and dimensional_color_system:
		var current_turn = turn_cycle_manager.current_turn
		if current_turn > 0:
			var current_color = turn_cycle_manager.turn_color_mapping[current_turn - 1]
			var color = dimensional_color_system.get_color_value(current_color)
			paint_system.apply_color_to_current_brush(color)
			emit_signal("brush_changed", paint_system.current_brush_settings)

func _create_new_canvas():
	canvas_size = size
	
	# Create a new texture
	var dimension = 1
	if paint_system.current_brush_settings:
		dimension = paint_system.current_brush_settings.dimension
	
	current_texture_id = paint_system.create_texture(canvas_size, dimension)
	_update_canvas_display()
	
	# Create grid
	_update_grid()

func load_texture(texture_id: String) -> bool:
	if not paint_system.textures.has(texture_id):
		return false
	
	current_texture_id = texture_id
	_update_canvas_display()
	return true

func _update_canvas_display():
	if not paint_system.textures.has(current_texture_id):
		return
	
	var paint_texture = paint_system.textures[current_texture_id]
	texture_image = paint_texture.image
	texture = paint_texture.get_texture()
	
	canvas_texture_rect.texture = texture

func _update_grid():
	if not show_grid:
		grid_overlay.visible = false
		return
	
	grid_overlay.visible = true
	
	var grid_image = Image.create(int(canvas_size.x), int(canvas_size.y), false, Image.FORMAT_RGBA8)
	grid_image.fill(Color(0, 0, 0, 0))
	
	# Draw grid
	grid_image.lock()
	for x in range(0, int(canvas_size.x) + 1, int(grid_size)):
		for y in range(0, int(canvas_size.y)):
			grid_image.set_pixel(x, y, grid_color)
	
	for y in range(0, int(canvas_size.y) + 1, int(grid_size)):
		for x in range(0, int(canvas_size.x)):
			grid_image.set_pixel(x, y, grid_color)
	grid_image.unlock()
	
	grid_overlay.texture = ImageTexture.create_from_image(grid_image)

func _gui_input(event):
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey:
		_handle_key_event(event)

func _handle_mouse_button(event: InputEventMouseButton):
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start painting
			painting = true
			last_position = event.position
			current_pressure = event.pressure if event.pressure > 0 else 1.0
			
			# Start a new stroke
			paint_system.start_stroke()
			paint_system.add_point_to_stroke(event.position, current_pressure)
			
			# Preview
			_preview_stroke(event.position)
		else:
			# End painting
			if painting:
				painting = false
				
				# Complete stroke
				var stroke_id = paint_system.end_stroke()
				
				# Add the stroke to the current texture
				if stroke_id != "" and current_texture_id != "":
					paint_system.add_stroke_to_texture(stroke_id, current_texture_id)
				
				_update_canvas_display()
				emit_signal("stroke_completed", stroke_id)
				
				# Clear preview
				_clear_stroke_preview()

func _handle_mouse_motion(event: InputEventMouseMotion):
	if painting:
		current_pressure = event.pressure if event.pressure > 0 else 1.0
		
		# Add point to current stroke
		paint_system.add_point_to_stroke(event.position, current_pressure)
		
		# Preview
		_preview_stroke(event.position)
		
		last_position = event.position

func _handle_key_event(event: InputEventKey):
	if event.pressed:
		if event.keycode == KEY_ESCAPE:
			# Cancel current stroke
			if painting:
				painting = false
				paint_system.cancel_stroke()
				_clear_stroke_preview()
		
		elif event.keycode == KEY_G:
			# Toggle grid
			show_grid = !show_grid
			_update_grid()
		
		elif event.keycode == KEY_C:
			# Clear canvas
			if current_texture_id != "":
				paint_system.clear_texture(current_texture_id)
				_update_canvas_display()
				emit_signal("canvas_painted")

func _preview_stroke(position: Vector2):
	# Create a temporary image to preview the current stroke
	var preview_image = Image.create(int(canvas_size.x), int(canvas_size.y), false, Image.FORMAT_RGBA8)
	preview_image.fill(Color(0, 0, 0, 0))
	
	var brush_settings = paint_system.current_brush_settings
	var size = brush_settings.size
	if brush_settings.pressure_sensitivity:
		size *= current_pressure
	
	preview_image.lock()
	
	# Just draw a circle at the current position for preview
	var radius = size / 2.0
	var center_x = int(position.x)
	var center_y = int(position.y)
	
	var min_x = max(0, center_x - int(radius))
	var min_y = max(0, center_y - int(radius))
	var max_x = min(preview_image.get_width() - 1, center_x + int(radius))
	var max_y = min(preview_image.get_height() - 1, center_y + int(radius))
	
	var color = brush_settings.color
	color.a *= brush_settings.opacity
	
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var distance = Vector2(x, y).distance_to(Vector2(center_x, center_y))
			if distance <= radius:
				var alpha_factor = 1.0
				if brush_settings.hardness < 1.0:
					alpha_factor = clamp(1.0 - (distance / radius) * (1.0 - brush_settings.hardness), 0.0, 1.0)
				
				var pixel_color = color
				pixel_color.a *= alpha_factor * 0.5  # More transparent for preview
				
				preview_image.set_pixel(x, y, pixel_color)
	
	preview_image.unlock()
	
	stroke_overlay.texture = ImageTexture.create_from_image(preview_image)

func _clear_stroke_preview():
	var clear_image = Image.create(int(canvas_size.x), int(canvas_size.y), false, Image.FORMAT_RGBA8)
	clear_image.fill(Color(0, 0, 0, 0))
	stroke_overlay.texture = ImageTexture.create_from_image(clear_image)

func clear_canvas():
	if current_texture_id != "":
		paint_system.clear_texture(current_texture_id)
		_update_canvas_display()
		emit_signal("canvas_painted")

func resize_canvas(new_size: Vector2):
	if new_size.x <= 0 or new_size.y <= 0:
		return
	
	# Create a new texture with the new size
	var dimension = paint_system.textures[current_texture_id].dimension if paint_system.textures.has(current_texture_id) else 1
	var new_texture_id = paint_system.create_texture(new_size, dimension)
	
	# Copy the old texture to the new one if it exists
	if paint_system.textures.has(current_texture_id):
		var old_texture = paint_system.textures[current_texture_id]
		var old_image = old_texture.image
		var new_image = paint_system.textures[new_texture_id].image
		
		new_image.lock()
		old_image.lock()
		
		var copy_width = min(old_image.get_width(), new_image.get_width())
		var copy_height = min(old_image.get_height(), new_image.get_height())
		
		for y in range(copy_height):
			for x in range(copy_width):
				var color = old_image.get_pixel(x, y)
				new_image.set_pixel(x, y, color)
		
		old_image.unlock()
		new_image.unlock()
	
	current_texture_id = new_texture_id
	canvas_size = new_size
	_update_canvas_display()
	_update_grid()

func set_brush_properties(property: String, value):
	match property:
		"size":
			paint_system.set_brush_size(value)
		"opacity":
			paint_system.set_brush_opacity(value)
		"hardness":
			paint_system.set_brush_hardness(value)
		"stroke_type":
			paint_system.set_brush_stroke_type(value)
		"dimension":
			paint_system.set_brush_dimension(value)
		"color":
			paint_system.apply_color_to_current_brush(value)
	
	emit_signal("brush_changed", paint_system.current_brush_settings)

func set_shape_overlay(shape_id: String):
	if not is_node_ready():
		await ready
	
	var shape_system = get_node_or_null("/root/ShapeSystem")
	if not shape_system or not shape_system.shapes.has(shape_id):
		shape_overlay.visible = false
		return
	
	var shape = shape_system.shapes[shape_id]
	
	# Create a shape outline image
	var outline_image = Image.create(int(canvas_size.x), int(canvas_size.y), false, Image.FORMAT_RGBA8)
	outline_image.fill(Color(0, 0, 0, 0))
	
	outline_image.lock()
	
	var points = shape.points
	if points.size() >= 2:
		# Draw the shape outline
		var color = shape.color
		color.a = 0.5
		
		for i in range(points.size()):
			var start = points[i]
			var end = points[(i + 1) % points.size()]
			
			# Simple line drawing algorithm
			var dx = int(end.x) - int(start.x)
			var dy = int(end.y) - int(start.y)
			var steps = max(abs(dx), abs(dy))
			
			if steps == 0:
				continue
			
			var x_increment = dx / float(steps)
			var y_increment = dy / float(steps)
			
			var x = start.x
			var y = start.y
			
			for j in range(steps + 1):
				if x >= 0 and x < outline_image.get_width() and y >= 0 and y < outline_image.get_height():
					outline_image.set_pixel(int(x), int(y), color)
				
				x += x_increment
				y += y_increment
	
	outline_image.unlock()
	
	shape_overlay.texture = ImageTexture.create_from_image(outline_image)
	shape_overlay.visible = true

func hide_shape_overlay():
	shape_overlay.visible = false

func _on_texture_created(texture_id, dimension):
	if current_texture_id == "":
		current_texture_id = texture_id
		_update_canvas_display()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		# Optionally resize the canvas when the control is resized
		var new_size = get_rect().size
		if canvas_size != new_size:
			# Only resize canvas if explicitly requested
			pass