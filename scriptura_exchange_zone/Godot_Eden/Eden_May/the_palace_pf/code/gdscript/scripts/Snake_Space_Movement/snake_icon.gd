extends Node
class_name SnakeDesktopIcon
# JSH_World/height_map
# JSH_World/icon
#
# res://code/gdscript/scripts/Snake_Space_Movement/snake_icon.gd
# Icon properties
var icon_color = Color(0, 0.7, 0, 1)  # Green color for snake theme
var main_ref = null

# Initialize icon
func _ready_icon():
	# Find reference to main node
	var scene_root = get_tree().get_root()
	if scene_root.has_node("main"):
		main_ref = scene_root.get_node("main")
		
	# Create icon visuals
	create_icon_visuals()
	
	# Add click handler area
	setup_click_handler()

# Create the visual components of the icon
func create_icon_visuals():
	# Create icon mesh
	var icon_mesh = MeshInstance3D.new()
	icon_mesh.name = "IconMesh"
	add_child(icon_mesh)
	
	# Create a simple cube mesh for the icon
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.5, 0.5, 0.1)
	icon_mesh.mesh = box_mesh
	
	# Create a green material for the snake theme
	var material = StandardMaterial3D.new()
	material.albedo_color = icon_color
	icon_mesh.material_override = material
	
	# Add icon text
	var icon_text = Label3D.new()
	icon_text.name = "IconText"
	icon_text.text = "Snake"
	icon_text.font_size = 12
	icon_text.position = Vector3(0, -0.4, 0)
	add_child(icon_text)
	
	# Add snake symbol (simple S shape)
	add_snake_symbol()

# Add snake symbol to make icon recognizable
func add_snake_symbol():
	var snake_symbol = MeshInstance3D.new()
	snake_symbol.name = "SnakeSymbol"
	add_child(snake_symbol)
	
	# Create a simple curved line for the snake
	var immediate_mesh = ImmediateMesh.new()
	snake_symbol.mesh = immediate_mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.9, 0.9) # White snake on green background
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	snake_symbol.material_override = material
	
	# Draw S-shaped snake
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	# S-curve points
	var points = [
		Vector3(-0.15, 0.1, 0.05),
		Vector3(0, 0.1, 0.05),
		Vector3(0.1, 0, 0.05),
		Vector3(0, -0.1, 0.05),
		Vector3(-0.15, -0.1, 0.05)
	]
	
	# Draw lines connecting points
	for i in range(points.size() - 1):
		immediate_mesh.surface_add_vertex(points[i])
		immediate_mesh.surface_add_vertex(points[i + 1])
	
	immediate_mesh.surface_end()

# Setup click handler
func setup_click_handler():
	# Create area for detection
	var area = Area3D.new()
	area.name = "ClickArea"
	add_child(area)
	
	# Add collision shape
	var collision = CollisionShape3D.new()
	area.add_child(collision)
	
	# Create box shape slightly larger than the icon
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.6, 0.6, 0.2)
	collision.shape = shape
	
	# Connect input signal
	area.input_event.connect(_on_area_input_event)

# Handle input on icon
func _on_area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("🐍 Snake icon clicked!")
		
		# Launch snake menu
		if main_ref and main_ref.has_method("show_snake_menu"):
			main_ref.show_snake_menu()
		elif main_ref:
			# Fallback if show_snake_menu doesn't exist
			if main_ref.has_method("three_stages_of_creation_snake"):
				main_ref.three_stages_of_creation_snake("snake_game")
			if main_ref.has_method("show_snake_game"):
				main_ref.show_snake_game()
