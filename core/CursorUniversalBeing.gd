# ==================================================
# SCRIPT NAME: CursorUniversalBeing.gd
# DESCRIPTION: Universal Being cursor for 2D/3D interaction
# PURPOSE: Triangle cursor with sphere collision for precise interaction
# CREATED: 2025-06-01 - Universal Being Revolution
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends UniversalBeing
class_name CursorUniversalBeing

# ===== CURSOR UNIVERSAL BEING =====

## Cursor Properties
var cursor_shape: Node2D = null
var interaction_sphere: Area3D = null
var cursor_tip_position: Vector2 = Vector2.ZERO

## Interaction State
var is_hovering: bool = false
var hovered_object: Node = null
var is_clicking: bool = false

# ===== SIGNALS =====

signal cursor_hover_started(object: Node)
signal cursor_hover_ended(object: Node)
signal cursor_clicked(object: Node, position: Vector2)
signal cursor_dragging(object: Node, delta_position: Vector2)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	# Call parent init
	super()
	
	# Set cursor-specific properties
	being_type = "cursor"
	consciousness_level = 4  # High consciousness for precise interaction
	being_name = "Universal Cursor"
	
	print("🎯 CursorUniversalBeing: Pentagon cursor initialization")

func pentagon_ready() -> void:
	# Call parent ready
	super()
	
	# Create cursor visual
	create_cursor_triangle()
	
	# Create interaction sphere
	create_interaction_sphere()
	
	# Hide system cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func pentagon_process(delta: float) -> void:
	# Call parent process
	super(delta)
	
	# Update cursor position
	update_cursor_position()
	
	# Process interactions
	process_cursor_interactions(delta)

func pentagon_input(event: InputEvent) -> void:
	# Call parent input
	super(event)
	
	# Handle cursor-specific input
	process_cursor_input(event)

func pentagon_sewers() -> void:
	# Restore system cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Call parent cleanup
	super()

# ===== CURSOR CREATION =====

func create_cursor_triangle() -> void:
	"""Create triangle cursor shape positioned like Windows cursor"""
	cursor_shape = Node2D.new()
	cursor_shape.name = "CursorTriangle"
	cursor_shape.z_index = 1000  # Render above all UI
	add_child(cursor_shape)
	
	# Create triangle points (tip matches Windows cursor tip position)
	var triangle_points = PackedVector2Array([
		Vector2(0, 0),      # Top tip (interaction point) - matches Windows cursor
		Vector2(-4, 12),    # Bottom left (smaller triangle)
		Vector2(3, 8)       # Bottom right (asymmetric like Windows cursor)
	])
	
	# Create triangle polygon
	var polygon = Polygon2D.new()
	polygon.polygon = triangle_points
	polygon.color = Color.CYAN
	cursor_shape.add_child(polygon)
	
	# Add outline for visibility
	var line = Line2D.new()
	line.add_point(Vector2(0, 0))
	line.add_point(Vector2(-4, 12))
	line.add_point(Vector2(3, 8))
	line.add_point(Vector2(0, 0))
	line.width = 1
	line.default_color = Color.WHITE
	cursor_shape.add_child(line)
	
	# Set tip position for precise interaction (Windows cursor tip)
	cursor_tip_position = Vector2(0, 0)
	
	print("🎯 Cursor: Windows-style triangle created")

func create_interaction_sphere() -> void:
	"""Create tiny 3D interaction sphere at cursor tip"""
	interaction_sphere = Area3D.new()
	interaction_sphere.name = "InteractionSphere"
	add_child(interaction_sphere)
	
	# Create tiny sphere collision shape - same size as visual
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.02  # Very small for precise interaction
	collision_shape.shape = sphere_shape
	interaction_sphere.add_child(collision_shape)
	
	# Create tiny visual sphere
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.02  # Same as collision
	sphere_mesh.height = 0.04  # Diameter = 2 * radius
	mesh_instance.mesh = sphere_mesh
	
	# Make it glow subtly
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.CYAN
	material.emission = Color.CYAN
	material.emission_energy = 0.3
	material.flags_transparent = true
	material.albedo_color.a = 0.7  # Semi-transparent
	mesh_instance.material_override = material
	
	interaction_sphere.add_child(mesh_instance)
	
	# Connect interaction signals
	interaction_sphere.area_entered.connect(_on_area_entered)
	interaction_sphere.area_exited.connect(_on_area_exited)
	interaction_sphere.body_entered.connect(_on_body_entered)
	interaction_sphere.body_exited.connect(_on_body_exited)
	
	print("🎯 Cursor: Tiny precision sphere created")

# ===== CURSOR BEHAVIOR =====

func update_cursor_position() -> void:
	"""Update cursor position to follow mouse"""
	if cursor_shape:
		var mouse_pos = get_viewport().get_mouse_position()
		cursor_shape.global_position = mouse_pos
		
		# Update 3D sphere position (project to 3D space)
		if interaction_sphere:
			var camera = get_viewport().get_camera_3d()
			if camera:
				# Project 2D mouse to 3D ray
				var ray_origin = camera.project_ray_origin(mouse_pos)
				var ray_direction = camera.project_ray_normal(mouse_pos)
				
				# Position sphere slightly forward from camera
				interaction_sphere.global_position = ray_origin + ray_direction * 2.0

func process_cursor_interactions(delta: float) -> void:
	"""Process cursor interactions with objects"""
	if is_hovering and hovered_object:
		# Update hover state
		if hovered_object.has_method("on_cursor_hover"):
			hovered_object.on_cursor_hover(cursor_tip_position)

func process_cursor_input(event: InputEvent) -> void:
	"""Process cursor-specific input"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_clicking = true
				if hovered_object:
					cursor_clicked.emit(hovered_object, cursor_tip_position)
					
					# Trigger inspector if this is a Universal Being
					trigger_inspector_for_object(hovered_object)
					
					if hovered_object.has_method("on_cursor_click"):
						hovered_object.on_cursor_click(cursor_tip_position)
			else:
				is_clicking = false
	
	elif event is InputEventMouseMotion:
		if is_clicking and hovered_object:
			cursor_dragging.emit(hovered_object, event.relative)
			if hovered_object.has_method("on_cursor_drag"):
				hovered_object.on_cursor_drag(event.relative)

func trigger_inspector_for_object(object: Node) -> void:
	"""Trigger inspector interface for clicked Universal Being"""
	# Check if object is a Universal Being or related to one
	var universal_being = find_universal_being(object)
	
	if universal_being:
		print("🎯 Cursor: Clicked Universal Being - %s" % universal_being.name)
		
		# Send inspector command to Gemma AI
		if GemmaAI and GemmaAI.has_method("show_inspection_interface"):
			GemmaAI.show_inspection_interface()
		elif GemmaAI:
			# Create inspection report
			var inspection_data = get_being_inspection_data(universal_being)
			var message = "🎯 CURSOR INSPECTION:\n"
			message += "🌟 Being: %s\n" % inspection_data.get("name", "Unknown")
			message += "🧠 Type: %s\n" % inspection_data.get("type", "unknown")
			message += "💫 Consciousness: %d\n" % inspection_data.get("consciousness", 0)
			message += "📍 Position: %s\n" % str(universal_being.global_position)
			
			if GemmaAI.has_method("ai_message"):
				GemmaAI.ai_message.emit(message)

func find_universal_being(node: Node) -> Node:
	"""Find Universal Being from clicked node"""
	var current = node
	
	# Traverse up the tree to find a Universal Being
	while current:
		if current.has_method("get") and current.has_method("pentagon_init"):
			# This looks like a Universal Being
			return current
		elif current.name.contains("Universal Being") or current.name.contains("Being"):
			return current
		
		current = current.get_parent()
	
	return null

func get_being_inspection_data(being: Node) -> Dictionary:
	"""Get inspection data for a Universal Being"""
	var data = {}
	
	if being.has_method("get"):
		data["name"] = being.get("being_name") if being.has_method("get") else being.name
		data["type"] = being.get("being_type") if being.has_method("get") else "unknown"
		data["consciousness"] = being.get("consciousness_level") if being.has_method("get") else 0
	else:
		data["name"] = being.name
		data["type"] = "scene_object"
		data["consciousness"] = 0
	
	return data

# ===== INTERACTION CALLBACKS =====

func _on_area_entered(area: Area3D) -> void:
	"""Handle area entered by cursor sphere"""
	if not is_hovering:
		is_hovering = true
		hovered_object = area
		cursor_hover_started.emit(area)
		print("🎯 Cursor: Hovering over area - %s" % area.name)

func _on_area_exited(area: Area3D) -> void:
	"""Handle area exited by cursor sphere"""
	if is_hovering and hovered_object == area:
		is_hovering = false
		cursor_hover_ended.emit(area)
		hovered_object = null
		print("🎯 Cursor: Stopped hovering over area - %s" % area.name)

func _on_body_entered(body: Node3D) -> void:
	"""Handle body entered by cursor sphere"""
	if not is_hovering:
		is_hovering = true
		hovered_object = body
		cursor_hover_started.emit(body)
		print("🎯 Cursor: Hovering over body - %s" % body.name)

func _on_body_exited(body: Node3D) -> void:
	"""Handle body exited by cursor sphere"""
	if is_hovering and hovered_object == body:
		is_hovering = false
		cursor_hover_ended.emit(body)
		hovered_object = null
		print("🎯 Cursor: Stopped hovering over body - %s" % body.name)

# ===== CURSOR UTILITIES =====

func get_cursor_tip_world_position() -> Vector3:
	"""Get the world position of cursor tip in 3D space"""
	if interaction_sphere:
		return interaction_sphere.global_position
	return Vector3.ZERO

func set_cursor_visibility(visible: bool) -> void:
	"""Set cursor visibility"""
	if cursor_shape:
		cursor_shape.visible = visible

func set_cursor_color(color: Color) -> void:
	"""Set cursor color"""
	if cursor_shape:
		var polygon = cursor_shape.get_child(0)
		if polygon is Polygon2D:
			polygon.color = color

# ===== DEBUG FUNCTIONS =====

func get_cursor_info() -> Dictionary:
	"""Get cursor information for debugging"""
	return {
		"is_hovering": is_hovering,
		"hovered_object": hovered_object.name if hovered_object else "none",
		"is_clicking": is_clicking,
		"tip_position": cursor_tip_position,
		"consciousness_level": consciousness_level
	}