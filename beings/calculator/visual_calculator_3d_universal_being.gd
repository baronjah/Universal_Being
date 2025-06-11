# 3D VISUAL CALCULATOR - TRUE VISUAL PROGRAMMING SYSTEM
# Functions as nodes, data flows as arrows, operations as visual connections
extends UniversalBeing
class_name VisualCalculator3DUniversalBeing

signal data_flow_started(from_node: String, to_node: String, data: Variant)
signal calculation_completed(result: Variant)
signal function_node_created(node_name: String, function_type: String)
signal connection_established(from_output: String, to_input: String)

# Visual programming nodes
enum FunctionNodeType {
	INPUT,          # Data input
	OUTPUT,         # Data output  
	MATH,          # Mathematical operations
	LOGIC,         # Boolean logic
	COMPARISON,    # Comparison operations
	TRANSFORM,     # Data transformation
	SPLIT,         # Split data to multiple outputs
	MERGE,         # Merge multiple inputs
	STORAGE,       # Store/retrieve data
	CONDITIONAL,   # If/then logic
	INSPECTOR      # Data inspection and analysis
}

# Node management
var function_nodes: Dictionary = {}  # node_id -> node_data
var data_connections: Array = []     # connection data
var active_calculations: Array = []  # running calculations
var visual_arrows: Array = []        # visual connection arrows

# Calculator workspace
var workspace_center: Vector3 = Vector3.ZERO
var grid_size: float = 5.0
var node_spacing: float = 8.0

# Pentagon lifecycle
func pentagon_init():
	super.pentagon_init()
	being_type = "visual_calculator_3d"
	being_name = "3D Visual Calculator Universal Being"
	consciousness_level = 4
	print("🧮 Visual Calculator: Initializing data flow programming system...")

func pentagon_ready():
	super.pentagon_ready()
	create_calculator_workspace()
	create_function_node_palette()
	create_example_calculation()
	print("✨ Visual Calculator: Ready for visual programming!")

func pentagon_process(delta: float):
	super.pentagon_process(delta)
	update_data_flow_animations(delta)
	process_active_calculations(delta)

func pentagon_input(event: InputEvent):
	super.pentagon_input(event)
	handle_calculator_input(event)

func pentagon_sewers():
	save_calculator_workspace()
	super.pentagon_sewers()

func create_calculator_workspace():
	"""Create the 3D visual programming workspace"""
	print("🌌 Creating visual calculator workspace...")
	
	# Create workspace floor grid
	create_workspace_grid()
	
	# Create function node creation tools
	create_node_creation_interface()
	
	# Create data type legends
	create_data_type_legend()

func create_workspace_grid():
	"""Create visual grid for function node placement"""
	var grid_size_count = 20
	var grid_spacing = grid_size
	
	for x in range(-grid_size_count, grid_size_count + 1):
		for z in range(-grid_size_count, grid_size_count + 1):
			if x % 5 == 0 or z % 5 == 0:  # Major grid lines
				var grid_point = MeshInstance3D.new()
				var sphere = SphereMesh.new()
				sphere.radius = 0.1
				grid_point.mesh = sphere
				grid_point.position = Vector3(x * grid_spacing, -1, z * grid_spacing)
				
				var material = StandardMaterial3D.new()
				material.albedo_color = Color(0.3, 0.3, 0.6, 0.5)
				material.emission_enabled = true
				material.emission = Color.CYAN * 0.2
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				grid_point.material_override = material
				
				add_child(grid_point)

func create_function_node_palette():
	"""Create palette of available function node types"""
	var palette_position = Vector3(-25, 0, 0)
	
	var node_types = [
		{"type": FunctionNodeType.INPUT, "name": "INPUT", "color": Color.GREEN},
		{"type": FunctionNodeType.OUTPUT, "name": "OUTPUT", "color": Color.RED},
		{"type": FunctionNodeType.MATH, "name": "MATH", "color": Color.BLUE},
		{"type": FunctionNodeType.LOGIC, "name": "LOGIC", "color": Color.PURPLE},
		{"type": FunctionNodeType.COMPARISON, "name": "COMPARE", "color": Color.ORANGE},
		{"type": FunctionNodeType.TRANSFORM, "name": "TRANSFORM", "color": Color.CYAN},
		{"type": FunctionNodeType.SPLIT, "name": "SPLIT", "color": Color.YELLOW},
		{"type": FunctionNodeType.MERGE, "name": "MERGE", "color": Color.MAGENTA},
		{"type": FunctionNodeType.INSPECTOR, "name": "INSPECT", "color": Color.WHITE}
	]
	
	for i in range(node_types.size()):
		var node_type = node_types[i]
		var palette_node = create_palette_node(
			node_type.name,
			palette_position + Vector3(0, i * 3, 0),
			node_type.color,
			node_type.type
		)
		add_child(palette_node)

func create_palette_node(name: String, position: Vector3, color: Color, type: FunctionNodeType) -> Node3D:
	"""Create a palette node for spawning function nodes"""
	var palette_node = Node3D.new()
	palette_node.name = "PaletteNode_" + name
	palette_node.position = position
	
	# Node visual
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(3, 1, 1)
	mesh.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color * 1.5
	material.emission_energy = 0.8
	mesh.material_override = material
	palette_node.add_child(mesh)
	
	# Node label
	var label = Label3D.new()
	label.text = "📦 " + name
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0, 1)
	label.modulate = Color.WHITE
	label.pixel_size = 0.01
	palette_node.add_child(label)
	
	# Click detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(3, 1, 1.5)
	collision.shape = shape
	area.add_child(collision)
	palette_node.add_child(area)
	
	# Connect spawning
	area.input_event.connect(_on_palette_node_clicked.bind(type, name))
	
	return palette_node

func create_example_calculation():
	"""Create example visual calculation to demonstrate system"""
	print("🧮 Creating example calculation...")
	
	# Create input node
	var input_node = create_function_node(FunctionNodeType.INPUT, Vector3(0, 0, 0), "Number Input")
	input_node.set_meta("value", 5.0)
	
	# Create math node (multiply by 2)
	var math_node = create_function_node(FunctionNodeType.MATH, Vector3(10, 0, 0), "Multiply")
	math_node.set_meta("operation", "multiply")
	math_node.set_meta("operand", 2.0)
	
	# Create output node
	var output_node = create_function_node(FunctionNodeType.OUTPUT, Vector3(20, 0, 0), "Result")
	
	# Connect nodes
	create_data_connection(input_node, "output", math_node, "input_a")
	create_data_connection(math_node, "output", output_node, "input")

func create_function_node(type: FunctionNodeType, position: Vector3, label: String) -> Node3D:
	"""Create a function node in the workspace"""
	var node_id = "node_" + str(function_nodes.size())
	var function_node = Node3D.new()
	function_node.name = node_id
	function_node.position = position
	
	# Node data
	var node_data = {
		"id": node_id,
		"type": type,
		"label": label,
		"position": position,
		"inputs": {},
		"outputs": {},
		"properties": {}
	}
	
	# Visual representation
	var node_visual = create_node_visual(type, label)
	function_node.add_child(node_visual)
	
	# Input/Output connection points
	create_node_connection_points(function_node, type)
	
	# Store node data
	function_nodes[node_id] = node_data
	add_child(function_node)
	
	function_node_created.emit(node_id, get_node_type_name(type))
	print("📦 Created function node: " + label)
	
	return function_node

func create_node_visual(type: FunctionNodeType, label: String) -> Node3D:
	"""Create visual representation of function node"""
	var visual = Node3D.new()
	visual.name = "NodeVisual"
	
	# Main node body
	var mesh = MeshInstance3D.new()
	var shape = _get_node_shape(type)
	mesh.mesh = shape
	
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_node_color(type)
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.5
	material.emission_energy = 0.6
	mesh.material_override = material
	visual.add_child(mesh)
	
	# Node label
	var node_label = Label3D.new()
	node_label.text = label
	node_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	node_label.position = Vector3(0, 2, 0)
	node_label.modulate = Color.WHITE
	node_label.pixel_size = 0.012
	visual.add_child(node_label)
	
	return visual

func _get_node_shape(type: FunctionNodeType) -> Mesh:
	"""Get appropriate mesh shape for node type"""
	match type:
		FunctionNodeType.INPUT:
			var cylinder = CylinderMesh.new()
			cylinder.height = 1.5
			cylinder.top_radius = 1.0
			cylinder.bottom_radius = 1.0
			return cylinder
		FunctionNodeType.OUTPUT:
			var cylinder = CylinderMesh.new()
			cylinder.height = 1.5
			cylinder.top_radius = 1.5
			cylinder.bottom_radius = 0.5
			return cylinder
		FunctionNodeType.MATH:
			var box = BoxMesh.new()
			box.size = Vector3(2, 1.5, 2)
			return box
		FunctionNodeType.LOGIC:
			var prism = PrismMesh.new()
			prism.size = Vector3(2, 1.5, 2)
			return prism
		FunctionNodeType.SPLIT:
			var prism = PrismMesh.new()
			prism.size = Vector3(1, 1.5, 3)
			return prism
		_:
			var sphere = SphereMesh.new()
			sphere.radius = 1.0
			return sphere

func _get_node_color(type: FunctionNodeType) -> Color:
	"""Get color for node type"""
	match type:
		FunctionNodeType.INPUT: return Color.GREEN
		FunctionNodeType.OUTPUT: return Color.RED
		FunctionNodeType.MATH: return Color.BLUE
		FunctionNodeType.LOGIC: return Color.PURPLE
		FunctionNodeType.COMPARISON: return Color.ORANGE
		FunctionNodeType.TRANSFORM: return Color.CYAN
		FunctionNodeType.SPLIT: return Color.YELLOW
		FunctionNodeType.MERGE: return Color.MAGENTA
		FunctionNodeType.INSPECTOR: return Color.WHITE
		_: return Color.GRAY

func create_node_connection_points(node: Node3D, type: FunctionNodeType):
	"""Create input/output connection points for node"""
	var input_points = _get_input_points(type)
	var output_points = _get_output_points(type)
	
	# Create input connection points
	for i in range(input_points):
		var input_point = create_connection_point("input_" + str(i), Vector3(-2, 0, -1 + i * 2), Color.GREEN)
		node.add_child(input_point)
	
	# Create output connection points
	for i in range(output_points):
		var output_point = create_connection_point("output_" + str(i), Vector3(2, 0, -1 + i * 2), Color.RED)
		node.add_child(output_point)

func create_connection_point(point_id: String, position: Vector3, color: Color) -> Node3D:
	"""Create a connection point for data flow"""
	var point = Node3D.new()
	point.name = point_id
	point.position = position
	
	# Visual indicator
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.3
	mesh.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color * 2.0
	material.emission_energy = 1.0
	mesh.material_override = material
	point.add_child(mesh)
	
	# Connection detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.5
	collision.shape = shape
	area.add_child(collision)
	point.add_child(area)
	
	return point

func _get_input_points(type: FunctionNodeType) -> int:
	"""Get number of input points for node type"""
	match type:
		FunctionNodeType.INPUT: return 0
		FunctionNodeType.OUTPUT: return 1
		FunctionNodeType.MATH: return 2
		FunctionNodeType.LOGIC: return 2
		FunctionNodeType.COMPARISON: return 2
		FunctionNodeType.TRANSFORM: return 1
		FunctionNodeType.SPLIT: return 1
		FunctionNodeType.MERGE: return 3
		_: return 1

func _get_output_points(type: FunctionNodeType) -> int:
	"""Get number of output points for node type"""
	match type:
		FunctionNodeType.INPUT: return 1
		FunctionNodeType.OUTPUT: return 0
		FunctionNodeType.SPLIT: return 3
		_: return 1

func create_data_connection(from_node: Node3D, from_output: String, to_node: Node3D, to_input: String):
	"""Create visual data connection between nodes"""
	var connection_id = "conn_" + str(data_connections.size())
	
	var connection_data = {
		"id": connection_id,
		"from_node": from_node.name,
		"from_output": from_output,
		"to_node": to_node.name,
		"to_input": to_input,
		"data_type": "number",  # Could be inferred
		"active": true
	}
	
	data_connections.append(connection_data)
	
	# Create visual arrow
	var arrow = create_connection_arrow(from_node.global_position, to_node.global_position)
	visual_arrows.append(arrow)
	add_child(arrow)
	
	connection_established.emit(from_output, to_input)
	print("🔗 Connected: " + from_node.name + "." + from_output + " → " + to_node.name + "." + to_input)

func create_connection_arrow(from_pos: Vector3, to_pos: Vector3) -> Node3D:
	"""Create visual arrow showing data connection"""
	var arrow = Node3D.new()
	arrow.name = "DataConnection"
	
	# Arrow line
	var line_mesh = MeshInstance3D.new()
	var line_length = from_pos.distance_to(to_pos)
	var cylinder = CylinderMesh.new()
	cylinder.height = line_length
	cylinder.top_radius = 0.1
	cylinder.bottom_radius = 0.1
	line_mesh.mesh = cylinder
	
	# Position and orient arrow
	arrow.position = from_pos + (to_pos - from_pos) * 0.5
	arrow.look_at(to_pos, Vector3.UP)
	arrow.rotation.x += PI/2  # Correct orientation
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.CYAN
	material.emission_enabled = true
	material.emission = Color.CYAN * 1.5
	material.emission_energy = 0.8
	line_mesh.material_override = material
	
	arrow.add_child(line_mesh)
	
	# Arrow head
	var arrow_head = MeshInstance3D.new()
	var cone = ConeMesh.new()
	cone.height = 1.0
	cone.top_radius = 0.0
	cone.bottom_radius = 0.3
	arrow_head.mesh = cone
	arrow_head.position = Vector3(0, line_length * 0.5, 0)
	arrow_head.material_override = material
	arrow.add_child(arrow_head)
	
	return arrow

func update_data_flow_animations(delta: float):
	"""Animate data flowing through connections"""
	for arrow in visual_arrows:
		if arrow and is_instance_valid(arrow):
			# Pulse effect for data flow
			var time = Time.get_ticks_msec() * 0.003
			var pulse = 1.0 + sin(time) * 0.3
			arrow.scale = Vector3(pulse, 1.0, pulse)

func process_active_calculations(delta: float):
	"""Process any active calculations"""
	# This would handle the actual data processing
	# For now, just demonstration
	pass

func handle_calculator_input(event: InputEvent):
	"""Handle input for calculator operations"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				execute_calculation_flow()
			KEY_R:
				reset_calculator()
			KEY_S:
				save_calculator_workspace()

func execute_calculation_flow():
	"""Execute the current calculation flow"""
	print("🧮 Executing calculation flow...")
	
	# Find input nodes and start calculation
	for node_id in function_nodes.keys():
		var node_data = function_nodes[node_id]
		if node_data.type == FunctionNodeType.INPUT:
			_propagate_data_from_node(node_id)

func _propagate_data_from_node(node_id: String):
	"""Propagate data from a specific node"""
	var node_data = function_nodes[node_id]
	print("📤 Propagating data from: " + node_data.label)
	
	# This would implement the actual data flow logic
	data_flow_started.emit(node_id, "output", node_data.get("value", 0))

func _on_palette_node_clicked(type: FunctionNodeType, name: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle palette node clicks to spawn new function nodes"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var spawn_position = _find_empty_workspace_position()
		create_function_node(type, spawn_position, name + "_" + str(function_nodes.size()))

func _find_empty_workspace_position() -> Vector3:
	"""Find empty position in workspace for new node"""
	var attempts = 0
	while attempts < 50:
		var test_pos = Vector3(
			randf_range(-20, 20),
			0,
			randf_range(-20, 20)
		)
		
		var is_empty = true
		for node_id in function_nodes.keys():
			var node_data = function_nodes[node_id]
			if node_data.position.distance_to(test_pos) < node_spacing:
				is_empty = false
				break
		
		if is_empty:
			return test_pos
		
		attempts += 1
	
	# Fallback to grid position
	return Vector3(function_nodes.size() * node_spacing, 0, 0)

func create_data_type_legend():
	"""Create legend showing data types and their colors"""
	var legend_position = Vector3(25, 0, 0)
	
	var data_types = [
		{"name": "Number", "color": Color.BLUE},
		{"name": "String", "color": Color.GREEN},
		{"name": "Boolean", "color": Color.RED},
		{"name": "Array", "color": Color.YELLOW},
		{"name": "Object", "color": Color.PURPLE}
	]
	
	var legend_title = Label3D.new()
	legend_title.text = "📊 DATA TYPES"
	legend_title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	legend_title.position = legend_position + Vector3(0, 5, 0)
	legend_title.modulate = Color.WHITE
	legend_title.pixel_size = 0.015
	add_child(legend_title)
	
	for i in range(data_types.size()):
		var data_type = data_types[i]
		var legend_item = create_legend_item(
			data_type.name,
			legend_position + Vector3(0, 3 - i * 1.5, 0),
			data_type.color
		)
		add_child(legend_item)

func create_legend_item(name: String, position: Vector3, color: Color) -> Node3D:
	"""Create a legend item showing data type"""
	var item = Node3D.new()
	item.position = position
	
	# Color indicator
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.3
	mesh.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy = 1.0
	mesh.material_override = material
	item.add_child(mesh)
	
	# Type label
	var label = Label3D.new()
	label.text = name
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(1, 0, 0)
	label.modulate = Color.WHITE
	label.pixel_size = 0.01
	item.add_child(label)
	
	return item

func get_node_type_name(type: FunctionNodeType) -> String:
	"""Get human-readable name for node type"""
	match type:
		FunctionNodeType.INPUT: return "Input"
		FunctionNodeType.OUTPUT: return "Output"
		FunctionNodeType.MATH: return "Math"
		FunctionNodeType.LOGIC: return "Logic"
		FunctionNodeType.COMPARISON: return "Comparison"
		FunctionNodeType.TRANSFORM: return "Transform"
		FunctionNodeType.SPLIT: return "Split"
		FunctionNodeType.MERGE: return "Merge"
		FunctionNodeType.STORAGE: return "Storage"
		FunctionNodeType.CONDITIONAL: return "Conditional"
		FunctionNodeType.INSPECTOR: return "Inspector"
		_: return "Unknown"

func reset_calculator():
	"""Reset calculator workspace"""
	print("🔄 Resetting calculator workspace...")
	
	# Clear all nodes and connections
	for arrow in visual_arrows:
		if arrow and is_instance_valid(arrow):
			arrow.queue_free()
	
	visual_arrows.clear()
	data_connections.clear()
	function_nodes.clear()

func save_calculator_workspace():
	"""Save current workspace configuration"""
	print("💾 Saving calculator workspace...")
	# This would save the current configuration to AkashicRecords

# Public interface
func get_workspace_info() -> Dictionary:
	"""Get comprehensive workspace information"""
	return {
		"function_nodes": function_nodes.size(),
		"data_connections": data_connections.size(),
		"active_calculations": active_calculations.size(),
		"workspace_center": workspace_center
	}