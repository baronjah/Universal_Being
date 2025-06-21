# Debug World Layer - Divine Vision System
# JSH #memories
extends Node3D
class_name DebugWorldLayer

signal shape_recognized(entity_data: Dictionary)
signal debug_mode_changed(enabled: bool)

# Debug visualization components
var debug_enabled := false
var show_points := true
var show_lines := true
var show_shapes := true
var show_text := true
var show_states := true

# Shape recognition from points
var point_cloud := {}  # Track all entity points
var shape_templates := {}  # Pre-defined shape patterns
var recognized_shapes := {}  # Currently recognized entities

# Visual elements
var debug_draw_node: ImmediateMesh
var label_container: Node3D
var shape_container: Node3D

# Colors for different states
const STATE_COLORS = {
	"idle": Color.GRAY,
	"active": Color.GREEN,
	"interacting": Color.YELLOW,
	"transforming": Color.CYAN,
	"error": Color.RED
}

func _ready():
	print("🔍 Debug World Layer initialized - Divine vision activated")
	setup_debug_components()
	setup_shape_templates()
	
func setup_debug_components():
	# Create immediate mesh for debug drawing
	var immediate_mesh_instance = MeshInstance3D.new()
	debug_draw_node = ImmediateMesh.new()
	immediate_mesh_instance.mesh = debug_draw_node
	immediate_mesh_instance.material_override = create_debug_material()
	add_child(immediate_mesh_instance)
	
	# Containers for labels and shapes
	label_container = Node3D.new()
	label_container.name = "DebugLabels"
	add_child(label_container)
	
	shape_container = Node3D.new()
	shape_container.name = "DebugShapes"
	add_child(shape_container)

func create_debug_material() -> Material:
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func setup_shape_templates():
	# Define shape patterns from point arrangements
	shape_templates = {
		"cube": {
			"points": 8,
			"pattern": "box_corners",
			"min_distance": 0.5,
			"max_distance": 5.0
		},
		"sphere": {
			"points": 1,  # Center + radius
			"pattern": "center_radius",
			"min_distance": 0.1,
			"max_distance": 10.0
		},
		"pyramid": {
			"points": 5,
			"pattern": "pyramid_vertices",
			"min_distance": 0.5,
			"max_distance": 5.0
		},
		"screen": {
			"points": 4,
			"pattern": "flat_rectangle",
			"min_distance": 1.0,
			"max_distance": 20.0
		}
	}

func toggle_debug_mode():
	debug_enabled = !debug_enabled
	visible = debug_enabled
	debug_mode_changed.emit(debug_enabled)
	
	if debug_enabled:
		print("🔍 Debug mode ENABLED - Divine vision active")
	else:
		print("🔍 Debug mode DISABLED - Normal vision")

func add_entity_point(entity_id: String, position: Vector3, data: Dictionary):
	"""Track entity points for shape recognition"""
	if not point_cloud.has(entity_id):
		point_cloud[entity_id] = {
			"points": [],
			"data": data,
			"state": "idle",
			"direction": Vector3.FORWARD
		}
	
	point_cloud[entity_id].points.append(position)
	point_cloud[entity_id].data = data
	
	# Try to recognize shape
	recognize_shape(entity_id)

func recognize_shape(entity_id: String):
	"""Recognize shape from point pattern"""
	if not point_cloud.has(entity_id):
		return
		
	var entity_data = point_cloud[entity_id]
	var points = entity_data.points
	
	# Check against templates
	for shape_name in shape_templates:
		var template = shape_templates[shape_name]
		
		if points.size() >= template.points:
			if matches_pattern(points, template):
				recognized_shapes[entity_id] = {
					"shape": shape_name,
					"position": calculate_center(points),
					"scale": calculate_scale(points),
					"rotation": calculate_rotation(entity_data.direction),
					"state": entity_data.state
				}
				shape_recognized.emit(recognized_shapes[entity_id])
				create_debug_shape(entity_id)
				break

func matches_pattern(points: Array, template: Dictionary) -> bool:
	"""Check if points match a shape template pattern"""
	match template.pattern:
		"box_corners":
			return is_box_pattern(points)
		"center_radius":
			return points.size() >= 1
		"pyramid_vertices":
			return is_pyramid_pattern(points)
		"flat_rectangle":
			return is_flat_rectangle_pattern(points)
	return false

func is_box_pattern(points: Array) -> bool:
	"""Check if points form a box"""
	if points.size() < 8:
		return false
	# Simple check: 8 points with roughly equal distances
	var center = calculate_center(points)
	var avg_dist = 0.0
	for p in points:
		avg_dist += center.distance_to(p)
	avg_dist /= points.size()
	
	# Check if all points are roughly equidistant from center
	for p in points:
		if abs(center.distance_to(p) - avg_dist) > 0.5:
			return false
	return true

func is_pyramid_pattern(points: Array) -> bool:
	"""Check if points form a pyramid"""
	if points.size() < 5:
		return false
	# One point should be higher than the others
	var heights = []
	for p in points:
		heights.append(p.y)
	heights.sort()
	return heights[-1] - heights[0] > 1.0

func is_flat_rectangle_pattern(points: Array) -> bool:
	"""Check if points form a flat rectangle"""
	if points.size() < 4:
		return false
	# All points should be roughly on same plane
	var avg_y = 0.0
	for p in points:
		avg_y += p.y
	avg_y /= points.size()
	
	for p in points:
		if abs(p.y - avg_y) > 0.1:
			return false
	return true

func calculate_center(points: Array) -> Vector3:
	"""Calculate center of point cloud"""
	var center = Vector3.ZERO
	for p in points:
		center += p
	return center / points.size()

func calculate_scale(points: Array) -> Vector3:
	"""Calculate bounding box scale"""
	if points.is_empty():
		return Vector3.ONE
		
	var min_pos = points[0]
	var max_pos = points[0]
	
	for p in points:
		min_pos.x = min(min_pos.x, p.x)
		min_pos.y = min(min_pos.y, p.y)
		min_pos.z = min(min_pos.z, p.z)
		max_pos.x = max(max_pos.x, p.x)
		max_pos.y = max(max_pos.y, p.y)
		max_pos.z = max(max_pos.z, p.z)
	
	return max_pos - min_pos

func calculate_rotation(direction: Vector3) -> Vector3:
	"""Calculate rotation from direction vector"""
	if direction.is_zero_approx():
		return Vector3.ZERO
	
	var forward = direction.normalized()
	var up = Vector3.UP
	if abs(forward.dot(up)) > 0.99:
		up = Vector3.RIGHT
	
	var right = up.cross(forward).normalized()
	up = forward.cross(right).normalized()
	
	var basis = Basis(right, up, -forward)
	return basis.get_euler()

func create_debug_shape(entity_id: String):
	"""Create visual debug shape for recognized entity"""
	if not recognized_shapes.has(entity_id):
		return
		
	var shape_data = recognized_shapes[entity_id]
	var shape_instance = MeshInstance3D.new()
	
	# Create appropriate mesh
	match shape_data.shape:
		"cube":
			shape_instance.mesh = BoxMesh.new()
		"sphere":
			shape_instance.mesh = SphereMesh.new()
		"pyramid":
			shape_instance.mesh = CylinderMesh.new()
			shape_instance.mesh.top_radius = 0.0
		"screen":
			shape_instance.mesh = PlaneMesh.new()
	
	# Apply transform
	shape_instance.position = shape_data.position
	shape_instance.scale = shape_data.scale
	shape_instance.rotation = shape_data.rotation
	
	# Apply state color
	var mat = StandardMaterial3D.new()
	mat.albedo_color = STATE_COLORS.get(shape_data.state, Color.WHITE)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.3
	shape_instance.material_override = mat
	
	# Add to container
	shape_container.add_child(shape_instance)
	shape_instance.name = "DebugShape_" + entity_id

func update_entity_state(entity_id: String, new_state: String):
	"""Update entity state and visualization"""
	if point_cloud.has(entity_id):
		point_cloud[entity_id].state = new_state
		
	if recognized_shapes.has(entity_id):
		recognized_shapes[entity_id].state = new_state
		
		# Update visual
		var shape_node = shape_container.get_node_or_null("DebugShape_" + entity_id)
		if shape_node and shape_node.material_override:
			shape_node.material_override.albedo_color = STATE_COLORS.get(new_state, Color.WHITE)
			shape_node.material_override.albedo_color.a = 0.3

func _process(_delta):
	if not debug_enabled:
		return
		
	# Clear previous frame
	debug_draw_node.clear_surfaces()
	
	# Draw debug elements
	if show_points:
		draw_all_points()
	if show_lines:
		draw_all_connections()
	if show_text:
		update_debug_labels()

func draw_all_points():
	"""Draw all tracked points"""
	debug_draw_node.surface_begin(Mesh.PRIMITIVE_POINTS)
	
	for entity_id in point_cloud:
		var entity_data = point_cloud[entity_id]
		var color = STATE_COLORS.get(entity_data.state, Color.WHITE)
		
		for point in entity_data.points:
			debug_draw_node.surface_set_color(color)
			debug_draw_node.surface_add_vertex(point)
	
	debug_draw_node.surface_end()

func draw_all_connections():
	"""Draw connections between points"""
	debug_draw_node.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for entity_id in point_cloud:
		var entity_data = point_cloud[entity_id]
		var points = entity_data.points
		var color = STATE_COLORS.get(entity_data.state, Color.WHITE)
		color.a = 0.5
		
		# Draw connections based on recognized shape
		if recognized_shapes.has(entity_id):
			var shape = recognized_shapes[entity_id].shape
			draw_shape_connections(points, shape, color)
	
	debug_draw_node.surface_end()

func draw_shape_connections(points: Array, shape: String, color: Color):
	"""Draw lines connecting points based on shape type"""
	match shape:
		"cube":
			# Draw cube edges
			if points.size() >= 8:
				# Bottom face
				for i in range(4):
					debug_draw_node.surface_set_color(color)
					debug_draw_node.surface_add_vertex(points[i])
					debug_draw_node.surface_add_vertex(points[(i + 1) % 4])
				# Top face
				for i in range(4, 8):
					debug_draw_node.surface_set_color(color)
					debug_draw_node.surface_add_vertex(points[i])
					debug_draw_node.surface_add_vertex(points[4 + (i + 1) % 4])
				# Vertical edges
				for i in range(4):
					debug_draw_node.surface_set_color(color)
					debug_draw_node.surface_add_vertex(points[i])
					debug_draw_node.surface_add_vertex(points[i + 4])
		
		"screen":
			# Draw rectangle edges
			if points.size() >= 4:
				for i in range(4):
					debug_draw_node.surface_set_color(color)
					debug_draw_node.surface_add_vertex(points[i])
					debug_draw_node.surface_add_vertex(points[(i + 1) % 4])

func update_debug_labels():
	"""Update text labels for entities"""
	# Clear old labels
	for child in label_container.get_children():
		child.queue_free()
	
	# Create new labels
	for entity_id in recognized_shapes:
		var shape_data = recognized_shapes[entity_id]
		var label = Label3D.new()
		label.text = "%s\n%s\n%s" % [entity_id, shape_data.shape, shape_data.state]
		label.position = shape_data.position + Vector3(0, 1, 0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.modulate = STATE_COLORS.get(shape_data.state, Color.WHITE)
		label_container.add_child(label)

func clear_debug_data():
	"""Clear all debug visualization data"""
	point_cloud.clear()
	recognized_shapes.clear()
	
	for child in shape_container.get_children():
		child.queue_free()
	for child in label_container.get_children():
		child.queue_free()
	
	debug_draw_node.clear_surfaces()

# Gameplay mode support
var gameplay_mode := 0  # 0: Explorer, 1: Creator

func switch_gameplay_mode():
	gameplay_mode = (gameplay_mode + 1) % 2
	match gameplay_mode:
		0:
			print("🎮 Explorer Mode - Discover and interact")
		1:
			print("🎮 Creator Mode - Build and manifest")