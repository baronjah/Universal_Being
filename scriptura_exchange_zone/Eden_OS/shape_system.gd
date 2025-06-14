extends Node

class_name ShapeSystem

signal shape_created(shape_id, shape_type)
signal shape_transformed(shape_id, transformation_type)
signal shape_merged(shape_id1, shape_id2, new_shape_id)
signal zone_created(zone_id, zone_properties)
signal point_created(point_id, coordinates)

# Basic shape types
enum ShapeType {
	POINT,      # Single point in space
	LINE,       # Line between two points
	TRIANGLE,   # Three points forming a triangle
	SQUARE,     # Four points forming a square
	PENTAGON,   # Five-sided shape
	HEXAGON,    # Six-sided shape
	CIRCLE,     # Perfect circle
	ELLIPSE,    # Oval shape
	SPIRAL,     # Spiraling shape
	STAR,       # Star-shaped polygon
	CUSTOM      # Custom polygon with arbitrary points
}

# 2D transformation types
enum TransformationType {
	TRANSLATE,  # Move shape
	ROTATE,     # Rotate shape
	SCALE,      # Scale shape
	REFLECT,    # Mirror shape
	SHEAR,      # Deform shape
	MORPH       # Gradual transformation between shapes
}

# Shape class
class Shape2D:
	var id: String
	var type: int  # ShapeType
	var points: Array = []  # Array of Vector2 points
	var color: Color
	var dimension: int  # Associated dimension
	var properties: Dictionary = {}
	var connected_shapes: Array = []
	var creation_time: int
	var zone_id: String = ""
	var metadata: Dictionary = {}
	
	func _init(p_id: String, p_type: int, p_points: Array, p_color: Color, p_dimension: int):
		id = p_id
		type = p_type
		points = p_points
		color = p_color
		dimension = p_dimension
		creation_time = Time.get_unix_time_from_system()
	
	func add_point(point: Vector2):
		points.append(point)
	
	func remove_point(index: int):
		if index >= 0 and index < points.size():
			points.remove_at(index)
	
	func translate(offset: Vector2):
		for i in range(points.size()):
			points[i] += offset
	
	func rotate(center: Vector2, angle_rad: float):
		for i in range(points.size()):
			var point = points[i]
			var relative_pos = point - center
			var rotated_pos = Vector2(
				relative_pos.x * cos(angle_rad) - relative_pos.y * sin(angle_rad),
				relative_pos.x * sin(angle_rad) + relative_pos.y * cos(angle_rad)
			)
			points[i] = center + rotated_pos
	
	func scale(center: Vector2, scale_factor: Vector2):
		for i in range(points.size()):
			var point = points[i]
			var relative_pos = point - center
			relative_pos.x *= scale_factor.x
			relative_pos.y *= scale_factor.y
			points[i] = center + relative_pos
	
	func reflect(axis: Vector2):
		var axis_normalized = axis.normalized()
		for i in range(points.size()):
			var point = points[i]
			var dot_product = point.dot(axis_normalized)
			var projection = axis_normalized * dot_product
			points[i] = 2 * projection - point
	
	func shear(x_shear: float, y_shear: float):
		for i in range(points.size()):
			var point = points[i]
			points[i] = Vector2(
				point.x + y_shear * point.y,
				point.y + x_shear * point.x
			)
	
	func get_center() -> Vector2:
		if points.size() == 0:
			return Vector2(0, 0)
		
		var sum = Vector2(0, 0)
		for point in points:
			sum += point
		
		return sum / points.size()
	
	func get_bounding_box() -> Rect2:
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
		
		return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)
	
	func connect_to(shape_id: String):
		if not shape_id in connected_shapes:
			connected_shapes.append(shape_id)
	
	func disconnect_from(shape_id: String):
		connected_shapes.erase(shape_id)
	
	func serialize() -> Dictionary:
		var serialized_points = []
		for point in points:
			serialized_points.append({"x": point.x, "y": point.y})
		
		return {
			"id": id,
			"type": type,
			"points": serialized_points,
			"color": color.to_html(),
			"dimension": dimension,
			"properties": properties,
			"connected_shapes": connected_shapes,
			"creation_time": creation_time,
			"zone_id": zone_id,
			"metadata": metadata
		}
	
	static func deserialize(data: Dictionary) -> Shape2D:
		var deserialized_points = []
		for point_data in data.points:
			deserialized_points.append(Vector2(point_data.x, point_data.y))
		
		var shape = Shape2D.new(
			data.id,
			data.type,
			deserialized_points,
			Color.from_html(data.color),
			data.dimension
		)
		
		shape.properties = data.properties
		shape.connected_shapes = data.connected_shapes
		shape.creation_time = data.creation_time
		shape.zone_id = data.zone_id
		shape.metadata = data.metadata
		
		return shape

# Zone class - represents a collection of shapes in a specific area
class Zone2D:
	var id: String
	var name: String
	var boundaries: Rect2
	var shapes: Array = []  # Array of shape IDs
	var color: Color
	var dimension: int
	var properties: Dictionary = {}
	var creation_time: int
	var connected_zones: Array = []
	var metadata: Dictionary = {}
	
	func _init(p_id: String, p_name: String, p_boundaries: Rect2, p_color: Color, p_dimension: int):
		id = p_id
		name = p_name
		boundaries = p_boundaries
		color = p_color
		dimension = p_dimension
		creation_time = Time.get_unix_time_from_system()
	
	func add_shape(shape_id: String):
		if not shape_id in shapes:
			shapes.append(shape_id)
	
	func remove_shape(shape_id: String):
		shapes.erase(shape_id)
	
	func expand_boundaries(expansion: Vector2):
		boundaries = Rect2(
			boundaries.position - expansion/2,
			boundaries.size + expansion
		)
	
	func connect_to(zone_id: String):
		if not zone_id in connected_zones:
			connected_zones.append(zone_id)
	
	func disconnect_from(zone_id: String):
		connected_zones.erase(zone_id)
	
	func contains_point(point: Vector2) -> bool:
		return boundaries.has_point(point)
	
	func serialize() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"boundaries": {
				"x": boundaries.position.x,
				"y": boundaries.position.y,
				"width": boundaries.size.x,
				"height": boundaries.size.y
			},
			"shapes": shapes,
			"color": color.to_html(),
			"dimension": dimension,
			"properties": properties,
			"creation_time": creation_time,
			"connected_zones": connected_zones,
			"metadata": metadata
		}
	
	static func deserialize(data: Dictionary) -> Zone2D:
		var boundaries_rect = Rect2(
			data.boundaries.x,
			data.boundaries.y,
			data.boundaries.width,
			data.boundaries.height
		)
		
		var zone = Zone2D.new(
			data.id,
			data.name,
			boundaries_rect,
			Color.from_html(data.color),
			data.dimension
		)
		
		zone.shapes = data.shapes
		zone.properties = data.properties
		zone.creation_time = data.creation_time
		zone.connected_zones = data.connected_zones
		zone.metadata = data.metadata
		
		return zone

# Point class - represents a specific 2D point with properties
class Point2D:
	var id: String
	var position: Vector2
	var color: Color
	var dimension: int
	var properties: Dictionary = {}
	var creation_time: int
	var connected_points: Array = []
	var metadata: Dictionary = {}
	
	func _init(p_id: String, p_position: Vector2, p_color: Color, p_dimension: int):
		id = p_id
		position = p_position
		color = p_color
		dimension = p_dimension
		creation_time = Time.get_unix_time_from_system()
	
	func connect_to(point_id: String):
		if not point_id in connected_points:
			connected_points.append(point_id)
	
	func disconnect_from(point_id: String):
		connected_points.erase(point_id)
	
	func distance_to(other_position: Vector2) -> float:
		return position.distance_to(other_position)
	
	func serialize() -> Dictionary:
		return {
			"id": id,
			"position": {"x": position.x, "y": position.y},
			"color": color.to_html(),
			"dimension": dimension,
			"properties": properties,
			"creation_time": creation_time,
			"connected_points": connected_points,
			"metadata": metadata
		}
	
	static func deserialize(data: Dictionary) -> Point2D:
		var point = Point2D.new(
			data.id,
			Vector2(data.position.x, data.position.y),
			Color.from_html(data.color),
			data.dimension
		)
		
		point.properties = data.properties
		point.creation_time = data.creation_time
		point.connected_points = data.connected_points
		point.metadata = data.metadata
		
		return point

# Shape registry
var shapes = {}  # id -> Shape2D
var zones = {}   # id -> Zone2D
var points = {}  # id -> Point2D

# Counter for generating IDs
var shape_id_counter = 0
var zone_id_counter = 0
var point_id_counter = 0

# Reference to other systems
var dimensional_color_system: DimensionalColorSystem
var turn_cycle_manager: TurnCycleManager

func _ready():
	# Try to get references to other systems
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	if not dimensional_color_system:
		dimensional_color_system = DimensionalColorSystem.new()
		add_child(dimensional_color_system)
	
	turn_cycle_manager = get_node_or_null("/root/TurnCycleManager")
	
	# Load saved data
	_load_data()

func create_shape(type: int, initial_points: Array, dimension: int = 1) -> String:
	var shape_id = "shape_" + str(shape_id_counter)
	shape_id_counter += 1
	
	# Get color for the shape based on dimension
	var color = Color.WHITE
	if dimensional_color_system:
		var dim_color = dimensional_color_system.get_color_for_dimension(dimension)
		color = dimensional_color_system.get_color_value(dim_color)
	
	var shape = Shape2D.new(shape_id, type, initial_points, color, dimension)
	shapes[shape_id] = shape
	
	emit_signal("shape_created", shape_id, type)
	_save_data()
	
	return shape_id

func create_standard_shape(type: int, center: Vector2, size: float, dimension: int = 1) -> String:
	var points = []
	
	match type:
		ShapeType.POINT:
			points = [center]
		
		ShapeType.LINE:
			points = [
				center + Vector2(-size/2, 0),
				center + Vector2(size/2, 0)
			]
		
		ShapeType.TRIANGLE:
			points = [
				center + Vector2(0, -size/2),
				center + Vector2(-size/2, size/2),
				center + Vector2(size/2, size/2)
			]
		
		ShapeType.SQUARE:
			points = [
				center + Vector2(-size/2, -size/2),
				center + Vector2(size/2, -size/2),
				center + Vector2(size/2, size/2),
				center + Vector2(-size/2, size/2)
			]
		
		ShapeType.PENTAGON:
			for i in range(5):
				var angle = 2 * PI * i / 5 - PI/2
				points.append(center + Vector2(cos(angle), sin(angle)) * size/2)
		
		ShapeType.HEXAGON:
			for i in range(6):
				var angle = 2 * PI * i / 6
				points.append(center + Vector2(cos(angle), sin(angle)) * size/2)
		
		ShapeType.CIRCLE:
			# Approximate with 16 points
			for i in range(16):
				var angle = 2 * PI * i / 16
				points.append(center + Vector2(cos(angle), sin(angle)) * size/2)
		
		ShapeType.STAR:
			for i in range(5):
				var outer_angle = 2 * PI * i / 5 - PI/2
				var inner_angle = outer_angle + PI/5
				points.append(center + Vector2(cos(outer_angle), sin(outer_angle)) * size/2)
				points.append(center + Vector2(cos(inner_angle), sin(inner_angle)) * size/4)
	
	return create_shape(type, points, dimension)

func transform_shape(shape_id: String, transformation_type: int, params: Dictionary) -> bool:
	if not shapes.has(shape_id):
		return false
	
	var shape = shapes[shape_id]
	
	match transformation_type:
		TransformationType.TRANSLATE:
			if params.has("offset"):
				shape.translate(params.offset)
		
		TransformationType.ROTATE:
			if params.has("angle_degrees"):
				var center = params.get("center", shape.get_center())
				var angle_rad = deg_to_rad(params.angle_degrees)
				shape.rotate(center, angle_rad)
		
		TransformationType.SCALE:
			if params.has("scale_factor"):
				var center = params.get("center", shape.get_center())
				var scale_factor = params.scale_factor
				if typeof(scale_factor) == TYPE_FLOAT or typeof(scale_factor) == TYPE_INT:
					scale_factor = Vector2(scale_factor, scale_factor)
				shape.scale(center, scale_factor)
		
		TransformationType.REFLECT:
			if params.has("axis"):
				shape.reflect(params.axis)
		
		TransformationType.SHEAR:
			if params.has("x_shear") or params.has("y_shear"):
				var x_shear = params.get("x_shear", 0.0)
				var y_shear = params.get("y_shear", 0.0)
				shape.shear(x_shear, y_shear)
		
		TransformationType.MORPH:
			if params.has("target_shape_id") and params.has("factor"):
				var target_shape_id = params.target_shape_id
				var factor = params.factor
				
				if shapes.has(target_shape_id):
					var target_shape = shapes[target_shape_id]
					if shape.points.size() == target_shape.points.size():
						for i in range(shape.points.size()):
							shape.points[i] = shape.points[i].lerp(target_shape.points[i], factor)
					else:
						return false
				else:
					return false
	
	emit_signal("shape_transformed", shape_id, transformation_type)
	_save_data()
	
	return true

func create_zone(name: String, boundaries: Rect2, dimension: int = 1) -> String:
	var zone_id = "zone_" + str(zone_id_counter)
	zone_id_counter += 1
	
	# Get color for the zone based on dimension
	var color = Color.WHITE
	if dimensional_color_system:
		var dim_color = dimensional_color_system.get_color_for_dimension(dimension)
		color = dimensional_color_system.get_color_value(dim_color)
	
	var zone = Zone2D.new(zone_id, name, boundaries, color, dimension)
	zones[zone_id] = zone
	
	emit_signal("zone_created", zone_id, {"name": name, "dimension": dimension})
	_save_data()
	
	return zone_id

func add_shape_to_zone(shape_id: String, zone_id: String) -> bool:
	if not shapes.has(shape_id) or not zones.has(zone_id):
		return false
	
	var shape = shapes[shape_id]
	var zone = zones[zone_id]
	
	zone.add_shape(shape_id)
	shape.zone_id = zone_id
	
	_save_data()
	return true

func remove_shape_from_zone(shape_id: String, zone_id: String) -> bool:
	if not shapes.has(shape_id) or not zones.has(zone_id):
		return false
	
	var shape = shapes[shape_id]
	var zone = zones[zone_id]
	
	zone.remove_shape(shape_id)
	if shape.zone_id == zone_id:
		shape.zone_id = ""
	
	_save_data()
	return true

func create_point(position: Vector2, dimension: int = 1) -> String:
	var point_id = "point_" + str(point_id_counter)
	point_id_counter += 1
	
	# Get color for the point based on dimension
	var color = Color.WHITE
	if dimensional_color_system:
		var dim_color = dimensional_color_system.get_color_for_dimension(dimension)
		color = dimensional_color_system.get_color_value(dim_color)
	
	var point = Point2D.new(point_id, position, color, dimension)
	points[point_id] = point
	
	emit_signal("point_created", point_id, {"x": position.x, "y": position.y})
	_save_data()
	
	return point_id

func connect_points(point_id1: String, point_id2: String) -> bool:
	if not points.has(point_id1) or not points.has(point_id2):
		return false
	
	points[point_id1].connect_to(point_id2)
	points[point_id2].connect_to(point_id1)
	
	_save_data()
	return true

func connect_shapes(shape_id1: String, shape_id2: String) -> bool:
	if not shapes.has(shape_id1) or not shapes.has(shape_id2):
		return false
	
	shapes[shape_id1].connect_to(shape_id2)
	shapes[shape_id2].connect_to(shape_id1)
	
	_save_data()
	return true

func connect_zones(zone_id1: String, zone_id2: String) -> bool:
	if not zones.has(zone_id1) or not zones.has(zone_id2):
		return false
	
	zones[zone_id1].connect_to(zone_id2)
	zones[zone_id2].connect_to(zone_id1)
	
	_save_data()
	return true

func merge_shapes(shape_id1: String, shape_id2: String, new_type: int = -1) -> String:
	if not shapes.has(shape_id1) or not shapes.has(shape_id2):
		return ""
	
	var shape1 = shapes[shape_id1]
	var shape2 = shapes[shape_id2]
	
	# Use specified type or the type of the first shape
	if new_type == -1:
		new_type = shape1.type
	
	# Create a new shape with combined points
	var combined_points = []
	combined_points.append_array(shape1.points)
	combined_points.append_array(shape2.points)
	
	# Get average dimension for the new shape
	var avg_dimension = int((shape1.dimension + shape2.dimension) / 2)
	
	var new_shape_id = create_shape(new_type, combined_points, avg_dimension)
	var new_shape = shapes[new_shape_id]
	
	# Connect to all shapes connected to either original shape
	for connected_id in shape1.connected_shapes:
		if connected_id != shape_id2 and connected_id != new_shape_id:
			new_shape.connect_to(connected_id)
			if shapes.has(connected_id):
				shapes[connected_id].connect_to(new_shape_id)
				shapes[connected_id].disconnect_from(shape_id1)
	
	for connected_id in shape2.connected_shapes:
		if connected_id != shape_id1 and connected_id != new_shape_id:
			new_shape.connect_to(connected_id)
			if shapes.has(connected_id):
				shapes[connected_id].connect_to(new_shape_id)
				shapes[connected_id].disconnect_from(shape_id2)
	
	# Copy combined properties
	for key in shape1.properties:
		new_shape.properties[key] = shape1.properties[key]
	
	for key in shape2.properties:
		if not new_shape.properties.has(key):
			new_shape.properties[key] = shape2.properties[key]
		else:
			# For duplicate keys, try to merge values
			var val1 = new_shape.properties[key]
			var val2 = shape2.properties[key]
			
			if typeof(val1) == TYPE_INT or typeof(val1) == TYPE_FLOAT:
				if typeof(val2) == TYPE_INT or typeof(val2) == TYPE_FLOAT:
					new_shape.properties[key] = (val1 + val2) / 2
			elif typeof(val1) == TYPE_STRING:
				if typeof(val2) == TYPE_STRING:
					new_shape.properties[key] = val1 + " " + val2
	
	# Remove the original shapes
	shapes.erase(shape_id1)
	shapes.erase(shape_id2)
	
	emit_signal("shape_merged", shape_id1, shape_id2, new_shape_id)
	_save_data()
	
	return new_shape_id

func get_shapes_in_zone(zone_id: String) -> Array:
	if not zones.has(zone_id):
		return []
	
	var zone = zones[zone_id]
	return zone.shapes

func get_shapes_in_rect(rect: Rect2, dimension: int = -1) -> Array:
	var result = []
	
	for shape_id in shapes:
		var shape = shapes[shape_id]
		
		if dimension >= 0 and shape.dimension != dimension:
			continue
		
		var shape_rect = shape.get_bounding_box()
		if rect.intersects(shape_rect):
			result.append(shape_id)
	
	return result

func get_points_in_radius(center: Vector2, radius: float, dimension: int = -1) -> Array:
	var result = []
	
	for point_id in points:
		var point = points[point_id]
		
		if dimension >= 0 and point.dimension != dimension:
			continue
		
		if point.position.distance_to(center) <= radius:
			result.append(point_id)
	
	return result

func match_shape_to_template(shape_id: String, template_type: int, tolerance: float = 10.0) -> float:
	if not shapes.has(shape_id):
		return 0.0
	
	var shape = shapes[shape_id]
	
	# Create a normalized template shape
	var center = Vector2(0, 0)
	var template_id = create_standard_shape(template_type, center, 1.0)
	var template = shapes[template_id]
	
	# Ensure both shapes have the same number of points
	if template.points.size() != shape.points.size():
		shapes.erase(template_id)
		return 0.0
	
	# Center and normalize the test shape
	var shape_center = shape.get_center()
	var normalized_points = []
	
	for point in shape.points:
		normalized_points.append(point - shape_center)
	
	# Find max distance from center to normalize
	var max_distance = 0.0
	for point in normalized_points:
		max_distance = max(max_distance, point.length())
	
	if max_distance > 0:
		for i in range(normalized_points.size()):
			normalized_points[i] = normalized_points[i] / max_distance
	
	# Calculate similarity score
	var total_distance = 0.0
	for i in range(template.points.size()):
		var template_point = template.points[i]
		var shape_point = normalized_points[i]
		total_distance += template_point.distance_to(shape_point)
	
	var avg_distance = total_distance / template.points.size()
	var similarity = 1.0 - min(avg_distance / tolerance, 1.0)
	
	# Clean up template
	shapes.erase(template_id)
	
	return similarity

func _load_data():
	if FileAccess.file_exists("user://eden_shapes.save"):
		var file = FileAccess.open("user://eden_shapes.save", FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			
			shape_id_counter = data.shape_id_counter
			zone_id_counter = data.zone_id_counter
			point_id_counter = data.point_id_counter
			
			# Load shapes
			shapes.clear()
			for shape_data in data.shapes:
				var shape = Shape2D.deserialize(shape_data)
				shapes[shape.id] = shape
			
			# Load zones
			zones.clear()
			for zone_data in data.zones:
				var zone = Zone2D.deserialize(zone_data)
				zones[zone.id] = zone
			
			# Load points
			points.clear()
			for point_data in data.points:
				var point = Point2D.deserialize(point_data)
				points[point.id] = point

func _save_data():
	var serialized_shapes = []
	for shape_id in shapes:
		serialized_shapes.append(shapes[shape_id].serialize())
	
	var serialized_zones = []
	for zone_id in zones:
		serialized_zones.append(zones[zone_id].serialize())
	
	var serialized_points = []
	for point_id in points:
		serialized_points.append(points[point_id].serialize())
	
	var data = {
		"shape_id_counter": shape_id_counter,
		"zone_id_counter": zone_id_counter,
		"point_id_counter": point_id_counter,
		"shapes": serialized_shapes,
		"zones": serialized_zones,
		"points": serialized_points
	}
	
	var json_string = JSON.stringify(data)
	var file = FileAccess.open("user://eden_shapes.save", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()