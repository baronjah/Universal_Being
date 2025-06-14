@tool
extends UniversalBeingBase
class_name ZoneSystem
## 3D Block Coding Zone System - Creation and Visualization Zones
## One zone creates data (points, shapes, noise), another visualizes it
## Universal Beings decide HOW to interpret and display the data

# Zone connections like neural synapses
var creation_zones: Array[CreationZone] = []
var visualization_zones: Array[VisualizationZone] = []
var zone_connections: Dictionary = {} # {from_zone_id: [to_zone_ids]}
var data_flows: Dictionary = {} # Active data streams between zones

# Visual feedback
var connection_lines: Array[MeshInstance3D] = []
var data_particles: CPUParticles3D

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	"""Initialize the zone system"""
	set_physics_process(true)
	_setup_visual_feedback()
	
	if Engine.is_editor_hint():
		print("🧠 Zone System: 3D Block Coding Active")


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
func create_zone_pair(zone_position: Vector3) -> Dictionary:
	"""Create a connected creation-visualization zone pair"""
	# Creation zone on the left
	var creation_zone = preload("res://scripts/zones/creation_zone.gd").new()
	creation_zone.position = zone_position + Vector3(-6, 0, 0)
	creation_zone.zone_id = _generate_zone_id()
	add_child(creation_zone)
	creation_zones.append(creation_zone)
	
	# Visualization zone on the right
	var viz_zone = preload("res://scripts/zones/visualization_zone.gd").new()
	viz_zone.position = zone_position + Vector3(6, 0, 0)
	viz_zone.zone_id = _generate_zone_id()
	add_child(viz_zone)
	visualization_zones.append(viz_zone)
	
	# Connect them
	connect_zones(creation_zone, viz_zone)
	
	return {
		"creation": creation_zone,
		"visualization": viz_zone
	}

func connect_zones(from_zone: Zone, to_zone: Zone) -> void:
	"""Connect two zones for data flow"""
	var from_id = from_zone.zone_id
	var to_id = to_zone.zone_id
	
	if not zone_connections.has(from_id):
		zone_connections[from_id] = []
	
	if not to_id in zone_connections[from_id]:
		zone_connections[from_id].append(to_id)
		
		# Visual connection
		_create_connection_visual(from_zone, to_zone)
		
		# Setup data flow
		_setup_data_flow(from_zone, to_zone)
		
		print("✨ Connected: %s → %s" % [from_zone.name, to_zone.name])

func _setup_data_flow(from_zone: Zone, to_zone: Zone) -> void:
	"""Setup automatic data flow between zones"""
	# When creation zone updates, notify visualization
	if from_zone.has_signal("data_updated"):
		from_zone.data_updated.connect(
			func(data): _transfer_data(from_zone, to_zone, data)
		)

func _transfer_data(from_zone: Zone, to_zone: Zone, data: Dictionary) -> void:
	"""Transfer data from one zone to another with visual feedback"""
	# Store data flow
	var flow_id = "%s_%s" % [from_zone.zone_id, to_zone.zone_id]
	data_flows[flow_id] = {
		"data": data,
		"timestamp": Time.get_ticks_msec()
	}
	
	# Visualization zone processes the data
	if to_zone.has_method("process_incoming_data"):
		to_zone.process_incoming_data(data, from_zone)
	
	# Visual feedback - data particles flowing along connection
	_spawn_data_particles(from_zone.global_position, to_zone.global_position)

func _create_connection_visual(from_zone: Zone, to_zone: Zone) -> void:
	"""Create visual connection between zones"""
	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	
	# Create a tube mesh for the connection
	var curve = Curve3D.new()
	curve.add_point(from_zone.position)
	
	# Add control points for smooth curve
	var mid_point = (from_zone.position + to_zone.position) / 2.0
	mid_point.y += 2.0 # Arc upward
	curve.add_point(mid_point)
	curve.add_point(to_zone.position)
	
	# Generate tube mesh
	var tube_mesh = _create_tube_mesh(curve)
	mesh_instance.mesh = tube_mesh
	
	# Glowing material
	var material = MaterialLibrary.get_material("default")
	material.emission_enabled = true
	material.emission = Color(0.2, 0.5, 1.0)
	material.emission_intensity = 2.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.3, 0.6, 1.0, 0.5)
	mesh_instance.material_override = material
	
	connection_lines.append(mesh_instance)

func _create_tube_mesh(curve: Curve3D) -> ArrayMesh:
	"""Create a tube mesh along a curve"""
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	
	# Generate tube geometry
	var segments = 20
	var radial_segments = 8
	var radius = 0.1
	
	for i in range(segments + 1):
		var t = float(i) / float(segments)
		var pos = curve.sample_baked(t * curve.get_baked_length())
		var tangent = curve.sample_baked(t * curve.get_baked_length() + 0.01) - pos
		tangent = tangent.normalized()
		
		# Create ring of vertices
		for j in range(radial_segments):
			var angle = float(j) / float(radial_segments) * TAU
			
			# Calculate perpendicular vectors
			var right = Vector3.UP.cross(tangent).normalized()
			if right.length() < 0.01:
				right = Vector3.RIGHT
			var up = tangent.cross(right).normalized()
			
			# Vertex position
			var offset = (right * cos(angle) + up * sin(angle)) * radius
			vertices.append(pos + offset)
			
			# Normal
			normals.append(offset.normalized())
			
			# UV
			uvs.append(Vector2(float(i) / float(segments), float(j) / float(radial_segments)))
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	
	# Create indices
	var indices = PackedInt32Array()
	for i in range(segments):
		for j in range(radial_segments):
			var current = i * radial_segments + j
			var next = i * radial_segments + ((j + 1) % radial_segments)
			var current_next = (i + 1) * radial_segments + j
			var next_next = (i + 1) * radial_segments + ((j + 1) % radial_segments)
			
			# Two triangles per quad
			indices.append(current)
			indices.append(next)
			indices.append(current_next)
			
			indices.append(next)
			indices.append(next_next)
			indices.append(current_next)
	
	arrays[Mesh.ARRAY_INDEX] = indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return array_mesh

func _setup_visual_feedback() -> void:
	"""Setup particle system for data flow visualization"""
	data_particles = CPUParticles3D.new()
	add_child(data_particles)
	
	data_particles.emitting = false
	data_particles.amount = 50
	data_particles.lifetime = 2.0
	data_particles.one_shot = true
	
	# Particle appearance
	data_particles.mesh = SphereMesh.new()
	data_particles.mesh.radial_segments = 8
	data_particles.mesh.height = 0.1
	data_particles.mesh.radius = 0.05
	
	# Glowing material
	var particle_mat = MaterialLibrary.get_material("default")
	particle_mat.emission_enabled = true
	particle_mat.emission = Color(1.0, 0.8, 0.2)
	particle_mat.emission_intensity = 5.0
	data_particles.material_override = particle_mat
	
	# Particle behavior
	data_particles.initial_velocity_min = 0.5
	data_particles.initial_velocity_max = 1.0
	data_particles.angular_velocity_min = -180
	data_particles.angular_velocity_max = 180
	data_particles.scale_amount_min = 0.5
	data_particles.scale_amount_max = 1.5

func _spawn_data_particles(from_pos: Vector3, to_pos: Vector3) -> void:
	"""Spawn particles that flow from one zone to another"""
	data_particles.position = from_pos
	data_particles.direction = (to_pos - from_pos).normalized()
	data_particles.emitting = true
	data_particles.restart()

func _generate_zone_id() -> String:
	"""Generate unique zone ID"""
	return "zone_%d" % Time.get_ticks_msec()

func get_all_zones() -> Array[Zone]:
	"""Get all zones in the system"""
	var all_zones: Array[Zone] = []
	all_zones.append_array(creation_zones)
	all_zones.append_array(visualization_zones)
	return all_zones

func save_zone_configuration(path: String) -> void:
	"""Save current zone setup to file"""
	var config = {
		"zones": [],
		"connections": zone_connections,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	for zone in get_all_zones():
		config.zones.append(zone.serialize())
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(config, "\t"))
		file.close()
		print("💾 Saved zone configuration to: %s" % path)

func load_zone_configuration(path: String) -> void:
	"""Load zone setup from file"""
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var _config = json.data
			print("📂 Loaded zone configuration from: %s" % path)
			# TODO: Implement zone rebuilding from config
