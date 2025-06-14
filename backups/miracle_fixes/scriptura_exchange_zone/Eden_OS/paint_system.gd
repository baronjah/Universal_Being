extends Node

class_name PaintSystem

signal stroke_created(stroke_id, color, dimension)
signal shape_painted(shape_id, texture_id)
signal texture_created(texture_id, dimension)

# Stroke types
enum StrokeType {
	BRUSH,          # Regular brush stroke
	WATER,          # Water/blend effect
	GLOW,           # Glowing effect
	PARTICLE,       # Particle effect
	DIMENSIONAL,    # Cross-dimensional stroke
	PATTERN         # Pattern-based stroke
}

# Brush settings
class BrushSettings:
	var size: float = 10.0
	var opacity: float = 1.0
	var hardness: float = 0.8  # 0.0 = soft, 1.0 = hard
	var spacing: float = 0.1   # Distance between points as fraction of size
	var color: Color = Color.WHITE
	var stroke_type: int = StrokeType.BRUSH
	var dimension: int = 1
	var jitter: float = 0.0
	var pressure_sensitivity: bool = true
	var properties = {}  # Additional custom properties
	
	func duplicate() -> BrushSettings:
		var new_settings = BrushSettings.new()
		new_settings.size = size
		new_settings.opacity = opacity
		new_settings.hardness = hardness
		new_settings.spacing = spacing
		new_settings.color = color
		new_settings.stroke_type = stroke_type
		new_settings.dimension = dimension
		new_settings.jitter = jitter
		new_settings.pressure_sensitivity = pressure_sensitivity
		new_settings.properties = properties.duplicate()
		return new_settings

# Stroke data
class Stroke:
	var id: String
	var points = []          # Array of Vector2 points
	var pressures = []       # Array of pressure values
	var brush_settings: BrushSettings
	var creation_time: int
	var last_update_time: int
	var properties = {}
	
	func _init(p_id: String, p_brush_settings: BrushSettings):
		id = p_id
		brush_settings = p_brush_settings.duplicate()
		creation_time = Time.get_unix_time_from_system()
		last_update_time = creation_time
	
	func add_point(position: Vector2, pressure: float = 1.0):
		points.append(position)
		pressures.append(pressure)
		last_update_time = Time.get_unix_time_from_system()
	
	func get_bounding_rect() -> Rect2:
		if points.size() == 0:
			return Rect2(0, 0, 0, 0)
		
		var min_x = points[0].x
		var min_y = points[0].y
		var max_x = points[0].x
		var max_y = points[0].y
		
		for i in range(1, points.size()):
			min_x = min(min_x, points[i].x)
			min_y = min(min_y, points[i].y)
			max_x = max(max_x, points[i].x)
			max_y = max(max_y, points[i].y)
		
		# Add brush size to bounds
		var half_size = brush_settings.size / 2.0
		min_x -= half_size
		min_y -= half_size
		max_x += half_size
		max_y += half_size
		
		return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)
	
	func serialize() -> Dictionary:
		var serialized_points = []
		for point in points:
			serialized_points.append({"x": point.x, "y": point.y})
		
		return {
			"id": id,
			"points": serialized_points,
			"pressures": pressures,
			"brush_settings": {
				"size": brush_settings.size,
				"opacity": brush_settings.opacity,
				"hardness": brush_settings.hardness,
				"spacing": brush_settings.spacing,
				"color": brush_settings.color.to_html(),
				"stroke_type": brush_settings.stroke_type,
				"dimension": brush_settings.dimension,
				"jitter": brush_settings.jitter,
				"pressure_sensitivity": brush_settings.pressure_sensitivity,
				"properties": brush_settings.properties
			},
			"creation_time": creation_time,
			"last_update_time": last_update_time,
			"properties": properties
		}
	
	static func deserialize(data: Dictionary) -> Stroke:
		var brush_settings = BrushSettings.new()
		brush_settings.size = data.brush_settings.size
		brush_settings.opacity = data.brush_settings.opacity
		brush_settings.hardness = data.brush_settings.hardness
		brush_settings.spacing = data.brush_settings.spacing
		brush_settings.color = Color.from_html(data.brush_settings.color)
		brush_settings.stroke_type = data.brush_settings.stroke_type
		brush_settings.dimension = data.brush_settings.dimension
		brush_settings.jitter = data.brush_settings.jitter
		brush_settings.pressure_sensitivity = data.brush_settings.pressure_sensitivity
		brush_settings.properties = data.brush_settings.properties
		
		var stroke = Stroke.new(data.id, brush_settings)
		
		var points = []
		for point_data in data.points:
			points.append(Vector2(point_data.x, point_data.y))
		
		stroke.points = points
		stroke.pressures = data.pressures
		stroke.creation_time = data.creation_time
		stroke.last_update_time = data.last_update_time
		stroke.properties = data.properties
		
		return stroke

# Paint texture class
class PaintTexture:
	var id: String
	var image: Image
	var dimension: int
	var strokes = []  # Array of stroke IDs that make up this texture
	var creation_time: int
	var last_update_time: int
	var properties = {}
	
	func _init(p_id: String, size: Vector2, p_dimension: int):
		id = p_id
		image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
		image.fill(Color(0, 0, 0, 0))  # Transparent background
		dimension = p_dimension
		creation_time = Time.get_unix_time_from_system()
		last_update_time = creation_time
	
	func add_stroke(stroke_id: String):
		if not stroke_id in strokes:
			strokes.append(stroke_id)
			last_update_time = Time.get_unix_time_from_system()
	
	func clear():
		image.fill(Color(0, 0, 0, 0))
		last_update_time = Time.get_unix_time_from_system()
	
	func get_texture() -> ImageTexture:
		return ImageTexture.create_from_image(image)
	
	func serialize() -> Dictionary:
		# Save image to temporary buffer
		var buffer = image.save_png_to_buffer()
		var image_data = Marshalls.raw_to_base64(buffer)
		
		return {
			"id": id,
			"image_data": image_data,
			"dimension": dimension,
			"strokes": strokes,
			"creation_time": creation_time,
			"last_update_time": last_update_time,
			"properties": properties,
			"width": image.get_width(),
			"height": image.get_height()
		}
	
	static func deserialize(data: Dictionary) -> PaintTexture:
		var texture = PaintTexture.new(data.id, Vector2(data.width, data.height), data.dimension)
		
		# Recreate image from data
		var buffer = Marshalls.base64_to_raw(data.image_data)
		var img = Image.new()
		img.load_png_from_buffer(buffer)
		texture.image = img
		
		texture.strokes = data.strokes
		texture.creation_time = data.creation_time
		texture.last_update_time = data.last_update_time
		texture.properties = data.properties
		
		return texture

# Shape paint assignment
class ShapePaint:
	var shape_id: String
	var texture_id: String
	var creation_time: int
	var properties = {}
	
	func _init(p_shape_id: String, p_texture_id: String):
		shape_id = p_shape_id
		texture_id = p_texture_id
		creation_time = Time.get_unix_time_from_system()

# Storage
var strokes = {}  # id -> Stroke
var textures = {}  # id -> PaintTexture
var shape_paints = {}  # shape_id -> ShapePaint

# Counters
var stroke_id_counter = 0
var texture_id_counter = 0

# Active brush settings
var current_brush_settings = BrushSettings.new()
var active_stroke: Stroke = null

# References to other systems
var shape_system: ShapeSystem
var dimensional_color_system: DimensionalColorSystem
var turn_cycle_manager: TurnCycleManager

func _ready():
	# Get references to other systems
	shape_system = get_node_or_null("/root/ShapeSystem")
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	turn_cycle_manager = get_node_or_null("/root/TurnCycleManager")
	
	# Set default brush settings based on current dimension
	if turn_cycle_manager and dimensional_color_system:
		var current_turn = turn_cycle_manager.current_turn
		if current_turn > 0:
			var current_color = turn_cycle_manager.turn_color_mapping[current_turn - 1]
			var color = dimensional_color_system.get_color_value(current_color)
			current_brush_settings.color = color
			current_brush_settings.dimension = dimensional_color_system.color_properties[current_color].dimensional_depth
	
	# Load data
	_load_data()

# Stroke creation and painting
func start_stroke() -> String:
	var stroke_id = "stroke_" + str(stroke_id_counter)
	stroke_id_counter += 1
	
	active_stroke = Stroke.new(stroke_id, current_brush_settings)
	strokes[stroke_id] = active_stroke
	
	return stroke_id

func add_point_to_stroke(position: Vector2, pressure: float = 1.0) -> bool:
	if not active_stroke:
		return false
	
	active_stroke.add_point(position, pressure)
	return true

func end_stroke() -> String:
	if not active_stroke:
		return ""
	
	var stroke_id = active_stroke.id
	active_stroke = null
	
	emit_signal("stroke_created", stroke_id, current_brush_settings.color, current_brush_settings.dimension)
	_save_data()
	
	return stroke_id

func cancel_stroke():
	if active_stroke:
		strokes.erase(active_stroke.id)
		active_stroke = null

func create_texture(size: Vector2, dimension: int = -1) -> String:
	if dimension == -1:
		dimension = current_brush_settings.dimension
	
	var texture_id = "texture_" + str(texture_id_counter)
	texture_id_counter += 1
	
	var texture = PaintTexture.new(texture_id, size, dimension)
	textures[texture_id] = texture
	
	emit_signal("texture_created", texture_id, dimension)
	_save_data()
	
	return texture_id

func add_stroke_to_texture(stroke_id: String, texture_id: String) -> bool:
	if not strokes.has(stroke_id) or not textures.has(texture_id):
		return false
	
	var stroke = strokes[stroke_id]
	var texture = textures[texture_id]
	
	# Check if dimensions match
	if stroke.brush_settings.dimension != texture.dimension:
		# Allow cross-dimensional drawing if the stroke is of DIMENSIONAL type
		if stroke.brush_settings.stroke_type != StrokeType.DIMENSIONAL:
			return false
	
	# Add the stroke to the texture metadata
	texture.add_stroke(stroke_id)
	
	# Render the stroke onto the texture
	_render_stroke_to_texture(stroke, texture)
	
	_save_data()
	return true

func _render_stroke_to_texture(stroke: Stroke, texture: PaintTexture):
	var image = texture.image
	image.lock()
	
	var brush_settings = stroke.brush_settings
	var points = stroke.points
	var pressures = stroke.pressures
	
	if points.size() < 2:
		# Just a single point
		if points.size() == 1:
			var pos = points[0]
			var size = brush_settings.size
			if brush_settings.pressure_sensitivity and pressures.size() > 0:
				size *= pressures[0]
			
			_draw_dot(image, pos, size, brush_settings)
	else:
		# Line segments
		for i in range(1, points.size()):
			var start = points[i-1]
			var end = points[i]
			var start_pressure = 1.0
			var end_pressure = 1.0
			
			if brush_settings.pressure_sensitivity:
				if pressures.size() > i-1:
					start_pressure = pressures[i-1]
				if pressures.size() > i:
					end_pressure = pressures[i]
			
			_draw_line_segment(image, start, end, start_pressure, end_pressure, brush_settings)
	
	image.unlock()

func _draw_dot(image: Image, position: Vector2, size: float, brush_settings: BrushSettings):
	var radius = size / 2.0
	var color = brush_settings.color
	color.a *= brush_settings.opacity
	
	var hardness = brush_settings.hardness
	var center_x = int(position.x)
	var center_y = int(position.y)
	
	var min_x = max(0, center_x - int(radius))
	var min_y = max(0, center_y - int(radius))
	var max_x = min(image.get_width() - 1, center_x + int(radius))
	var max_y = min(image.get_height() - 1, center_y + int(radius))
	
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var distance = Vector2(x, y).distance_to(Vector2(center_x, center_y))
			if distance <= radius:
				var alpha_factor = 1.0
				if hardness < 1.0:
					alpha_factor = clamp(1.0 - (distance / radius) * (1.0 - hardness), 0.0, 1.0)
				
				var pixel_color = color
				pixel_color.a *= alpha_factor
				
				# Apply different effects based on stroke type
				match brush_settings.stroke_type:
					StrokeType.GLOW:
						pixel_color.a *= (1.0 - distance / radius) * 0.5
						pixel_color.r *= 1.2
						pixel_color.g *= 1.2
						pixel_color.b *= 1.2
					
					StrokeType.WATER:
						var existing_color = image.get_pixel(x, y)
						pixel_color = existing_color.lerp(pixel_color, 0.3)
					
					StrokeType.PARTICLE:
						if randf() > 0.7:
							pixel_color.a *= randf()
					
					StrokeType.DIMENSIONAL:
						# Changes color based on distance from center
						var dim_factor = distance / radius
						pixel_color = pixel_color.lerp(Color(
							pixel_color.r * (1.0 - dim_factor),
							pixel_color.g * dim_factor,
							pixel_color.b * (1.0 - dim_factor * 0.5),
							pixel_color.a
						), 0.5)
					
					StrokeType.PATTERN:
						# Apply a pattern effect
						var pattern = int(x/4 + y/4) % 2
						if pattern == 0:
							pixel_color.a *= 0.7
				
				_blend_pixel(image, x, y, pixel_color)

func _draw_line_segment(image: Image, start: Vector2, end: Vector2, 
		start_pressure: float, end_pressure: float, brush_settings: BrushSettings):
	var distance = start.distance_to(end)
	if distance < 0.1:
		return
	
	var steps = int(distance / (brush_settings.size * brush_settings.spacing)) + 1
	steps = max(steps, 2)
	
	for i in range(steps):
		var t = float(i) / float(steps - 1)
		var pos = start.lerp(end, t)
		var pressure = start_pressure + (end_pressure - start_pressure) * t
		
		if brush_settings.jitter > 0:
			var jitter_amount = brush_settings.jitter * brush_settings.size
			pos += Vector2(
				randf_range(-jitter_amount, jitter_amount),
				randf_range(-jitter_amount, jitter_amount)
			)
		
		_draw_dot(image, pos, brush_settings.size * pressure, brush_settings)

func _blend_pixel(image: Image, x: int, y: int, color: Color):
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	
	var existing = image.get_pixel(x, y)
	var new_color = Color(
		existing.r * (1.0 - color.a) + color.r * color.a,
		existing.g * (1.0 - color.a) + color.g * color.a,
		existing.b * (1.0 - color.a) + color.b * color.a,
		existing.a + color.a * (1.0 - existing.a)
	)
	
	image.set_pixel(x, y, new_color)

func clear_texture(texture_id: String):
	if not textures.has(texture_id):
		return
	
	textures[texture_id].clear()
	_save_data()

func paint_shape(shape_id: String, texture_id: String) -> bool:
	if not shape_system:
		return false
	
	if not shape_system.shapes.has(shape_id) or not textures.has(texture_id):
		return false
	
	var shape = shape_system.shapes[shape_id]
	var texture = textures[texture_id]
	
	# Check if dimensions match
	if shape.dimension != texture.dimension:
		# Allow cross-dimensional painting if the texture has dimensional strokes
		var has_dimensional_strokes = false
		for stroke_id in texture.strokes:
			if strokes.has(stroke_id) and strokes[stroke_id].brush_settings.stroke_type == StrokeType.DIMENSIONAL:
				has_dimensional_strokes = true
				break
		
		if not has_dimensional_strokes:
			return false
	
	# Create or update the shape paint
	var shape_paint = ShapePaint.new(shape_id, texture_id)
	shape_paints[shape_id] = shape_paint
	
	# Update shape properties
	shape.properties["painted"] = true
	shape.properties["texture_id"] = texture_id
	
	emit_signal("shape_painted", shape_id, texture_id)
	_save_data()
	
	return true

func get_texture_for_shape(shape_id: String) -> String:
	if shape_paints.has(shape_id):
		return shape_paints[shape_id].texture_id
	return ""

func create_texture_for_shape(shape_id: String) -> String:
	if not shape_system:
		return ""
	
	if not shape_system.shapes.has(shape_id):
		return ""
	
	var shape = shape_system.shapes[shape_id]
	var bbox = shape.get_bounding_box()
	
	# Add some padding
	var padding = 20
	bbox.position -= Vector2(padding, padding)
	bbox.size += Vector2(padding * 2, padding * 2)
	
	# Create a texture based on the shape's bounding box
	var texture_id = create_texture(bbox.size, shape.dimension)
	
	# Set texture origin to match shape position
	textures[texture_id].properties["origin"] = bbox.position
	
	# Paint the shape with this texture
	paint_shape(shape_id, texture_id)
	
	return texture_id

func apply_color_to_current_brush(color: Color):
	current_brush_settings.color = color

func set_brush_dimension(dimension: int):
	current_brush_settings.dimension = dimension

func set_brush_size(size: float):
	current_brush_settings.size = size

func set_brush_opacity(opacity: float):
	current_brush_settings.opacity = opacity

func set_brush_hardness(hardness: float):
	current_brush_settings.hardness = hardness

func set_brush_stroke_type(stroke_type: int):
	current_brush_settings.stroke_type = stroke_type

func get_strokes_in_dimension(dimension: int) -> Array:
	var result = []
	
	for stroke_id in strokes:
		var stroke = strokes[stroke_id]
		if stroke.brush_settings.dimension == dimension:
			result.append(stroke_id)
	
	return result

func get_textures_in_dimension(dimension: int) -> Array:
	var result = []
	
	for texture_id in textures:
		var texture = textures[texture_id]
		if texture.dimension == dimension:
			result.append(texture_id)
	
	return result

func generate_texture_preview(texture_id: String, size: Vector2) -> ImageTexture:
	if not textures.has(texture_id):
		return null
	
	var texture = textures[texture_id]
	var orig_size = Vector2(texture.image.get_width(), texture.image.get_height())
	
	var scale = min(size.x / orig_size.x, size.y / orig_size.y)
	var new_size = orig_size * scale
	
	var preview_image = texture.image.duplicate()
	preview_image.resize(int(new_size.x), int(new_size.y))
	
	return ImageTexture.create_from_image(preview_image)

func _load_data():
	if FileAccess.file_exists("user://eden_paint.save"):
		var file = FileAccess.open("user://eden_paint.save", FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			
			stroke_id_counter = data.stroke_id_counter
			texture_id_counter = data.texture_id_counter
			
			# Load strokes
			strokes.clear()
			for stroke_data in data.strokes:
				var stroke = Stroke.deserialize(stroke_data)
				strokes[stroke.id] = stroke
			
			# Load textures
			textures.clear()
			for texture_data in data.textures:
				var texture = PaintTexture.deserialize(texture_data)
				textures[texture.id] = texture
			
			# Load shape paints
			shape_paints.clear()
			for paint_data in data.shape_paints:
				var shape_paint = ShapePaint.new(paint_data.shape_id, paint_data.texture_id)
				shape_paint.creation_time = paint_data.creation_time
				shape_paint.properties = paint_data.properties
				shape_paints[paint_data.shape_id] = shape_paint

func _save_data():
	var serialized_strokes = []
	for stroke_id in strokes:
		serialized_strokes.append(strokes[stroke_id].serialize())
	
	var serialized_textures = []
	for texture_id in textures:
		serialized_textures.append(textures[texture_id].serialize())
	
	var serialized_shape_paints = []
	for shape_id in shape_paints:
		var shape_paint = shape_paints[shape_id]
		serialized_shape_paints.append({
			"shape_id": shape_paint.shape_id,
			"texture_id": shape_paint.texture_id,
			"creation_time": shape_paint.creation_time,
			"properties": shape_paint.properties
		})
	
	var data = {
		"stroke_id_counter": stroke_id_counter,
		"texture_id_counter": texture_id_counter,
		"strokes": serialized_strokes,
		"textures": serialized_textures,
		"shape_paints": serialized_shape_paints
	}
	
	var json_string = JSON.stringify(data)
	var file = FileAccess.open("user://eden_paint.save", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()