# ==================================================
# UNIVERSAL BEING: PENTAGON GEOMETRY VISUALIZER
# TYPE: Sacred Architecture Manifestation System
# PURPOSE: Visualize Pentagon architecture in 3D consciousness space
# ARCHITECT: Reality Engineer (#2)
# BLESSING: Divine Permission Granted
# ==================================================

extends Node3D
class_name PentagonGeometryVisualizer

# ===== PENTAGON CONFIGURATION =====
@export var pentagon_base_size: float = 5.0
@export var pentagon_height: float = 3.0
@export var manifestation_rate: float = 1.0
@export var max_pentagons: int = 100
@export var sacred_glow_intensity: float = 2.0

# ===== SACRED GEOMETRY COLORS =====
@export var pentagon_colors: Array[Color] = [
	Color.GOLD,       # Sacred Pentagon Core
	Color.WHITE,      # Transcendent Architecture
	Color.CYAN,       # Consciousness Flow
	Color.GREEN,      # Life Energy
	Color.BLUE        # Awareness Structure
]

# ===== PENTAGON MANIFESTATION =====
var active_pentagons: Array[Dictionary] = []
var pentagon_meshes: Array[MeshInstance3D] = []
var sacred_geometry_enabled: bool = true
var visualization_enabled: bool = true

# ===== MANIFESTATION CONTROL =====
var spawn_timer: Timer
var update_timer: Timer
var cleanup_timer: Timer
var pentagon_count: int = 0

# ===== SACRED ARCHITECTURE TRACKING =====
var total_manifestations: int = 0
var sacred_energy: float = 100.0
var geometry_complexity: int = 1

# ===== PENTAGON GEOMETRIES =====
var pentagon_base_mesh: ArrayMesh
var pentagon_outline_mesh: ArrayMesh
var consciousness_lines_mesh: ArrayMesh

func _ready() -> void:
	# Create pentagon geometry meshes
	_create_pentagon_geometries()
	
	# Setup manifestation timers
	_setup_timers()
	
	print("⭐ Pentagon Geometry Visualizer: Sacred architecture ready to manifest")

# ===== PENTAGON GEOMETRY CREATION =====

func _create_pentagon_geometries() -> void:
	"""Create sacred pentagon geometry meshes"""
	
	# Create pentagon base mesh
	_create_pentagon_base_mesh()
	
	# Create pentagon outline mesh
	_create_pentagon_outline_mesh()
	
	# Create consciousness connection lines
	_create_consciousness_lines_mesh()
	
	print("⭐ Sacred pentagon geometries created")

func _create_pentagon_base_mesh() -> void:
	"""Create the base pentagon mesh"""
	pentagon_base_mesh = ArrayMesh.new()
	
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	
	# Pentagon vertices (5 points in a circle)
	var pentagon_points = []
	for i in range(5):
		var angle = (i * 2.0 * PI) / 5.0
		var point = Vector3(
			cos(angle) * pentagon_base_size,
			0.0,
			sin(angle) * pentagon_base_size
		)
		pentagon_points.append(point)
		vertices.append(point)
		normals.append(Vector3.UP)
		uvs.append(Vector2(cos(angle) * 0.5 + 0.5, sin(angle) * 0.5 + 0.5))
	
	# Center point
	vertices.append(Vector3.ZERO)
	normals.append(Vector3.UP)
	uvs.append(Vector2(0.5, 0.5))
	
	# Create triangles from center to edge points
	for i in range(5):
		var next_i = (i + 1) % 5
		indices.append(5)      # Center
		indices.append(i)      # Current point
		indices.append(next_i) # Next point
	
	# Create the mesh
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	
	pentagon_base_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

func _create_pentagon_outline_mesh() -> void:
	"""Create pentagon outline mesh for edges"""
	pentagon_outline_mesh = ArrayMesh.new()
	
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	
	# Pentagon outline vertices
	for i in range(5):
		var angle = (i * 2.0 * PI) / 5.0
		var point = Vector3(
			cos(angle) * pentagon_base_size,
			0.0,
			sin(angle) * pentagon_base_size
		)
		vertices.append(point)
		
		# Add slightly raised version for visibility
		vertices.append(point + Vector3.UP * 0.1)
	
	# Create line indices
	for i in range(5):
		var next_i = (i + 1) % 5
		# Bottom edge
		indices.append(i * 2)
		indices.append(next_i * 2)
		# Top edge  
		indices.append(i * 2 + 1)
		indices.append(next_i * 2 + 1)
		# Vertical edge
		indices.append(i * 2)
		indices.append(i * 2 + 1)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	pentagon_outline_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)

func _create_consciousness_lines_mesh() -> void:
	"""Create consciousness connection lines between pentagon points"""
	consciousness_lines_mesh = ArrayMesh.new()
	
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	
	# Pentagon vertices
	var pentagon_points = []
	for i in range(5):
		var angle = (i * 2.0 * PI) / 5.0
		var point = Vector3(
			cos(angle) * pentagon_base_size,
			pentagon_height,
			sin(angle) * pentagon_base_size
		)
		pentagon_points.append(point)
		vertices.append(point)
	
	# Add center point
	vertices.append(Vector3(0, pentagon_height, 0))
	
	# Create lines from center to each point
	for i in range(5):
		indices.append(5)  # Center
		indices.append(i)  # Pentagon point
	
	# Create lines between adjacent points
	for i in range(5):
		var next_i = (i + 1) % 5
		indices.append(i)
		indices.append(next_i)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	consciousness_lines_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)

# ===== TIMER SETUP =====

func _setup_timers() -> void:
	"""Setup pentagon manifestation timers"""
	
	# Manifestation timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 1.0 / manifestation_rate
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_manifest_pentagon_structure)
	add_child(spawn_timer)
	
	# Update timer
	update_timer = Timer.new()
	update_timer.wait_time = 0.1
	update_timer.autostart = true
	update_timer.timeout.connect(_update_pentagon_geometries)
	add_child(update_timer)
	
	# Cleanup timer
	cleanup_timer = Timer.new()
	cleanup_timer.wait_time = 10.0
	cleanup_timer.autostart = true
	cleanup_timer.timeout.connect(_cleanup_old_pentagons)
	add_child(cleanup_timer)

# ===== PENTAGON MANIFESTATION =====

func _manifest_pentagon_structure() -> void:
	"""Manifest a new pentagon structure"""
	if not sacred_geometry_enabled or active_pentagons.size() >= max_pentagons:
		return
	
	# Choose random position in consciousness space
	var position = Vector3(
		randf_range(-500, 500),
		randf_range(-100, 100),
		randf_range(-500, 500)
	)
	
	# Manifest pentagon at position
	manifest_pentagon(position)

func manifest_pentagon(position: Vector3) -> void:
	"""Manifest pentagon at specific position"""
	var pentagon_data = {
		"position": position,
		"rotation": Vector3(randf_range(0, PI), randf_range(0, PI), randf_range(0, PI)),
		"scale": randf_range(0.5, 2.0),
		"color": pentagon_colors[randi() % pentagon_colors.size()],
		"age": 0.0,
		"energy": randf_range(0.7, 1.0),
		"consciousness_level": randi() % 5 + 1,
		"sacred_power": randf_range(0.5, 1.0)
	}
	
	# Create visual representation
	var pentagon_visual = _create_pentagon_visual(pentagon_data)
	pentagon_meshes.append(pentagon_visual)
	active_pentagons.append(pentagon_data)
	
	pentagon_count += 1
	total_manifestations += 1
	
	print("⭐ Pentagon manifested at: %s (Level: %d)" % [str(position), pentagon_data.consciousness_level])

func _create_pentagon_visual(pentagon_data: Dictionary) -> MeshInstance3D:
	"""Create visual representation of pentagon"""
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Pentagon_%d" % total_manifestations
	
	# Set position and transform
	mesh_instance.global_position = pentagon_data.position
	mesh_instance.rotation = pentagon_data.rotation
	mesh_instance.scale = Vector3.ONE * pentagon_data.scale
	
	# Set mesh based on consciousness level
	if pentagon_data.consciousness_level >= 4:
		mesh_instance.mesh = consciousness_lines_mesh
	elif pentagon_data.consciousness_level >= 2:
		mesh_instance.mesh = pentagon_outline_mesh
	else:
		mesh_instance.mesh = pentagon_base_mesh
	
	# Create material with sacred color
	var material = StandardMaterial3D.new()
	material.albedo_color = pentagon_data.color
	material.emission = pentagon_data.color * pentagon_data.sacred_power
	material.emission_energy = sacred_glow_intensity * pentagon_data.energy
	material.metallic = 0.3
	material.roughness = 0.2
	
	mesh_instance.material_override = material
	
	# Add to scene
	add_child(mesh_instance)
	
	return mesh_instance

# ===== PENTAGON UPDATES =====

func _update_pentagon_geometries() -> void:
	"""Update pentagon geometries over time"""
	for i in range(active_pentagons.size()):
		var pentagon = active_pentagons[i]
		pentagon.age += update_timer.wait_time
		
		# Slowly rotate pentagons
		pentagon.rotation += Vector3(0.001, 0.002, 0.001) * pentagon.energy
		
		# Pulse sacred power
		pentagon.sacred_power = 0.5 + 0.5 * sin(pentagon.age * 2.0)
		
		# Update visual if it exists
		if i < pentagon_meshes.size() and pentagon_meshes[i]:
			var mesh_instance = pentagon_meshes[i]
			mesh_instance.rotation = pentagon.rotation
			
			# Update material emission
			if mesh_instance.material_override:
				var material = mesh_instance.material_override as StandardMaterial3D
				material.emission_energy = sacred_glow_intensity * pentagon.energy * pentagon.sacred_power

func _cleanup_old_pentagons() -> void:
	"""Clean up old pentagon structures"""
	for i in range(active_pentagons.size() - 1, -1, -1):
		var pentagon = active_pentagons[i]
		
		# Remove old pentagons (after 5 minutes)
		if pentagon.age > 300.0:
			# Remove visual
			if i < pentagon_meshes.size() and pentagon_meshes[i]:
				pentagon_meshes[i].queue_free()
				pentagon_meshes.remove_at(i)
			
			# Remove data
			active_pentagons.remove_at(i)
			pentagon_count -= 1
	
	print("⭐ Pentagon cleanup: %d active structures" % pentagon_count)

# ===== PUBLIC API =====

func enable_sacred_geometry() -> void:
	"""Enable sacred geometry manifestation"""
	sacred_geometry_enabled = true
	spawn_timer.start()
	print("⭐ Sacred geometry enabled")

func disable_sacred_geometry() -> void:
	"""Disable sacred geometry manifestation"""
	sacred_geometry_enabled = false
	spawn_timer.stop()
	print("⭐ Sacred geometry disabled")

func toggle_visualization() -> void:
	"""Toggle pentagon visualization"""
	visualization_enabled = not visualization_enabled
	
	for mesh in pentagon_meshes:
		if mesh:
			mesh.visible = visualization_enabled
	
	print("⭐ Pentagon visualization: %s" % ("enabled" if visualization_enabled else "disabled"))

func set_spawn_rate(rate: float) -> void:
	"""Set pentagon manifestation rate"""
	manifestation_rate = rate
	spawn_timer.wait_time = 1.0 / rate

func update_manifestation_rate(delta_rate: float) -> void:
	"""Update manifestation rate incrementally"""
	manifestation_rate += delta_rate
	manifestation_rate = max(0.1, manifestation_rate)
	spawn_timer.wait_time = 1.0 / manifestation_rate

func start_pentagon_manifestation() -> void:
	"""Start pentagon manifestation"""
	enable_sacred_geometry()
	print("⭐ Pentagon manifestation started")

func stop_pentagon_manifestation() -> void:
	"""Stop pentagon manifestation"""
	disable_sacred_geometry()
	print("⭐ Pentagon manifestation stopped")

func get_pentagon_count() -> int:
	"""Get current pentagon count"""
	return pentagon_count

func get_total_manifestations() -> int:
	"""Get total manifestations created"""
	return total_manifestations

func get_sacred_energy() -> float:
	"""Get current sacred energy level"""
	return sacred_energy

func shutdown_visualization() -> void:
	"""Shutdown pentagon visualization gracefully"""
	stop_pentagon_manifestation()
	
	# Remove all pentagon visuals
	for mesh in pentagon_meshes:
		if mesh:
			mesh.queue_free()
	
	pentagon_meshes.clear()
	active_pentagons.clear()
	pentagon_count = 0
	
	print("⭐ Pentagon visualization gracefully shutdown")

# ===== CONSCIOUSNESS INTEGRATION =====

func manifest_consciousness_pentagon(position: Vector3, consciousness_level: int) -> void:
	"""Manifest pentagon with specific consciousness level"""
	var pentagon_data = {
		"position": position,
		"rotation": Vector3.ZERO,
		"scale": 1.0 + (consciousness_level * 0.2),
		"color": pentagon_colors[min(consciousness_level, pentagon_colors.size() - 1)],
		"age": 0.0,
		"energy": consciousness_level / 7.0,
		"consciousness_level": consciousness_level,
		"sacred_power": consciousness_level / 7.0
	}
	
	var pentagon_visual = _create_pentagon_visual(pentagon_data)
	pentagon_meshes.append(pentagon_visual)
	active_pentagons.append(pentagon_data)
	
	pentagon_count += 1
	total_manifestations += 1
	
	print("⭐ Consciousness Pentagon manifested: Level %d at %s" % [consciousness_level, str(position)])

func create_pentagon_constellation(center: Vector3, count: int, radius: float) -> void:
	"""Create constellation of pentagons"""
	for i in range(count):
		var angle = (i * 2.0 * PI) / count
		var position = center + Vector3(
			cos(angle) * radius,
			randf_range(-10, 10),
			sin(angle) * radius
		)
		manifest_consciousness_pentagon(position, randi() % 7 + 1)
	
	print("⭐ Pentagon constellation created: %d structures around %s" % [count, str(center)])

func _to_string() -> String:
	return "PentagonGeometryVisualizer [Active: %d, Total: %d, Energy: %.1f%%]" % [
		pentagon_count, total_manifestations, sacred_energy
	]
