# ==================================================
# SCRIPT NAME: debug_3d_screen.gd
# DESCRIPTION: 3D screen for debugging like notepad3d project
# CREATED: 2025-05-23 - Visual debug interface
# ==================================================

extends UniversalBeingBase
# Screen properties
var screen_mesh: MeshInstance3D
var screen_material: StandardMaterial3D
var screen_size: Vector2 = Vector2(10, 6)
var screen_position: Vector3 = Vector3(0, 3, -15)

# Debug display
var debug_texture: ImageTexture
var debug_image: Image
var debug_info: Dictionary = {}

# Objects being debugged
var selected_object: Node3D = null
var debug_gizmo: Node3D = null

# Colors for different object types
var object_colors: Dictionary = {
	"tree": Color.GREEN,
	"rock": Color.GRAY,
	"box": Color.BROWN,
	"ball": Color.RED,
	"ramp": Color.BLUE,
	"ragdoll": Color.YELLOW,
	"astral_being": Color.MAGENTA,
	"sun": Color.ORANGE
}

func _ready() -> void:
	# Basic safety check
	if not get_tree() or not get_tree().current_scene:
		print("Debug screen: Scene not ready, delaying initialization")
		call_deferred("_safe_initialize")
		return
	
	_safe_initialize()

func _safe_initialize() -> void:
	# Create basic debug screen
	_create_3d_screen()
	_create_debug_gizmo()
	set_process(true)

func _create_3d_screen() -> void:
	# Create screen mesh
	screen_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = screen_size
	screen_mesh.mesh = plane
	
	# Position at back of scene
	screen_mesh.position = screen_position
	screen_mesh.rotation.y = deg_to_rad(180)  # Face forward
	
	# Create material with debug texture
	screen_material = MaterialLibrary.get_material("default")
	screen_material.emission_enabled = true
	screen_material.emission_energy = 0.5
	screen_material.unshaded = true
	
	# Create debug texture
	debug_image = Image.create(512, 512, false, Image.FORMAT_RGB8)
	debug_image.fill(Color.BLACK)
	debug_texture = ImageTexture.new()
	debug_texture.set_image(debug_image)
	
	screen_material.albedo_texture = debug_texture
	screen_mesh.material_override = screen_material
	
	add_child(screen_mesh)
	
	print("3D Debug Screen created at position: " + str(screen_position))

func _create_debug_gizmo() -> void:
	# Create gizmo for selected objects
	debug_gizmo = Node3D.new()
	debug_gizmo.name = "DebugGizmo"
	add_child(debug_gizmo)
	
	# Create X, Y, Z axis indicators
	_create_axis_indicator(Vector3.RIGHT, Color.RED, "X")
	_create_axis_indicator(Vector3.UP, Color.GREEN, "Y")
	_create_axis_indicator(Vector3.FORWARD, Color.BLUE, "Z")

func _create_axis_indicator(direction: Vector3, color: Color, label: String) -> void:
	# Arrow shaft
	var shaft = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = 2.0
	cylinder.top_radius = 0.05
	cylinder.bottom_radius = 0.05
	shaft.mesh = cylinder
	
	# Position and rotate
	shaft.position = direction * 1.0
	if direction == Vector3.RIGHT:
		shaft.rotation.z = deg_to_rad(-90)
	elif direction == Vector3.FORWARD:
		shaft.rotation.x = deg_to_rad(90)
	
	# Material
	var mat = MaterialLibrary.get_material("default")
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy = 0.3
	shaft.material_override = mat
	
	FloodgateController.universal_add_child(shaft, debug_gizmo)
	
	# Arrow head
	var head = MeshInstance3D.new()
	var cone = SphereMesh.new()
	cone.radius = 0.15
	cone.height = 0.3
	head.mesh = cone
	head.position = direction * 2.0
	head.material_override = mat
	
	FloodgateController.universal_add_child(head, debug_gizmo)

func _process(delta: float) -> void:
	_update_debug_display()
	_update_gizmo_position()

func _update_debug_display() -> void:
	# Clear debug image
	debug_image.fill(Color.BLACK)
	
	# Get scene information
	_collect_scene_debug_info()
	
	# Draw debug information
	_draw_scene_overview()
	_draw_object_list()
	_draw_selected_object_info()
	_draw_camera_info()
	
	# Update texture
	debug_texture.set_image(debug_image)

func _collect_scene_debug_info() -> void:
	if not debug_info:
		debug_info = {}
	else:
		debug_info.clear()
	
	# Count objects by type
	var object_counts = {}
	var all_objects = []
	
	# Basic safety check
	if not get_tree() or not get_tree().current_scene:
		debug_info["total_objects"] = 0
		debug_info["all_objects"] = []
		return
	
	# Get spawned objects safely
	var world_builder = get_node_or_null("/root/WorldBuilder")
	if world_builder and world_builder.has_method("get_spawned_objects"):
		var spawned = world_builder.get_spawned_objects()
		all_objects.append_array(spawned)
	
	# Get ragdolls
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	all_objects.append_array(ragdolls)
	
	# Count by type
	for obj in all_objects:
		var type = _get_object_type(obj)
		object_counts[type] = object_counts.get(type, 0) + 1
	
	debug_info["object_counts"] = object_counts
	debug_info["total_objects"] = all_objects.size()
	debug_info["all_objects"] = all_objects

func _get_object_type(obj: Node3D) -> String:
	var name = obj.name.to_lower()
	
	if "tree" in name:
		return "tree"
	elif "rock" in name:
		return "rock"
	elif "box" in name:
		return "box"
	elif "ball" in name:
		return "ball"
	elif "ramp" in name:
		return "ramp"
	elif "ragdoll" in name:
		return "ragdoll"
	elif "astral" in name:
		return "astral_being"
	elif "sun" in name:
		return "sun"
	else:
		return "unknown"

func _draw_scene_overview() -> void:
	var y_pos = 20
	
	# Title
	_draw_text("=== SCENE DEBUG ===", 10, y_pos, Color.WHITE)
	y_pos += 25
	
	# Object counts
	var counts = debug_info.get("object_counts", {})
	for type in counts:
		var color = object_colors.get(type, Color.WHITE)
		_draw_text(type + ": " + str(counts[type]), 10, y_pos, color)
		y_pos += 20
	
	# Total
	y_pos += 10
	_draw_text("Total: " + str(debug_info.get("total_objects", 0)), 10, y_pos, Color.YELLOW)

func _draw_object_list() -> void:
	var y_pos = 20
	var x_pos = 200
	
	# Title
	_draw_text("=== OBJECTS ===", x_pos, y_pos, Color.WHITE)
	y_pos += 25
	
	var objects = debug_info.get("all_objects", [])
	var max_display = 15  # Limit display
	
	for i in range(min(objects.size(), max_display)):
		var obj = objects[i]
		var type = _get_object_type(obj)
		var color = object_colors.get(type, Color.WHITE)
		
		# Highlight selected object
		if obj == selected_object:
			color = Color.CYAN
		
		var text = obj.name + " (" + str(obj.global_position).substr(0, 20) + ")"
		_draw_text(text, x_pos, y_pos, color)
		y_pos += 18
	
	if objects.size() > max_display:
		_draw_text("... and " + str(objects.size() - max_display) + " more", x_pos, y_pos, Color.GRAY)

func _draw_selected_object_info() -> void:
	if not selected_object:
		return
	
	var x_pos = 10
	var y_pos = 300
	
	# Title
	_draw_text("=== SELECTED: " + selected_object.name + " ===", x_pos, y_pos, Color.CYAN)
	y_pos += 25
	
	# Position
	_draw_text("Position: " + str(selected_object.global_position), x_pos, y_pos, Color.WHITE)
	y_pos += 20
	
	# Rotation
	var rot = selected_object.global_rotation
	var rot_deg = Vector3(rad_to_deg(rot.x), rad_to_deg(rot.y), rad_to_deg(rot.z))
	_draw_text("Rotation: " + str(rot_deg), x_pos, y_pos, Color.WHITE)
	y_pos += 20
	
	# Scale
	_draw_text("Scale: " + str(selected_object.global_scale), x_pos, y_pos, Color.WHITE)
	y_pos += 20
	
	# Type-specific info
	var type = _get_object_type(selected_object)
	_draw_text("Type: " + type, x_pos, y_pos, object_colors.get(type, Color.WHITE))

func _draw_camera_info() -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var x_pos = 300
	var y_pos = 400
	
	# Title
	_draw_text("=== CAMERA ===", x_pos, y_pos, Color.YELLOW)
	y_pos += 25
	
	# Position
	_draw_text("Position: " + str(camera.global_position), x_pos, y_pos, Color.WHITE)
	y_pos += 20
	
	# Looking at
	var forward = -camera.global_transform.basis.z
	_draw_text("Forward: " + str(forward), x_pos, y_pos, Color.WHITE)

func _draw_text(text: String, x: int, y: int, color: Color) -> void:
	# Simple text drawing on debug image
	for i in range(text.length()):
		var char_x = x + i * 8
		if char_x < debug_image.get_width() - 8 and y < debug_image.get_height() - 12:
			_draw_char(text[i], char_x, y, color)

func _draw_char(character: String, x: int, y: int, color: Color) -> void:
	# Very simple character drawing (just rectangles for now)
	for py in range(8):
		for px in range(6):
			if px < debug_image.get_width() and py < debug_image.get_height():
				debug_image.set_pixel(x + px, y + py, color * 0.8)

func _update_gizmo_position() -> void:
	if selected_object and debug_gizmo:
		debug_gizmo.global_position = selected_object.global_position
		debug_gizmo.visible = true
	else:
		debug_gizmo.visible = false

# Public API

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func select_object(obj: Node3D) -> void:
	selected_object = obj
	if obj:
		print("Selected object: " + obj.name + " at " + str(obj.global_position))

func deselect_object() -> void:
	selected_object = null
	print("Deselected object")

func move_selected_object(direction: Vector3, amount: float = 1.0) -> void:
	if selected_object:
		selected_object.global_position += direction * amount
		print("Moved " + selected_object.name + " to " + str(selected_object.global_position))

func set_selected_object_position(new_position: Vector3) -> bool:
	if selected_object:
		selected_object.global_position = new_position
		print("Moved " + selected_object.name + " to " + str(selected_object.global_position))
		return true
	return false

func rotate_selected_object(axis: Vector3, angle_deg: float) -> void:
	if selected_object:
		selected_object.global_rotation += axis * deg_to_rad(angle_deg)
		print("Rotated " + selected_object.name)

func set_selected_object_rotation(new_rotation: Vector3) -> bool:
	if selected_object:
		selected_object.global_rotation = new_rotation
		print("Rotated " + selected_object.name + " to " + str(selected_object.global_rotation))
		return true
	return false

func scale_selected_object(scale_factor: Vector3) -> void:
	if selected_object:
		selected_object.scale *= scale_factor
		print("Scaled " + selected_object.name + " to " + str(selected_object.scale))

func set_selected_object_scale(new_scale: Vector3) -> bool:
	if selected_object:
		selected_object.scale = new_scale
		print("Scaled " + selected_object.name + " to " + str(selected_object.scale))
		return true
	return false

func set_screen_position(pos: Vector3) -> void:
	screen_position = pos
	if screen_mesh:
		screen_mesh.position = pos

func get_screen_info() -> Dictionary:
	var selected_name = "None"
	if selected_object and is_instance_valid(selected_object):
		selected_name = selected_object.name
	
	return {
		"position": screen_position,
		"size": screen_size,
		"selected_object": selected_name,
		"total_objects": debug_info.get("total_objects", 0)
	}

func find_object_by_name(name: String) -> Node3D:
	var objects = debug_info.get("all_objects", [])
	for obj in objects:
		if obj and is_instance_valid(obj) and obj.name.to_lower().contains(name.to_lower()):
			return obj
	return null
