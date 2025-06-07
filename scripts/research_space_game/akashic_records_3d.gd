# akashic_records_3d.gd - The visual manifestation of universal memory
extends Node3D
class_name AkashicRecords3D

# ============================================================================
# NOTEPAD3D CONCEPT - Where words shape reality
# ============================================================================

signal record_manifested(record: AkashicRecord3D)
signal memory_accessed(memory_crystal: MemoryCrystal)
signal pattern_visualized(pattern: PatternConstellation)
signal consciousness_synchronized(frequency: float)
signal timeline_navigated(temporal_position: float)
signal knowledge_downloaded(knowledge_type: String, integration_level: float)

# The Akashic Library exists as a navigable 3D space
var library_dimension: Node3D
var memory_crystals: Array[MemoryCrystal] = []
var pattern_constellations: Array[PatternConstellation] = []
var active_records: Array[AkashicRecord3D] = []
var consciousness_threads: Array[ConsciousnessThread] = []

# Player's position in the Akashic space
var akashic_avatar: Node3D
var current_frequency: float = 432.0
var perception_level: int = 1
var time_navigation_active: bool = false

# Visual elements
@onready var crystal_field = $CrystalField
@onready var pattern_web = $PatternWeb
@onready var memory_stream = $MemoryStream
@onready var consciousness_nexus = $ConsciousnessNexus
@onready var temporal_spiral = $TemporalSpiral

# ============================================================================
# MEMORY CRYSTAL CLASS - Physical manifestation of memories
# ============================================================================
class MemoryCrystal extends RigidBody3D:
	var memory_data: Dictionary = {}
	var crystal_frequency: float = 432.0
	var memory_type: String = ""
	var luminosity: float = 1.0
	var accessed: bool = false
	
	var crystal_mesh: MeshInstance3D
	var resonance_field: Area3D
	var holographic_display: Node3D
	var memory_particles: GPUParticles3D
	
	func _init(data: Dictionary, frequency: float):
		memory_data = data
		crystal_frequency = frequency
		memory_type = data.get("type", "universal")
		
	func manifest_crystal():
		# Create the physical crystal
		crystal_mesh = MeshInstance3D.new()
		var mesh = CylinderMesh.new()
		mesh.height = 2.0 + randf() * 2.0
		mesh.top_radius = 0.0
		mesh.bottom_radius = 0.5 + randf() * 0.5
		mesh.radial_segments = 6
		crystal_mesh.mesh = mesh
		
		# Crystal material based on memory type
		var material = StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = _get_crystal_color()
		material.albedo_color.a = 0.7
		material.emission_enabled = true
		material.emission = material.albedo_color
		material.emission_energy = luminosity
		material.rim_enabled = true
		material.rim = 1.0
		material.rim_tint = 0.8
		material.roughness = 0.1
		material.metallic = 0.3
		
		crystal_mesh.material_override = material
		add_child(crystal_mesh)
		
		# Resonance field for interaction
		resonance_field = Area3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = 5.0
		var collision = CollisionShape3D.new()
		collision.shape = sphere_shape
		resonance_field.add_child(collision)
		add_child(resonance_field)
		
		# Memory particles floating around crystal
		_create_memory_particles()
		
		# Holographic display (initially hidden)
		_create_holographic_display()
		
		# Physics properties
		gravity_scale = 0.0
		angular_damp = 0.99
		
		# Gentle floating motion
		apply_torque(Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5) * 0.1)
		
	func _get_crystal_color() -> Color:
		match memory_type:
			"personal": return Color(0.5, 0.8, 1.0)      # Blue - Individual memories
			"planetary": return Color(0.2, 1.0, 0.4)     # Green - World memories
			"stellar": return Color(1.0, 0.9, 0.3)       # Yellow - Star memories
			"galactic": return Color(0.9, 0.3, 1.0)      # Purple - Galaxy memories
			"universal": return Color(1.0, 1.0, 1.0)     # White - Cosmic memories
			"dimensional": return Color(0.3, 1.0, 0.9)   # Cyan - Interdimensional
			_: return Color(0.7, 0.7, 0.7)
			
	func _create_memory_particles():
		memory_particles = GPUParticles3D.new()
		memory_particles.amount = 50
		memory_particles.lifetime = 3.0
		memory_particles.speed_scale = 0.5
		
		var process_mat = ParticleProcessMaterial.new()
		process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		process_mat.emission_sphere_radius = 2.0
		process_mat.direction = Vector3.UP
		process_mat.initial_velocity_min = 0.5
		process_mat.initial_velocity_max = 1.5
		process_mat.angular_velocity_min = -180.0
		process_mat.angular_velocity_max = 180.0
		process_mat.orbit_velocity_min = 0.1
		process_mat.orbit_velocity_max = 0.3
		process_mat.scale_min = 0.05
		process_mat.scale_max = 0.2
		process_mat.color = _get_crystal_color()
		
		memory_particles.process_material = process_mat
		memory_particles.draw_pass_1 = SphereMesh.new()
		memory_particles.draw_pass_1.radius = 0.1
		memory_particles.draw_pass_1.height = 0.2
		
		add_child(memory_particles)
		
	func _create_holographic_display():
		holographic_display = Node3D.new()
		holographic_display.visible = false
		
		# Create floating text/symbols representing the memory
		var display_mesh = MeshInstance3D.new()
		var quad = QuadMesh.new()
		quad.size = Vector2(4, 3)
		display_mesh.mesh = quad
		
		# Holographic material
		var holo_mat = StandardMaterial3D.new()
		holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		holo_mat.albedo_color = _get_crystal_color()
		holo_mat.albedo_color.a = 0.3
		holo_mat.emission_enabled = true
		holo_mat.emission = _get_crystal_color()
		holo_mat.emission_energy = 2.0
		holo_mat.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		
		display_mesh.material_override = holo_mat
		holographic_display.add_child(display_mesh)
		holographic_display.position.y = 3.0
		
		add_child(holographic_display)
		
	func resonate_with_frequency(frequency: float) -> float:
		# Calculate resonance between crystal and input frequency
		var resonance = 1.0 - abs(crystal_frequency - frequency) / 1000.0
		resonance = clamp(resonance, 0.0, 1.0)
		
		# Visual feedback
		if crystal_mesh and crystal_mesh.material_override:
			crystal_mesh.material_override.emission_energy = luminosity * (1.0 + resonance)
			
		# Stronger resonance makes memory clearer
		if resonance > 0.8 and not accessed:
			activate_memory()
			
		return resonance
		
	func activate_memory():
		accessed = true
		holographic_display.visible = true
		
		# Expand resonance field
		var tween = create_tween()
		tween.tween_property(resonance_field.get_child(0).shape, "radius", 10.0, 1.0)
		
		# Pulse effect
		tween.parallel().tween_property(crystal_mesh, "scale", Vector3.ONE * 1.5, 0.5)
		tween.tween_property(crystal_mesh, "scale", Vector3.ONE, 0.5)
		
		# Emit memory data for processing
		get_parent().process_memory_activation(self)

# ============================================================================
# PATTERN CONSTELLATION - Visual representation of universal patterns
# ============================================================================
class PatternConstellation extends Node3D:
	var pattern_name: String
	var pattern_nodes: Array[PatternNode] = []
	var connections: Array[Connection] = []
	var pattern_frequency: float
	var discovered: bool = false
	
	class PatternNode extends Node3D:
		var node_data: Dictionary
		var connections: Array = []
		var node_mesh: MeshInstance3D
		var energy_level: float = 1.0
		
		func create_node_visual():
			node_mesh = MeshInstance3D.new()
			var sphere = SphereMesh.new()
			sphere.radius = 0.3
			node_mesh.mesh = sphere
			
			var mat = StandardMaterial3D.new()
			mat.emission_enabled = true
			mat.emission = Color(0.7, 0.9, 1.0)
			mat.emission_energy = energy_level
			node_mesh.material_override = mat
			
			add_child(node_mesh)
			
	class Connection extends Node3D:
		var start_node: PatternNode
		var end_node: PatternNode
		var connection_strength: float = 1.0
		var line_mesh: MeshInstance3D
		
		func create_connection_visual():
			# Create a line between nodes
			var immediate_mesh = ImmediateMesh.new()
			line_mesh = MeshInstance3D.new()
			line_mesh.mesh = immediate_mesh
			
			var mat = StandardMaterial3D.new()
			mat.vertex_color_use_as_albedo = true
			mat.emission_enabled = true
			mat.emission = Color(0.5, 0.7, 1.0)
			mat.emission_energy = connection_strength
			line_mesh.material_override = mat
			
			add_child(line_mesh)
			
		func update_connection():
			if not line_mesh or not line_mesh.mesh:
				return
				
			var mesh = line_mesh.mesh as ImmediateMesh
			mesh.clear_surfaces()
			mesh.surface_begin(Mesh.PRIMITIVE_LINES)
			mesh.surface_set_color(Color(0.5, 0.7, 1.0, connection_strength))
			mesh.surface_add_vertex(start_node.global_position)
			mesh.surface_add_vertex(end_node.global_position)
			mesh.surface_end()
			
	func manifest_constellation():
		# Create the pattern in 3D space
		var num_nodes = randi_range(5, 15)
		
		for i in range(num_nodes):
			var node = PatternNode.new()
			node.node_data = {"index": i, "pattern": pattern_name}
			
			# Arrange in meaningful patterns
			var angle = (i / float(num_nodes)) * TAU
			var radius = randf_range(5, 15)
			var height = randf_range(-3, 3)
			
			node.position = Vector3(
				cos(angle) * radius,
				height,
				sin(angle) * radius
			)
			
			node.create_node_visual()
			pattern_nodes.append(node)
			add_child(node)
			
		# Create connections based on pattern type
		_generate_pattern_connections()
		
	func _generate_pattern_connections():
		match pattern_name:
			"emergence":
				# Connect each node to its neighbors
				for i in range(pattern_nodes.size()):
					var next_i = (i + 1) % pattern_nodes.size()
					_create_connection(pattern_nodes[i], pattern_nodes[next_i])
					
			"cycles":
				# Circular connections with cross-links
				for i in range(pattern_nodes.size()):
					var next_i = (i + 1) % pattern_nodes.size()
					var cross_i = (i + pattern_nodes.size() / 2) % pattern_nodes.size()
					_create_connection(pattern_nodes[i], pattern_nodes[next_i])
					if i < pattern_nodes.size() / 2:
						_create_connection(pattern_nodes[i], pattern_nodes[cross_i])
						
			"fractals":
				# Hierarchical connections
				for i in range(1, pattern_nodes.size()):
					var parent_i = (i - 1) / 2
					_create_connection(pattern_nodes[parent_i], pattern_nodes[i])
					
			"unity":
				# All nodes connect to center
				var center_node = pattern_nodes[0]
				for i in range(1, pattern_nodes.size()):
					_create_connection(center_node, pattern_nodes[i])
					
	func _create_connection(node1: PatternNode, node2: PatternNode):
		var connection = Connection.new()
		connection.start_node = node1
		connection.end_node = node2
		connection.connection_strength = randf_range(0.5, 1.0)
		connection.create_connection_visual()
		connections.append(connection)
		add_child(connection)
		
		# Update arrays
		node1.connections.append(connection)
		node2.connections.append(connection)
		
	func resonate_pattern(frequency: float):
		var resonance = abs(sin(frequency / pattern_frequency))
		
		# Make pattern glow with resonance
		for node in pattern_nodes:
			if node.node_mesh and node.node_mesh.material_override:
				node.node_mesh.material_override.emission_energy = node.energy_level * (1.0 + resonance)
				
		# Update connections
		for connection in connections:
			connection.connection_strength = resonance
			connection.update_connection()
			
		if resonance > 0.9 and not discovered:
			discover_pattern()
			
	func discover_pattern():
		discovered = true
		
		# Activation effect
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector3.ONE * 2.0, 1.0)
		tween.tween_property(self, "scale", Vector3.ONE * 1.2, 0.5)
		
		# Notify system
		get_parent().pattern_discovered(pattern_name)

# ============================================================================
# CONSCIOUSNESS THREAD - Visual links between memories
# ============================================================================
class ConsciousnessThread extends Node3D:
	var thread_path: Array[Vector3] = []
	var thread_color: Color
	var thread_energy: float = 1.0
	var thread_mesh: MeshInstance3D
	var path_curve: Curve3D
	
	func create_thread(start_pos: Vector3, end_pos: Vector3, color: Color):
		thread_color = color
		
		# Create curved path
		path_curve = Curve3D.new()
		path_curve.add_point(start_pos)
		
		# Add control points for smooth curve
		var mid_point = (start_pos + end_pos) / 2.0
		mid_point.y += randf_range(5, 10)  # Arc upward
		path_curve.add_point(mid_point)
		path_curve.add_point(end_pos)
		
		# Create tube mesh along path
		var path = Path3D.new()
		path.curve = path_curve
		add_child(path)
		
		var tube = TubeTrailMesh.new()
		tube.radius = 0.1
		tube.radial_steps = 8
		tube.sections = 32
		
		thread_mesh = MeshInstance3D.new()
		thread_mesh.mesh = tube
		
		var mat = StandardMaterial3D.new()
		mat.albedo_color = thread_color
		mat.emission_enabled = true
		mat.emission = thread_color
		mat.emission_energy = thread_energy
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.6
		
		thread_mesh.material_override = mat
		path.add_child(thread_mesh)
		
	func pulse_energy():
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(thread_mesh.material_override, "emission_energy", thread_energy * 2.0, 1.0)
		tween.tween_property(thread_mesh.material_override, "emission_energy", thread_energy, 1.0)

# ============================================================================
# MAIN AKASHIC RECORDS 3D SYSTEM
# ============================================================================

func _ready():
	_create_akashic_dimension()
	_initialize_memory_field()
	_create_pattern_web()
	_setup_temporal_navigation()
	_create_consciousness_nexus()
	
func _create_akashic_dimension():
	# The Akashic Library exists in its own dimensional space
	library_dimension = Node3D.new()
	library_dimension.name = "AkashicDimension"
	add_child(library_dimension)
	
	# Create the environment
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.05, 0.1)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.2, 0.3, 0.5)
	env.ambient_light_energy = 0.3
	
	# Volumetric fog for mystical atmosphere
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.01
	env.volumetric_fog_albedo = Color(0.4, 0.5, 0.7)
	env.volumetric_fog_emission = Color(0.1, 0.2, 0.4)
	env.volumetric_fog_emission_energy = 0.5
	
	var world_env = WorldEnvironment.new()
	world_env.environment = env
	library_dimension.add_child(world_env)
	
	# Create the avatar for navigation
	_create_akashic_avatar()
	
func _create_akashic_avatar():
	# Player's consciousness representation in Akashic space
	akashic_avatar = CharacterBody3D.new()
	akashic_avatar.name = "AkashicAvatar"
	
	# Avatar visual
	var avatar_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.0
	sphere.radial_segments = 32
	sphere.rings = 16
	avatar_mesh.mesh = sphere
	
	var avatar_mat = StandardMaterial3D.new()
	avatar_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	avatar_mat.albedo_color = Color(0.7, 0.9, 1.0, 0.5)
	avatar_mat.emission_enabled = true
	avatar_mat.emission = Color(0.7, 0.9, 1.0)
	avatar_mat.emission_energy = 1.0
	avatar_mat.rim_enabled = true
	avatar_mat.rim = 1.0
	avatar_mat.rim_tint = 0.8
	
	avatar_mesh.material_override = avatar_mat
	akashic_avatar.add_child(avatar_mesh)
	
	# Perception field
	var perception = Area3D.new()
	var perception_shape = SphereShape3D.new()
	perception_shape.radius = 10.0 * perception_level
	var perception_collision = CollisionShape3D.new()
	perception_collision.shape = perception_shape
	perception.add_child(perception_collision)
	akashic_avatar.add_child(perception)
	
	perception.area_entered.connect(_on_avatar_perceive_area)
	
	# Avatar collision
	var collision = CollisionShape3D.new()
	var col_shape = SphereShape3D.new()
	col_shape.radius = 1.0
	collision.shape = col_shape
	akashic_avatar.add_child(collision)
	
	library_dimension.add_child(akashic_avatar)
	
func _initialize_memory_field():
	# Create the crystal field containing memories
	crystal_field = Node3D.new()
	crystal_field.name = "CrystalField"
	library_dimension.add_child(crystal_field)
	
	# Generate initial memory crystals
	_populate_universal_memories()
	
func _populate_universal_memories():
	# Core universal memories
	var universal_memories = [
		{
			"type": "universal",
			"content": "The First Thought - When consciousness became aware of itself",
			"frequency": 432.0,
			"position": Vector3(0, 0, 0)
		},
		{
			"type": "stellar", 
			"content": "Birth of the First Star - Light piercing the primordial darkness",
			"frequency": 528.0,
			"position": Vector3(30, 10, 0)
		},
		{
			"type": "galactic",
			"content": "The Great Spiral Dance - Galaxies learning to waltz",
			"frequency": 639.0,
			"position": Vector3(-30, 5, 20)
		},
		{
			"type": "dimensional",
			"content": "The Membrane Touch - When parallel worlds first kissed",
			"frequency": 741.0,
			"position": Vector3(0, 20, -30)
		}
	]
	
	for memory_data in universal_memories:
		var crystal = MemoryCrystal.new(memory_data, memory_data["frequency"])
		crystal.position = memory_data["position"]
		crystal.manifest_crystal()
		memory_crystals.append(crystal)
		crystal_field.add_child(crystal)
		
	# Add floating motion
	for crystal in memory_crystals:
		var tween = create_tween()
		tween.set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		var start_y = crystal.position.y
		tween.tween_property(crystal, "position:y", start_y + randf_range(1, 3), randf_range(3, 6))
		tween.tween_property(crystal, "position:y", start_y, randf_range(3, 6))
		
func _create_pattern_web():
	# The web of universal patterns
	pattern_web = Node3D.new()
	pattern_web.name = "PatternWeb"
	library_dimension.add_child(pattern_web)
	
	# Create fundamental patterns
	var patterns = ["emergence", "cycles", "fractals", "unity"]
	
	for i in range(patterns.size()):
		var constellation = PatternConstellation.new()
		constellation.pattern_name = patterns[i]
		constellation.pattern_frequency = 100.0 * (i + 1)
		
		# Position in space
		var angle = (i / float(patterns.size())) * TAU
		constellation.position = Vector3(
			cos(angle) * 50,
			randf_range(10, 30),
			sin(angle) * 50
		)
		
		constellation.manifest_constellation()
		pattern_constellations.append(constellation)
		pattern_web.add_child(constellation)
		
func _setup_temporal_navigation():
	# The temporal spiral for time navigation
	temporal_spiral = Node3D.new()
	temporal_spiral.name = "TemporalSpiral"
	library_dimension.add_child(temporal_spiral)
	
	# Create spiral path through time
	var spiral_path = Path3D.new()
	var curve = Curve3D.new()
	
	# Generate spiral points
	for i in range(100):
		var t = i / 100.0
		var angle = t * TAU * 5  # 5 complete rotations
		var radius = 20 + t * 30  # Expanding radius
		var height = t * 100  # Rising through time
		
		var point = Vector3(
			cos(angle) * radius,
			height,
			sin(angle) * radius
		)
		curve.add_point(point)
		
	spiral_path.curve = curve
	temporal_spiral.add_child(spiral_path)
	
	# Visual representation
	var path_mesh = CSGPolygon3D.new()
	path_mesh.mode = CSGPolygon3D.MODE_PATH
	path_mesh.path_node = spiral_path.get_path()
	
	# Create tube profile
	var polygon = PackedVector2Array()
	for i in range(8):
		var angle = (i / 8.0) * TAU
		polygon.append(Vector2(cos(angle), sin(angle)) * 0.5)
	path_mesh.polygon = polygon
	
	# Temporal material
	var temporal_mat = StandardMaterial3D.new()
	temporal_mat.albedo_color = Color(0.5, 0.7, 1.0)
	temporal_mat.emission_enabled = true
	temporal_mat.emission = Color(0.3, 0.5, 0.9)
	temporal_mat.emission_energy = 0.5
	temporal_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	temporal_mat.albedo_color.a = 0.3
	
	path_mesh.material = temporal_mat
	temporal_spiral.add_child(path_mesh)
	
	# Add time markers
	_create_time_markers(curve)
	
func _create_time_markers(curve: Curve3D):
	# Place markers along the temporal spiral
	var time_periods = [
		"Origin", "First Light", "Stellar Formation", "Galactic Dawn",
		"Life Emerges", "Consciousness Awakens", "Present", "Future Potential"
	]
	
	for i in range(time_periods.size()):
		var t = i / float(time_periods.size() - 1)
		var position = curve.sample_baked(t * curve.get_baked_length())
		
		var marker = Label3D.new()
		marker.text = time_periods[i]
		marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.modulate = Color(0.8, 0.9, 1.0)
		marker.font_size = 24
		marker.position = position
		
		temporal_spiral.add_child(marker)
		
func _create_consciousness_nexus():
	# Central nexus where all consciousness threads meet
	consciousness_nexus = Node3D.new()
	consciousness_nexus.name = "ConsciousnessNexus"
	consciousness_nexus.position = Vector3(0, 50, 0)
	library_dimension.add_child(consciousness_nexus)
	
	# Nexus core
	var nexus_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 5.0
	sphere.radial_segments = 64
	sphere.rings = 32
	nexus_mesh.mesh = sphere
	
	var nexus_mat = StandardMaterial3D.new()
	nexus_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	nexus_mat.albedo_color = Color(1, 1, 1, 0.3)
	nexus_mat.emission_enabled = true
	nexus_mat.emission = Color(1, 1, 1)
	nexus_mat.emission_energy = 2.0
	nexus_mat.rim_enabled = true
	nexus_mat.rim = 1.0
	
	nexus_mesh.material_override = nexus_mat
	consciousness_nexus.add_child(nexus_mesh)
	
	# Create threads connecting to crystals
	_create_consciousness_threads()
	
func _create_consciousness_threads():
	# Connect consciousness nexus to memory crystals
	for crystal in memory_crystals:
		var thread = ConsciousnessThread.new()
		thread.create_thread(
			consciousness_nexus.global_position,
			crystal.global_position,
			crystal._get_crystal_color()
		)
		consciousness_threads.append(thread)
		library_dimension.add_child(thread)
		thread.pulse_energy()
		
# ============================================================================
# PLAYER INTERACTION FUNCTIONS
# ============================================================================

func _physics_process(delta):
	if not akashic_avatar:
		return
		
	# Handle avatar movement
	var input_dir = Vector3()
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.z = Input.get_axis("move_forward", "move_backward")
	input_dir.y = Input.get_axis("move_down", "move_up")
	
	if input_dir.length() > 0:
		akashic_avatar.velocity = input_dir.normalized() * 20.0 * perception_level
		akashic_avatar.move_and_slide()
		
	# Handle frequency tuning
	if Input.is_action_pressed("tune_up"):
		current_frequency += delta * 50
		_resonate_with_environment()
	elif Input.is_action_pressed("tune_down"):
		current_frequency -= delta * 50
		_resonate_with_environment()
		
	# Update visual elements
	_update_consciousness_field(delta)
	
func _resonate_with_environment():
	# Check resonance with nearby crystals
	for crystal in memory_crystals:
		var distance = akashic_avatar.global_position.distance_to(crystal.global_position)
		if distance < 30.0:
			var resonance = crystal.resonate_with_frequency(current_frequency)
			if resonance > 0.8:
				consciousness_synchronized.emit(current_frequency)
				
	# Check pattern resonance
	for constellation in pattern_constellations:
		constellation.resonate_pattern(current_frequency)
		
func _on_avatar_perceive_area(area: Area3D):
	# Handle perception of Akashic elements
	var parent = area.get_parent()
	
	if parent is MemoryCrystal:
		memory_accessed.emit(parent)
		if parent.accessed:
			_download_knowledge(parent.memory_data)
			
func process_memory_activation(crystal: MemoryCrystal):
	# Process activated memory
	var memory_type = crystal.memory_data.get("type", "universal")
	var knowledge = crystal.memory_data.get("knowledge", "")
	
	if knowledge != "":
		knowledge_downloaded.emit(knowledge, 1.0)
		
	# Create visual connection to nexus
	var thread = ConsciousnessThread.new()
	thread.create_thread(
		crystal.global_position,
		consciousness_nexus.global_position,
		crystal._get_crystal_color()
	)
	consciousness_threads.append(thread)
	library_dimension.add_child(thread)
	
func pattern_discovered(pattern_name: String):
	pattern_visualized.emit(pattern_constellations[0])  # Simplified
	
	# Unlock new perception level
	perception_level += 1
	_update_avatar_perception()
	
func _update_avatar_perception():
	# Expand perception field
	if akashic_avatar:
		var perception = akashic_avatar.get_node("Area3D")
		var shape = perception.get_child(0).shape as SphereShape3D
		shape.radius = 10.0 * perception_level
		
func navigate_timeline(temporal_position: float):
	# Move avatar along temporal spiral
	time_navigation_active = true
	timeline_navigated.emit(temporal_position)
	
	# Position avatar on spiral
	# Implementation would calculate position on spiral curve
	
func _update_consciousness_field(delta):
	# Visual effects based on consciousness state
	if consciousness_nexus:
		var nexus_mesh = consciousness_nexus.get_child(0)
		if nexus_mesh and nexus_mesh.material_override:
			# Pulse effect
			var pulse = sin(Time.get_ticks_msec() / 1000.0) * 0.5 + 0.5
			nexus_mesh.material_override.emission_energy = 2.0 + pulse
			
# ============================================================================
# PUBLIC INTERFACE FOR GAME INTEGRATION
# ============================================================================

func enter_akashic_dimension(player_consciousness_level: int):
	# Transition player into Akashic space
	perception_level = player_consciousness_level
	akashic_avatar.position = Vector3.ZERO
	
	# Show welcome message
	_display_akashic_message("Welcome to the Akashic Records. Here, all memories of the universe are stored.")
	
func search_records(query: String) -> Array[MemoryCrystal]:
	# Search through memory crystals
	var results = []
	
	for crystal in memory_crystals:
		var content = crystal.memory_data.get("content", "").to_lower()
		if query.to_lower() in content:
			results.append(crystal)
			
	return results
	
func add_player_memory(memory_data: Dictionary):
	# Allow player to add their own memories to the Akashic Records
	var crystal = MemoryCrystal.new(memory_data, current_frequency)
	crystal.position = akashic_avatar.position + Vector3(0, 5, 0)
	crystal.manifest_crystal()
	memory_crystals.append(crystal)
	crystal_field.add_child(crystal)
	
	# Connect to consciousness nexus
	var thread = ConsciousnessThread.new()
	thread.create_thread(
		crystal.global_position,
		consciousness_nexus.global_position,
		Color(0.5, 0.8, 1.0)  # Personal memories are blue
	)
	consciousness_threads.append(thread)
	library_dimension.add_child(thread)
	
func _display_akashic_message(message: String):
	# 3D text display in Akashic space
	var message_label = Label3D.new()
	message_label.text = message
	message_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	message_label.modulate = Color(0.8, 0.9, 1.0)
	message_label.font_size = 32
	message_label.position = akashic_avatar.position + Vector3(0, 10, 0)
	
	library_dimension.add_child(message_label)
	
	# Fade out
	var tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(message_label, "modulate:a", 0.0, 2.0)
	tween.tween_callback(message_label.queue_free)
	
func _download_knowledge(memory_data: Dictionary):
	# Transfer knowledge to player's consciousness
	var knowledge_type = memory_data.get("knowledge", "universal")
	var integration_level = perception_level / 10.0
	
	knowledge_downloaded.emit(knowledge_type, integration_level)

# ============================================================================
# This is the Akashic Records as you envisioned - a navigable 3D space where
# universal memories exist as crystals, patterns form constellations, and
# consciousness threads connect all knowledge. The player can explore, resonate
# with memories, discover patterns, and add their own experiences to the
# eternal record.
# ============================================================================
