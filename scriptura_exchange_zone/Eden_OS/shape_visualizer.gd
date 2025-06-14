extends Node2D

class_name ShapeVisualizer

# Rendering options
var show_shapes: bool = true
var show_zones: bool = true
var show_points: bool = true
var show_connections: bool = true
var show_labels: bool = true
var shape_opacity: float = 0.7
var zone_opacity: float = 0.3
var point_size: float = 5.0
var line_width: float = 2.0
var connection_width: float = 1.0
var font_size: int = 14
var zoom_level: float = 1.0
var view_offset: Vector2 = Vector2.ZERO
var active_dimension: int = 1  # Current dimension being visualized

# References to other systems
var shape_system: ShapeSystem
var dimensional_color_system: DimensionalColorSystem

# Selected entities for interaction
var selected_shape_id: String = ""
var selected_zone_id: String = ""
var selected_point_id: String = ""

# UI Font
var font: Font

func _ready():
	# Setup font
	font = FontFile.new()
	
	# Try to get references to other systems
	shape_system = get_node_or_null("/root/ShapeSystem")
	if not shape_system:
		shape_system = ShapeSystem.new()
		get_node("/root").add_child(shape_system)
	
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	if not dimensional_color_system:
		dimensional_color_system = DimensionalColorSystem.new()
		get_node("/root").add_child(dimensional_color_system)
	
	# Connect signals
	shape_system.shape_created.connect(_on_shape_created)
	shape_system.shape_transformed.connect(_on_shape_transformed)
	shape_system.shape_merged.connect(_on_shape_merged)
	shape_system.zone_created.connect(_on_zone_created)
	shape_system.point_created.connect(_on_point_created)

func _draw():
	if not shape_system:
		return
	
	# Apply zoom and offset to the canvas
	var transform = Transform2D()
	transform = transform.scaled(Vector2(zoom_level, zoom_level))
	transform = transform.translated(view_offset)
	draw_set_transform_matrix(transform)
	
	# Draw zones
	if show_zones:
		for zone_id in shape_system.zones:
			var zone = shape_system.zones[zone_id]
			
			# Only draw zones in the active dimension
			if zone.dimension != active_dimension:
				continue
			
			var zone_color = zone.color
			zone_color.a = zone_opacity
			
			# Draw the zone rectangle
			draw_rect(zone.boundaries, zone_color, true)
			
			# Draw outline with slightly darker color
			var outline_color = zone.color
			outline_color.a = zone_opacity * 1.5
			draw_rect(zone.boundaries, outline_color, false, line_width)
			
			# Draw label if enabled
			if show_labels:
				var label_pos = zone.boundaries.position + Vector2(10, 20)
				draw_string(font, label_pos, zone.name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	
	# Draw shape connections
	if show_connections:
		for shape_id in shape_system.shapes:
			var shape = shape_system.shapes[shape_id]
			
			# Only draw shapes in the active dimension
			if shape.dimension != active_dimension:
				continue
			
			for connected_id in shape.connected_shapes:
				if shape_system.shapes.has(connected_id):
					var connected_shape = shape_system.shapes[connected_id]
					
					# Only draw connections to shapes in the active dimension
					if connected_shape.dimension != active_dimension:
						continue
					
					var start = shape.get_center()
					var end = connected_shape.get_center()
					
					# Draw connection line
					var connection_color = shape.color.lerp(connected_shape.color, 0.5)
					connection_color.a = 0.5
					draw_line(start, end, connection_color, connection_width)
	
	# Draw shapes
	if show_shapes:
		for shape_id in shape_system.shapes:
			var shape = shape_system.shapes[shape_id]
			
			# Only draw shapes in the active dimension
			if shape.dimension != active_dimension:
				continue
			
			var points = shape.points
			if points.size() < 2:
				continue
			
			var shape_color = shape.color
			shape_color.a = shape_opacity
			
			# Draw the shape based on its type
			match shape.type:
				ShapeSystem.ShapeType.POINT:
					# Single point
					if points.size() > 0:
						draw_circle(points[0], point_size, shape_color)
				
				ShapeSystem.ShapeType.LINE:
					# Line between two points
					if points.size() >= 2:
						draw_line(points[0], points[1], shape_color, line_width)
				
				ShapeSystem.ShapeType.CIRCLE:
					# Circle - calculate center and radius
					var center = shape.get_center()
					var radius = 0.0
					for point in points:
						radius = max(radius, point.distance_to(center))
					draw_circle(center, radius, shape_color)
					draw_arc(center, radius, 0, TAU, 32, shape_color, line_width, true)
				
				ShapeSystem.ShapeType.ELLIPSE:
					# Ellipse - calculate bounding box
					var rect = shape.get_bounding_box()
					draw_ellipse(rect.position + rect.size/2, rect.size/2, shape_color)
				
				_:
					# Default: draw as polygon
					var polygon_points = PackedVector2Array(points)
					draw_polygon(polygon_points, PackedColorArray([shape_color]))
					
					# Draw outline
					for i in range(points.size()):
						var start = points[i]
						var end = points[(i + 1) % points.size()]
						draw_line(start, end, shape_color, line_width)
			
			# Draw label if enabled
			if show_labels:
				var center = shape.get_center()
				var label = ShapeSystem.ShapeType.keys()[shape.type]
				if shape.properties.has("name"):
					label = shape.properties.name
				draw_string(font, center, label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)
	
	# Draw points
	if show_points:
		for point_id in shape_system.points:
			var point = shape_system.points[point_id]
			
			# Only draw points in the active dimension
			if point.dimension != active_dimension:
				continue
			
			var point_color = point.color
			point_color.a = 1.0
			
			# Draw the point
			draw_circle(point.position, point_size, point_color)
			
			# Draw connections between points
			if show_connections:
				for connected_id in point.connected_points:
					if shape_system.points.has(connected_id):
						var connected_point = shape_system.points[connected_id]
						
						# Only draw connections to points in the active dimension
						if connected_point.dimension != active_dimension:
							continue
						
						var start = point.position
						var end = connected_point.position
						
						# Draw connection line
						var connection_color = point.color.lerp(connected_point.color, 0.5)
						connection_color.a = 0.5
						draw_line(start, end, connection_color, connection_width)
			
			# Draw label if enabled
			if show_labels and point.properties.has("name"):
				var label_pos = point.position + Vector2(0, -15)
				draw_string(font, label_pos, point.properties.name, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)
	
	# Draw selection indicators
	if selected_shape_id != "" and shape_system.shapes.has(selected_shape_id):
		var shape = shape_system.shapes[selected_shape_id]
		if shape.dimension == active_dimension:
			var center = shape.get_center()
			var radius = 10.0
			
			# Draw selection circle
			draw_arc(center, radius, 0, TAU, 32, Color.WHITE, 2.0, true)
	
	if selected_zone_id != "" and shape_system.zones.has(selected_zone_id):
		var zone = shape_system.zones[selected_zone_id]
		if zone.dimension == active_dimension:
			# Draw selection outline
			draw_rect(zone.boundaries, Color.WHITE, false, 2.0)
	
	if selected_point_id != "" and shape_system.points.has(selected_point_id):
		var point = shape_system.points[selected_point_id]
		if point.dimension == active_dimension:
			# Draw selection circle
			draw_arc(point.position, point_size + 5, 0, TAU, 16, Color.WHITE, 2.0, true)

func set_active_dimension(dimension: int):
	active_dimension = dimension
	queue_redraw()

func zoom_in():
	zoom_level *= 1.2
	queue_redraw()

func zoom_out():
	zoom_level /= 1.2
	queue_redraw()

func reset_view():
	zoom_level = 1.0
	view_offset = Vector2.ZERO
	queue_redraw()

func pan_view(offset: Vector2):
	view_offset += offset / zoom_level
	queue_redraw()

func select_shape_at(position: Vector2) -> String:
	var closest_shape_id = ""
	var closest_distance = 9999999.0
	
	position = (position - view_offset) / zoom_level
	
	for shape_id in shape_system.shapes:
		var shape = shape_system.shapes[shape_id]
		
		# Only select shapes in the active dimension
		if shape.dimension != active_dimension:
			continue
		
		var center = shape.get_center()
		var distance = position.distance_to(center)
		
		if distance < closest_distance and is_position_inside_shape(position, shape):
			closest_distance = distance
			closest_shape_id = shape_id
	
	selected_shape_id = closest_shape_id
	selected_zone_id = ""
	selected_point_id = ""
	queue_redraw()
	
	return closest_shape_id

func select_zone_at(position: Vector2) -> String:
	position = (position - view_offset) / zoom_level
	
	for zone_id in shape_system.zones:
		var zone = shape_system.zones[zone_id]
		
		# Only select zones in the active dimension
		if zone.dimension != active_dimension:
			continue
		
		if zone.contains_point(position):
			selected_zone_id = zone_id
			selected_shape_id = ""
			selected_point_id = ""
			queue_redraw()
			return zone_id
	
	return ""

func select_point_at(position: Vector2) -> String:
	var closest_point_id = ""
	var closest_distance = 999999.0
	
	position = (position - view_offset) / zoom_level
	
	for point_id in shape_system.points:
		var point = shape_system.points[point_id]
		
		# Only select points in the active dimension
		if point.dimension != active_dimension:
			continue
		
		var distance = position.distance_to(point.position)
		if distance < closest_distance and distance <= point_size * 2:
			closest_distance = distance
			closest_point_id = point_id
	
	selected_point_id = closest_point_id
	selected_shape_id = ""
	selected_zone_id = ""
	queue_redraw()
	
	return closest_point_id

func is_position_inside_shape(position: Vector2, shape) -> bool:
	if shape.points.size() <= 2:
		# For points and lines, check distance to points or line
		if shape.type == ShapeSystem.ShapeType.POINT:
			return position.distance_to(shape.points[0]) <= point_size * 2
		elif shape.type == ShapeSystem.ShapeType.LINE:
			return is_point_near_line(position, shape.points[0], shape.points[1], line_width * 2)
	elif shape.type == ShapeSystem.ShapeType.CIRCLE:
		# For circles, check distance to center
		var center = shape.get_center()
		var radius = 0.0
		for point in shape.points:
			radius = max(radius, point.distance_to(center))
		return position.distance_to(center) <= radius
	else:
		# For polygons, use point_in_polygon
		return Geometry2D.is_point_in_polygon(position, PackedVector2Array(shape.points))

func is_point_near_line(point: Vector2, line_start: Vector2, line_end: Vector2, max_distance: float) -> bool:
	var line_vec = line_end - line_start
	var point_vec = point - line_start
	var line_length = line_vec.length()
	
	if line_length == 0:
		return point.distance_to(line_start) <= max_distance
	
	var t = point_vec.dot(line_vec) / (line_length * line_length)
	
	if t < 0:
		return point.distance_to(line_start) <= max_distance
	elif t > 1:
		return point.distance_to(line_end) <= max_distance
	
	var projection = line_start + t * line_vec
	return point.distance_to(projection) <= max_distance

func _on_shape_created(shape_id, shape_type):
	queue_redraw()

func _on_shape_transformed(shape_id, transformation_type):
	queue_redraw()

func _on_shape_merged(shape_id1, shape_id2, new_shape_id):
	queue_redraw()
	
	# If one of the merged shapes was selected, select the new one
	if shape_id1 == selected_shape_id or shape_id2 == selected_shape_id:
		selected_shape_id = new_shape_id

func _on_zone_created(zone_id, zone_properties):
	queue_redraw()

func _on_point_created(point_id, coordinates):
	queue_redraw()