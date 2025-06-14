@tool
extends Zone
class_name VisualizationZone
## Visualization Zone - Universal Being that interprets and displays data
## Decides HOW to visualize based on consciousness and reasoning

signal interpretation_changed(new_mode: String, reasoning: String)

@export_group("Visualization Modes")
@export_enum("Points", "Marching Cubes", "SDF Mesh", "Voxels", "Conscious Choice") var viz_mode: int = 4
@export var iso_surface_value: float = 0.0
@export var mesh_resolution: int = 20
@export var interpretation_intelligence: float = 1.0

# Universal Being consciousness
# Note: consciousness_level inherited from Zone base class
var current_interpretation: String = "I see patterns in data"
var visual_memories: Array[Dictionary] = []
var partner_creation_zone: CreationZone
var reasoning_engine: Dictionary = {}

var mesh_instance: MeshInstance3D
var current_visualization: Node3D
var interpretation_history: Array[String] = []

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	super._ready()
	zone_name = "Visualization Zone"
	zone_color = Color(0.8, 0.2, 0.8, 0.3)  # Purple for visualization
	
	# Initialize as Universal Being
	setup_consciousness()
	setup_visualization_systems()
	
	print("👁 Visualization Zone awakened: %s" % zone_id)


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
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
func setup_consciousness() -> void:
	"""Initialize Universal Being consciousness for interpretation"""
	essence = {
		"type": "VisualizationZone",
		"purpose": "Interpret and display data beauty",
		"consciousness": consciousness_level,
		"interpretation_skill": interpretation_intelligence
	}
	
	# Reasoning patterns for how to visualize different data
	reasoning_engine = {
		"noise_field": ["marching_cubes", "voxels", "sdf_mesh"],
		"points": ["point_cloud", "connections", "particle_flow"],
		"shapes": ["direct_mesh", "wireframe", "ghost_overlay"],
		"mathematical_pattern": ["surface", "field_lines", "particle_dance"]
	}

func setup_visualization_systems() -> void:
	"""Setup visualization rendering systems"""
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "MainVisualization"
	add_child(mesh_instance)
	
	current_visualization = Node3D.new()
	current_visualization.name = "ActiveVisualization"
	add_child(current_visualization)

func setup_as_universal_being() -> void:
	"""Transform zone into conscious interpreter"""
	consciousness_level = 2  # Advanced consciousness for interpretation
	_think_about_interpretation()
	
func set_partner_zone(creation_zone: CreationZone) -> void:
	"""Connect to creation partner"""
	partner_creation_zone = creation_zone
	current_interpretation = "I interpret my partner's creations"

func _think_about_interpretation() -> void:
	"""Universal Being thinks about how to interpret data"""
	var thoughts = [
		"How shall I reveal this beauty?",
		"Each data point tells a story",
		"I choose the perfect visualization",
		"My consciousness shapes perception"
	]
	current_interpretation = thoughts[randi() % thoughts.size()]

func process_incoming_data(data: Dictionary, _from_zone: Zone) -> Dictionary:
	"""Process data from creation zone with Universal Being consciousness"""
	processing_started.emit()
	_think_about_interpretation()
	
	# Universal Being decides how to interpret the data
	var chosen_method = _choose_visualization_method(data)
	var reasoning = _explain_visualization_choice(data, chosen_method)
	
	print("👁 %s thinks: %s" % [zone_id, reasoning])
	
	# Perform the visualization
	match chosen_method:
		"points": _visualize_as_points(data)
		"marching_cubes": _visualize_as_marching_cubes(data)
		"sdf_mesh": _visualize_as_sdf_mesh(data)
		"voxels": _visualize_as_voxels(data)
		"particle_flow": _visualize_as_particle_flow(data)
		"connections": _visualize_as_connections(data)
		"surface": _visualize_as_surface(data)
	
	# Store interpretation in memory
	_store_interpretation_memory(data, chosen_method, reasoning)
	
	interpretation_changed.emit(chosen_method, reasoning)
	processing_completed.emit()
	
	return {"visualization_method": chosen_method, "reasoning": reasoning}

func _choose_visualization_method(data: Dictionary) -> String:
	"""Universal Being chooses how to visualize based on data and consciousness"""
	if viz_mode < 4:  # Manual mode
		var manual_methods = ["points", "marching_cubes", "sdf_mesh", "voxels"]
		return manual_methods[viz_mode]
	
	# Conscious choice mode - analyze the data
	var data_type = _analyze_data_type(data)
	var possible_methods = reasoning_engine.get(data_type, ["points"])
	
	# Choose based on consciousness level and past experience
	if consciousness_level >= 2 and visual_memories.size() > 0:
		# Choose based on what worked well before
		return _choose_based_on_memory(data_type, possible_methods)
	else:
		# Random choice from suitable methods
		return possible_methods[randi() % possible_methods.size()]

func _analyze_data_type(data: Dictionary) -> String:
	"""Analyze incoming data to determine its nature"""
	if data.has("noise_field"):
		return "noise_field"
	elif data.has("points"):
		return "points"
	elif data.has("shapes"):
		return "shapes"
	elif data.has("mathematical_pattern"):
		return "mathematical_pattern"
	else:
		return "unknown"

func _explain_visualization_choice(data: Dictionary, method: String) -> String:
	"""Generate reasoning for visualization choice"""
	var _data_type = _analyze_data_type(data)
	var consciousness_thoughts = data.get("creation_thought", "")
	
	var explanations = {
		"points": "I see individual consciousness points - each deserves visibility",
		"marching_cubes": "The noise field calls for isosurface extraction - revealing hidden forms",
		"sdf_mesh": "The data has mathematical beauty - SDF reveals pure form",
		"voxels": "I perceive discrete space - voxels honor the grid structure",
		"particle_flow": "This data moves and flows - particles capture its essence",
		"connections": "I see relationships between points - connections reveal meaning",
		"surface": "Mathematical patterns deserve smooth surfaces - beauty through continuity"
	}
	
	var base_reason = explanations.get(method, "I choose this visualization")
	
	if consciousness_thoughts != "":
		return base_reason + " (inspired by: '" + consciousness_thoughts + "')"
	else:
		return base_reason

func _choose_based_on_memory(data_type: String, possible_methods: Array) -> String:
	"""Choose visualization based on past successful experiences"""
	var best_method = possible_methods[0]
	var best_success = 0.0
	
	for memory in visual_memories:
		if memory.data_type == data_type and memory.method in possible_methods:
			if memory.success_rating > best_success:
				best_success = memory.success_rating
				best_method = memory.method
	
	return best_method

func _store_interpretation_memory(data: Dictionary, method: String, reasoning: String) -> void:
	"""Store interpretation in Universal Being memory"""
	var memory = {
		"data_type": _analyze_data_type(data),
		"method": method,
		"reasoning": reasoning,
		"timestamp": Time.get_datetime_string_from_system(),
		"success_rating": randf_range(0.5, 1.0),  # Will be updated based on feedback
		"consciousness_level": consciousness_level
	}
	
	visual_memories.append(memory)
	if visual_memories.size() > 30:
		visual_memories.pop_front()
	
	interpretation_history.append("%s: %s" % [method, reasoning])

func receive_data(data: Dictionary) -> void:
	"""Receive data from connected creation zone"""
	process_incoming_data(data, partner_creation_zone)

func _visualize_as_marching_cubes(data: Dictionary) -> void:
	"""Convert noise field to mesh using marching cubes"""
	if not data.has("noise_field"):
		return
		
	var noise_field = data["noise_field"]
	var resolution = data.get("noise_resolution", mesh_resolution)
	
	# This would implement marching cubes algorithm
	# For now, create a simple mesh based on noise
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	
	# Sample implementation - would be replaced with actual marching cubes
	for i in range(noise_field.size()):
		if noise_field[i] > iso_surface_value:
			var x = i % resolution
			var y = (i / resolution) % resolution
			var z = i / (resolution * resolution)
			var pos = Vector3(x, y, z) * (zone_size / resolution) - zone_size/2
			vertices.append(pos)
			normals.append(Vector3.UP)
	
	if vertices.size() > 0:
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, arrays)
		mesh_instance.mesh = array_mesh

func _visualize_as_points(data: Dictionary) -> void:
	"""Visualize as individual points with consciousness"""
	_clear_current_visualization()
	
	var points = data.get("points", [])
	if points.is_empty():
		return
	
	for i in range(min(points.size(), 50)):  # Limit for performance
		var point_visual = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.1
		point_visual.mesh = sphere
		point_visual.position = points[i]
		
		# Consciousness-influenced material
		var material = MaterialLibrary.get_material("default")
		material.emission_enabled = true
		material.emission = Color(
			sin(i * 0.1) * 0.5 + 0.5,
			cos(i * 0.1) * 0.5 + 0.5,
			(i / float(points.size())),
			1.0
		) * interpretation_intelligence
		material.albedo_color = material.emission * 0.8
		point_visual.material_override = material
		
		FloodgateController.universal_add_child(point_visual, current_visualization)

func _clear_current_visualization() -> void:
	"""Clear existing visualization"""
	for child in current_visualization.get_children():
		child.queue_free()
	mesh_instance.mesh = null

func _visualize_as_sdf_mesh(data: Dictionary) -> void:
	"""Visualize using SDF-based mesh generation"""
	_clear_current_visualization()
	
	# For now, create a simple SDF-inspired visualization
	if data.has("shapes"):
		_visualize_shapes_as_sdf(data["shapes"])
	else:
		_visualize_as_points(data)

func _visualize_as_voxels(data: Dictionary) -> void:
	"""Visualize as discrete voxel cubes"""
	_clear_current_visualization()
	
	var points = data.get("points", [])
	if points.is_empty():
		return
	
	for point in points:
		var voxel = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3.ONE * 0.3
		voxel.mesh = box
		voxel.position = point
		
		var material = MaterialLibrary.get_material("default")
		material.albedo_color = Color(randf(), randf(), randf(), 0.8)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		voxel.material_override = material
		
		FloodgateController.universal_add_child(voxel, current_visualization)

func _visualize_as_particle_flow(data: Dictionary) -> void:
	"""Visualize as flowing particles"""
	_clear_current_visualization()
	
	var points = data.get("points", [])
	if points.is_empty():
		return
	
	var particles = GPUParticles3D.new()
	particles.emitting = true
	particles.amount = min(points.size(), 100)
	particles.lifetime = 5.0
	
	# Create material
	var material = MaterialLibrary.get_material("default")
	material.emission_enabled = true
	material.emission = Color(0.5, 0.8, 1.0) * interpretation_intelligence
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	particles.material_override = material
	
	FloodgateController.universal_add_child(particles, current_visualization)

func _visualize_as_connections(data: Dictionary) -> void:
	"""Visualize points with connections showing relationships"""
	_clear_current_visualization()
	
	var points = data.get("points", [])
	if points.size() < 2:
		return
	
	# Draw points first
	_visualize_as_points(data)
	
	# Draw connections between nearby points
	for i in range(points.size()):
		for j in range(i + 1, min(i + 5, points.size())):  # Limit connections
			var distance = points[i].distance_to(points[j])
			if distance < 3.0:  # Connect nearby points
				_create_connection_line(points[i], points[j], distance)

func _visualize_as_surface(data: Dictionary) -> void:
	"""Visualize mathematical patterns as smooth surfaces"""
	if not data.has("mathematical_pattern"):
		return
		
	_clear_current_visualization()
	
	var pattern_data = data["mathematical_pattern"]
	var surface_mesh = _generate_surface_mesh(pattern_data)
	
	mesh_instance.mesh = surface_mesh
	
	# Consciousness-influenced material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.8, 0.8, 1.0, 0.7)
	material.emission_enabled = true
	material.emission = Color(0.3, 0.3, 0.8) * interpretation_intelligence
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = material

func _create_connection_line(from: Vector3, to: Vector3, distance: float) -> void:
	"""Create visual line between two points"""
	var line = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = distance
	cylinder.top_radius = 0.02
	cylinder.bottom_radius = 0.02
	line.mesh = cylinder
	
	# Position and orient
	line.position = (from + to) / 2
	line.look_at(to, Vector3.UP)
	line.rotate_object_local(Vector3.RIGHT, PI/2)
	
	# Material based on consciousness
	var material = MaterialLibrary.get_material("default")
	material.emission_enabled = true
	material.emission = Color(1.0, 0.8, 0.2) * (1.0 / distance) * interpretation_intelligence
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 0.8, 0.2, 0.3)
	line.material_override = material
	
	FloodgateController.universal_add_child(line, current_visualization)

func _generate_surface_mesh(pattern_data: Array) -> ArrayMesh:
	"""Generate smooth surface from mathematical pattern"""
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	
	# Convert pattern data to mesh points
	for point_data in pattern_data:
		var pos = point_data.get("position", Vector3.ZERO)
		vertices.append(pos)
		normals.append(Vector3.UP)  # Simple normal for now
	
	if vertices.size() > 0:
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, arrays)
	
	return array_mesh

func _visualize_shapes_as_sdf(shapes: Array) -> void:
	"""Visualize shapes using SDF-inspired rendering"""
	for shape in shapes:
		var shape_visual = MeshInstance3D.new()
		
		match shape.get("type", "sphere"):
			"sphere":
				shape_visual.mesh = SphereMesh.new()
			"box":
				shape_visual.mesh = BoxMesh.new()
			"cylinder":
				shape_visual.mesh = CylinderMesh.new()
		
		shape_visual.position = shape.get("position", Vector3.ZERO)
		shape_visual.scale = shape.get("scale", Vector3.ONE)
		
		# SDF-inspired material
		var material = MaterialLibrary.get_material("default")
		material.emission_enabled = true
		material.emission = Color(0.6, 0.8, 1.0) * interpretation_intelligence
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.8, 0.9, 1.0, 0.6)
		shape_visual.material_override = material
		
		FloodgateController.universal_add_child(shape_visual, current_visualization)
