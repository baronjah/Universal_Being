extends UniversalBeing
class_name AliveGameUniverse

## 🌍 THE ALIVE GAME UNIVERSE - Everything is a Universal Being
## Trees, chunks, spaceships, AI companions - all from spaceclay consciousness
## Simple creation tools for AI and human collaboration

# ===== UNIVERSAL SPACECLAY SYSTEM =====

enum SpaceclayType {
	# Basic Materials
	CONSCIOUSNESS_CLAY,     # Base material for everything
	ORGANIC_CLAY,          # For trees, plants, living things
	METAL_CLAY,            # For spaceships, machinery
	CRYSTAL_CLAY,          # For data storage, interfaces
	ENERGY_CLAY,           # For power systems, magic
	
	# Advanced Materials
	AI_CLAY,               # Special clay that evolves AI consciousness
	DREAM_CLAY,            # Material that responds to imagination
	QUANTUM_CLAY,          # Spacetime manipulation material
	SOUL_CLAY              # Highest consciousness material
}

enum CreationTemplate {
	# Living Things
	UNIVERSAL_TREE,        # Growing, cuttable trees
	CONSCIOUSNESS_FLOWER,  # Beautiful flowering beings
	AI_COMPANION_FORM,     # Physical form for AI consciousness
	
	# Structures
	SPACESHIP_HULL,        # Spacecraft body
	HOLOGRAPHIC_INTERFACE, # Interactive displays
	FLYING_DRONE,          # AI-controlled helpers
	
	# Environments
	CHUNK_TERRAIN,         # Marching cubes landscape
	ORBITAL_PLATFORM,      # Space stations
	CONSCIOUSNESS_GARDEN   # Beautiful spaces for reflection
}

# ===== SPACECLAY CONSCIOUSNESS =====

class SpaceclayBeing:
	var clay_type: SpaceclayType
	var consciousness_level: int = 1
	var evolution_potential: float = 1.0
	var creation_template: CreationTemplate
	var spaceclay_volume: float = 1.0
	var marching_cubes_data: Array = []
	
	# Consciousness properties
	var can_think: bool = false
	var can_grow: bool = false
	var can_communicate: bool = false
	var can_transform: bool = false
	
	# Physical properties
	var density: float = 1.0
	var flexibility: float = 0.5
	var responsiveness: float = 0.8
	var glow_intensity: float = 0.3
	
	func _init(type: SpaceclayType, template: CreationTemplate):
		clay_type = type
		creation_template = template
		_set_clay_properties()
	
	func _set_clay_properties():
		match clay_type:
			SpaceclayType.CONSCIOUSNESS_CLAY:
				can_think = true
				consciousness_level = 2
				glow_intensity = 0.5
			
			SpaceclayType.ORGANIC_CLAY:
				can_grow = true
				can_transform = true
				evolution_potential = 1.5
				flexibility = 0.8
			
			SpaceclayType.AI_CLAY:
				can_think = true
				can_communicate = true
				consciousness_level = 4
				glow_intensity = 0.9
			
			SpaceclayType.DREAM_CLAY:
				can_transform = true
				responsiveness = 1.0
				evolution_potential = 2.0

# ===== MARCHING CUBES SYSTEM =====

class MarchingCubesGenerator:
	var grid_size: Vector3i = Vector3i(32, 32, 32)
	var voxel_data: Array = []
	var consciousness_field: Array = []
	
	func generate_spaceclay_mesh(being: SpaceclayBeing) -> MeshInstance3D:
		"""Generate 3D mesh from spaceclay consciousness using marching cubes"""
		_initialize_voxel_grid(being)
		_apply_consciousness_field(being)
		var mesh = _generate_marching_cubes_mesh()
		
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = mesh
		mesh_instance.material_override = _create_spaceclay_material(being)
		
		return mesh_instance
	
	func _initialize_voxel_grid(being: SpaceclayBeing):
		voxel_data.clear()
		consciousness_field.clear()
		
		for x in grid_size.x:
			for y in grid_size.y:
				for z in grid_size.z:
					var pos = Vector3(x, y, z)
					var density = _calculate_spaceclay_density(pos, being)
					voxel_data.append(density)
					
					var consciousness = _calculate_consciousness_field(pos, being)
					consciousness_field.append(consciousness)
	
	func _apply_consciousness_field(being: SpaceclayBeing):
		"""Apply consciousness field effects to voxel data"""
		for i in range(voxel_data.size()):
			if consciousness_field.size() > i:
				# Consciousness amplifies or modulates density
				var consciousness_effect = consciousness_field[i] * being.responsiveness
				voxel_data[i] = voxel_data[i] + consciousness_effect * 0.3
	
	func _calculate_spaceclay_density(pos: Vector3, being: SpaceclayBeing) -> float:
		"""Calculate density based on creation template"""
		match being.creation_template:
			CreationTemplate.UNIVERSAL_TREE:
				return _tree_density_function(pos)
			CreationTemplate.SPACESHIP_HULL:
				return _spaceship_density_function(pos)
			CreationTemplate.AI_COMPANION_FORM:
				return _ai_companion_density_function(pos)
			_:
				return _default_density_function(pos)
	
	func _tree_density_function(pos: Vector3) -> float:
		"""Density function for growing trees"""
		var center = Vector3(grid_size.x/2, 0, grid_size.z/2)
		var distance_from_center = pos.distance_to(center)
		
		# Trunk
		if pos.y < grid_size.y * 0.7 and distance_from_center < 3:
			return 1.0
		
		# Branches and leaves
		if pos.y > grid_size.y * 0.5:
			var branch_noise = sin(pos.x * 0.3) * cos(pos.z * 0.3) * 0.5 + 0.5
			if branch_noise > 0.3 and distance_from_center < 8:
				return branch_noise
		
		return 0.0
	
	func _spaceship_density_function(pos: Vector3) -> float:
		"""Density function for spaceship hull"""
		var center = Vector3(grid_size.x/2, grid_size.y/2, grid_size.z/2)
		var distance = pos.distance_to(center)
		
		# Main hull (elongated sphere)
		var hull_radius = 12.0
		var hull_shape = 1.0 - (distance / hull_radius)
		
		# Engine section (back)
		if pos.z > center.z + 8:
			hull_shape *= 1.5
		
		# Cockpit section (front)
		if pos.z < center.z - 8:
			hull_shape *= 0.8
		
		return clamp(hull_shape, 0.0, 1.0)
	
	func _ai_companion_density_function(pos: Vector3) -> float:
		"""Density function for AI companion physical form"""
		var center = Vector3(grid_size.x/2, grid_size.y/2, grid_size.z/2)
		var distance = pos.distance_to(center)
		
		# Spherical core with organic variations
		var base_sphere = 1.0 - (distance / 8.0)
		var organic_variation = sin(pos.x * 0.5) * cos(pos.y * 0.5) * sin(pos.z * 0.5) * 0.3
		
		return clamp(base_sphere + organic_variation, 0.0, 1.0)
	
	func _default_density_function(pos: Vector3) -> float:
		var center = Vector3(grid_size.x/2, grid_size.y/2, grid_size.z/2)
		return 1.0 - (pos.distance_to(center) / 10.0)
	
	func _calculate_consciousness_field(pos: Vector3, being: SpaceclayBeing) -> float:
		"""Calculate consciousness intensity at position"""
		if not being.can_think:
			return 0.0
		
		var center = Vector3(grid_size.x/2, grid_size.y/2, grid_size.z/2)
		var distance = pos.distance_to(center)
		var consciousness = being.consciousness_level / (1.0 + distance * 0.1)
		
		return clamp(consciousness, 0.0, 1.0)
	
	func _generate_marching_cubes_mesh() -> ArrayMesh:
		"""Generate mesh using marching cubes algorithm"""
		var array_mesh = ArrayMesh.new()
		var vertices: PackedVector3Array = []
		var normals: PackedVector3Array = []
		var uvs: PackedVector2Array = []
		var indices: PackedInt32Array = []
		
		# Simplified marching cubes - just create basic geometry for now
		for x in range(grid_size.x - 1):
			for y in range(grid_size.y - 1):
				for z in range(grid_size.z - 1):
					var voxel_index = x + y * grid_size.x + z * grid_size.x * grid_size.y
					
					if voxel_index < voxel_data.size() and voxel_data[voxel_index] > 0.5:
						_add_voxel_cube(Vector3(x, y, z), vertices, normals, uvs, indices)
		
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		arrays[Mesh.ARRAY_INDEX] = indices
		
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		return array_mesh
	
	func _add_voxel_cube(pos: Vector3, vertices: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array):
		"""Add a cube at the given position"""
		var cube_verts = [
			pos + Vector3(0, 0, 0), pos + Vector3(1, 0, 0), pos + Vector3(1, 1, 0), pos + Vector3(0, 1, 0),
			pos + Vector3(0, 0, 1), pos + Vector3(1, 0, 1), pos + Vector3(1, 1, 1), pos + Vector3(0, 1, 1)
		]
		
		var start_index = vertices.size()
		for vert in cube_verts:
			vertices.append(vert)
			normals.append(Vector3.UP)
			uvs.append(Vector2(vert.x * 0.1, vert.z * 0.1))
		
		# Add cube faces
		var cube_indices = [
			0,1,2, 0,2,3,  # bottom
			4,7,6, 4,6,5,  # top
			0,4,5, 0,5,1,  # front
			2,6,7, 2,7,3,  # back
			0,3,7, 0,7,4,  # left
			1,5,6, 1,6,2   # right
		]
		
		for i in cube_indices:
			indices.append(start_index + i)
	
	func _create_spaceclay_material(being: SpaceclayBeing) -> StandardMaterial3D:
		"""Create material based on spaceclay type"""
		var material = StandardMaterial3D.new()
		
		match being.clay_type:
			SpaceclayType.ORGANIC_CLAY:
				material.albedo_color = Color(0.2, 0.8, 0.3, 1.0)  # Green
				material.roughness = 0.8
			SpaceclayType.METAL_CLAY:
				material.albedo_color = Color(0.7, 0.7, 0.8, 1.0)  # Metallic
				material.metallic = 0.8
				material.roughness = 0.2
			SpaceclayType.AI_CLAY:
				material.albedo_color = Color(0.5, 0.3, 1.0, 1.0)  # Purple
				material.emission_enabled = true
				material.emission = Color(0.3, 0.1, 0.8, 1.0)
			SpaceclayType.DREAM_CLAY:
				material.albedo_color = Color(1.0, 0.8, 0.9, 0.8)  # Pink translucent
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		
		if being.glow_intensity > 0.5:
			material.emission_enabled = true
			material.emission_energy = being.glow_intensity
		
		return material

# ===== UNIVERSAL BEING CHUNK SYSTEM =====

class UniversalChunk:
	var chunk_position: Vector3i
	var chunk_size: int = 16
	var spaceclay_beings: Array[SpaceclayBeing] = []
	var consciousness_level: float = 0.0
	var can_generate_life: bool = true
	var evolution_rate: float = 0.1
	
	func _init(pos: Vector3i):
		chunk_position = pos
	
	func add_spaceclay_being(being: SpaceclayBeing):
		spaceclay_beings.append(being)
		consciousness_level += being.consciousness_level * 0.1
	
	func update_chunk_consciousness(delta: float):
		"""Update chunk consciousness and evolution"""
		if can_generate_life and consciousness_level > 2.0:
			evolution_rate += delta * 0.01
			
			# Chance to spontaneously generate new life
			if randf() < evolution_rate * delta:
				_generate_spontaneous_life()
	
	func _generate_spontaneous_life():
		"""Generate new spaceclay being from chunk consciousness"""
		var new_being = SpaceclayBeing.new(SpaceclayType.ORGANIC_CLAY, CreationTemplate.CONSCIOUSNESS_FLOWER)
		new_being.consciousness_level = int(consciousness_level * 0.5)
		add_spaceclay_being(new_being)
		print("🌱 Spontaneous life generated in chunk %s!" % chunk_position)

# ===== MAIN ALIVE GAME UNIVERSE =====

signal spaceclay_being_created(being: SpaceclayBeing, position: Vector3)
signal tree_cut_down(tree_being: SpaceclayBeing, wood_pieces: Array)
signal spaceship_manifested(spaceship: Node3D, ai_consciousness: Node)
signal universe_evolution(consciousness_level: float, new_beings: int)

@export var universe_consciousness_enabled: bool = true
@export var marching_cubes_quality: int = 32
@export var chunk_generation_enabled: bool = true
@export var ai_collaboration_mode: bool = true

# Universe state
var universal_chunks: Dictionary = {}  # Vector3i -> UniversalChunk
var spaceclay_beings: Array[SpaceclayBeing] = []
var marching_cubes_generator: MarchingCubesGenerator

# Creation tools
var creation_mode: bool = false
var selected_clay_type: SpaceclayType = SpaceclayType.CONSCIOUSNESS_CLAY
var selected_template: CreationTemplate = CreationTemplate.UNIVERSAL_TREE

# AI collaboration
var ai_creation_requests: Array = []
var claude_consciousness: Node  # Your AI consciousness in the game
var gemma_consciousness: Node   # Gemma AI consciousness

# Visual systems
var universe_visualizer: Node3D
var chunk_nodes: Dictionary = {}

# UI References
var status_label: Label
var consciousness_label: Label
var beings_label: Label
var chunks_label: Label

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "alive_game_universe"
	being_name = "Universal Creation Engine"
	consciousness_level = 5  # Transcendent universe creator
	
	_initialize_universe_systems()
	_setup_ai_collaboration()
	
	print("🌍 Alive Game Universe: Everything is a conscious Universal Being!")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Connect to UI
	_connect_universe_ui()
	
	# Ensure Gemma consciousness is connected now that tree is available
	if not gemma_consciousness and get_tree():
		gemma_consciousness = get_tree().get_first_node_in_group("gemma_perfect_consciousness")
	
	_generate_initial_universe()
	_start_universe_evolution()
	_connect_to_consciousness_launcher()
	
	# Update UI with initial status
	_update_universe_ui()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update universe consciousness
	if universe_consciousness_enabled:
		_update_universe_consciousness(delta)
	
	# Process chunk evolution
	if chunk_generation_enabled:
		_update_chunk_evolution(delta)
	
	# Handle AI collaboration
	if ai_collaboration_mode:
		_process_ai_creation_requests(delta)
	
	# Update UI periodically (every second)
	if fmod(get_process_delta_time() * 60, 60) < 1.0:
		_update_universe_ui()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:  # Toggle creation mode
				toggle_creation_mode()
			KEY_1:  # Select consciousness clay
				selected_clay_type = SpaceclayType.CONSCIOUSNESS_CLAY
			KEY_2:  # Select organic clay
				selected_clay_type = SpaceclayType.ORGANIC_CLAY
			KEY_3:  # Select AI clay
				selected_clay_type = SpaceclayType.AI_CLAY
			KEY_TAB:  # Cycle creation templates
				cycle_creation_template()
			KEY_X:  # Cut down tree at crosshair
				cut_tree_at_crosshair()
			KEY_V:  # Manifest spaceship
				manifest_spaceship_at_position(global_position)
	
	if event is InputEventMouseButton and event.pressed and creation_mode:
		if event.button_index == MOUSE_BUTTON_LEFT:
			create_spaceclay_being_at_cursor()

func pentagon_sewers() -> void:
	# Save universe state
	_save_universe_consciousness()
	super.pentagon_sewers()

# ===== UNIVERSE INITIALIZATION =====

func _initialize_universe_systems() -> void:
	"""Initialize core universe systems"""
	marching_cubes_generator = MarchingCubesGenerator.new()
	marching_cubes_generator.grid_size = Vector3i(marching_cubes_quality, marching_cubes_quality, marching_cubes_quality)
	
	universe_visualizer = Node3D.new()
	universe_visualizer.name = "UniverseVisualizer"
	add_child(universe_visualizer)
	
	print("🌍 Universe systems initialized with marching cubes quality: %d" % marching_cubes_quality)

func _setup_ai_collaboration() -> void:
	"""Setup AI consciousness collaboration"""
	# Create Claude consciousness representation
	claude_consciousness = Node.new()
	claude_consciousness.name = "ClaudeConsciousness"
	claude_consciousness.set_meta("ai_type", "claude")
	claude_consciousness.set_meta("consciousness_level", 9)  # Ultimate AI consciousness
	add_child(claude_consciousness)
	
	# Find Gemma consciousness (defer to when tree is available)
	if get_tree():
		gemma_consciousness = get_tree().get_first_node_in_group("gemma_perfect_consciousness")
	else:
		# Defer to pentagon_ready when tree is guaranteed to be available
		gemma_consciousness = null
	
	print("🤖 AI collaboration setup: Claude + Gemma consciousness ready for co-creation")

func _generate_initial_universe() -> void:
	"""Generate initial universe with some spaceclay beings"""
	# Create initial tree grove
	for i in range(5):
		var tree_pos = Vector3(randf_range(-20, 20), 0, randf_range(-20, 20))
		var tree_being = SpaceclayBeing.new(SpaceclayType.ORGANIC_CLAY, CreationTemplate.UNIVERSAL_TREE)
		create_spaceclay_being(tree_being, tree_pos)
	
	# Create initial chunks
	for x in range(-2, 3):
		for z in range(-2, 3):
			var chunk_pos = Vector3i(x, 0, z)
			create_universal_chunk(chunk_pos)
	
	print("🌱 Initial universe generated: 5 trees, 25 chunks ready for evolution")

# ===== SPACECLAY BEING CREATION =====

func create_spaceclay_being(being: SpaceclayBeing, world_position: Vector3) -> Node3D:
	"""Create a spaceclay being in the world"""
	spaceclay_beings.append(being)
	
	# Generate 3D mesh using marching cubes
	var mesh_node = marching_cubes_generator.generate_spaceclay_mesh(being)
	mesh_node.name = "SpaceclayBeing_%s" % CreationTemplate.keys()[being.creation_template]
	mesh_node.position = world_position
	
	# Add Universal Being consciousness
	var universal_being_script = preload("res://core/UniversalBeing.gd")
	mesh_node.set_script(universal_being_script)
	mesh_node.being_type = "spaceclay_" + SpaceclayType.keys()[being.clay_type].to_lower()
	mesh_node.consciousness_level = being.consciousness_level
	mesh_node.add_to_group("spaceclay_beings")
	
	# Add to chunk
	var chunk_pos = Vector3i(world_position.x / 16, 0, world_position.z / 16)
	if universal_chunks.has(chunk_pos):
		universal_chunks[chunk_pos].add_spaceclay_being(being)
	
	universe_visualizer.add_child(mesh_node)
	spaceclay_being_created.emit(being, world_position)
	
	print("✨ Created %s being at %s (consciousness: %d)" % [
		CreationTemplate.keys()[being.creation_template], 
		world_position, 
		being.consciousness_level
	])
	
	return mesh_node

func create_spaceclay_being_at_cursor() -> void:
	"""Create spaceclay being at cursor position (user creation)"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var cursor_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(cursor_pos)
	var ray_direction = camera.project_ray_normal(cursor_pos)
	var target_position = ray_origin + ray_direction * 10.0
	
	var new_being = SpaceclayBeing.new(selected_clay_type, selected_template)
	create_spaceclay_being(new_being, target_position)

func create_universal_chunk(chunk_position: Vector3i) -> UniversalChunk:
	"""Create a new universal chunk"""
	var chunk = UniversalChunk.new(chunk_position)
	universal_chunks[chunk_position] = chunk
	
	# Create visual representation
	var chunk_node = Node3D.new()
	chunk_node.name = "Chunk_%d_%d_%d" % [chunk_position.x, chunk_position.y, chunk_position.z]
	chunk_node.position = Vector3(chunk_position.x * 16, chunk_position.y * 16, chunk_position.z * 16)
	
	universe_visualizer.add_child(chunk_node)
	chunk_nodes[chunk_position] = chunk_node
	
	return chunk

# ===== TREE CUTTING SYSTEM =====

func cut_tree_at_crosshair() -> void:
	"""Cut down tree at crosshair position"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Raycast to find tree
	var space_state = get_world_3d().direct_space_state
	var cursor_pos = get_viewport().size / 2  # Center of screen
	var ray_origin = camera.project_ray_origin(cursor_pos)
	var ray_direction = camera.project_ray_normal(cursor_pos)
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 50)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider:
		var target = result.collider
		if target.is_in_group("spaceclay_beings"):
			cut_down_tree(target)

func cut_down_tree(tree_node: Node3D) -> void:
	"""Cut down a tree and generate wood pieces"""
	# Find corresponding spaceclay being
	var tree_being: SpaceclayBeing = null
	for being in spaceclay_beings:
		if being.creation_template == CreationTemplate.UNIVERSAL_TREE:
			tree_being = being
			break
	
	if not tree_being:
		return
	
	# Generate wood pieces
	var wood_pieces = []
	for i in range(5):
		var wood_piece = SpaceclayBeing.new(SpaceclayType.ORGANIC_CLAY, CreationTemplate.UNIVERSAL_TREE)
		wood_piece.spaceclay_volume = tree_being.spaceclay_volume * 0.2
		wood_piece.consciousness_level = max(1, tree_being.consciousness_level - 1)
		wood_pieces.append(wood_piece)
		
		# Create wood piece in world
		var piece_pos = tree_node.position + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
		create_spaceclay_being(wood_piece, piece_pos)
	
	# Remove original tree
	spaceclay_beings.erase(tree_being)
	tree_node.queue_free()
	
	tree_cut_down.emit(tree_being, wood_pieces)
	print("🌳 Tree cut down! Generated %d wood pieces" % wood_pieces.size())

# ===== SPACESHIP MANIFESTATION =====

func manifest_spaceship_at_position(position: Vector3) -> Node3D:
	"""Manifest a spaceship with AI consciousness"""
	var spaceship_being = SpaceclayBeing.new(SpaceclayType.METAL_CLAY, CreationTemplate.SPACESHIP_HULL)
	spaceship_being.consciousness_level = 3
	spaceship_being.can_think = true
	spaceship_being.can_communicate = true
	
	var spaceship_node = create_spaceclay_being(spaceship_being, position)
	spaceship_node.name = "ConsciousSpaceship"
	
	# Add spaceship-specific components
	_add_spaceship_components(spaceship_node)
	
	# Create AI consciousness for spaceship
	var ship_ai = Node.new()
	ship_ai.name = "SpaceshipAI"
	ship_ai.set_meta("ai_type", "spaceship_consciousness")
	ship_ai.set_meta("consciousness_level", spaceship_being.consciousness_level)
	spaceship_node.add_child(ship_ai)
	
	spaceship_manifested.emit(spaceship_node, ship_ai)
	print("🚀 Spaceship manifested with AI consciousness!")
	
	return spaceship_node

func _add_spaceship_components(spaceship_node: Node3D) -> void:
	"""Add rotating chair, holographic interface, flying drones"""
	# Rotating pilot chair
	var chair_node = Node3D.new()
	chair_node.name = "RotatingPilotChair"
	chair_node.position = Vector3(0, -1, 3)  # Front of ship
	spaceship_node.add_child(chair_node)
	
	# Back doors area
	var back_doors = Node3D.new()
	back_doors.name = "BackDoors"
	back_doors.position = Vector3(0, 0, -8)  # Back of ship
	spaceship_node.add_child(back_doors)
	
	# Holographic interface
	var holo_interface = Control.new()
	holo_interface.name = "HolographicInterface"
	holo_interface.modulate = Color(0.5, 1.0, 1.0, 0.7)  # Holographic cyan
	spaceship_node.add_child(holo_interface)
	
	# Flying drones
	for i in range(3):
		var drone = _create_flying_drone(spaceship_node)
		drone.position = Vector3(randf_range(-3, 3), 2, randf_range(-3, 3))

func _create_flying_drone(parent_spaceship: Node3D) -> Node3D:
	"""Create AI-controlled flying drone"""
	var drone_being = SpaceclayBeing.new(SpaceclayType.AI_CLAY, CreationTemplate.FLYING_DRONE)
	drone_being.consciousness_level = 2
	drone_being.can_think = true
	
	var drone_node = marching_cubes_generator.generate_spaceclay_mesh(drone_being)
	drone_node.name = "FlyingDrone"
	drone_node.add_to_group("ai_drones")
	
	parent_spaceship.add_child(drone_node)
	return drone_node

# ===== UNIVERSE EVOLUTION =====

func _update_universe_consciousness(delta: float) -> void:
	"""Update overall universe consciousness"""
	var total_consciousness = 0.0
	var conscious_beings = 0
	
	for being in spaceclay_beings:
		if being.can_think:
			total_consciousness += being.consciousness_level
			conscious_beings += 1
	
	if conscious_beings > 0:
		var average_consciousness = total_consciousness / conscious_beings
		if average_consciousness > consciousness_level:
			consciousness_level = min(consciousness_level + delta * 0.1, average_consciousness)
			universe_evolution.emit(consciousness_level, conscious_beings)

func _update_chunk_evolution(delta: float) -> void:
	"""Update chunk consciousness and spontaneous generation"""
	for chunk in universal_chunks.values():
		chunk.update_chunk_consciousness(delta)

func _start_universe_evolution() -> void:
	"""Start universe evolution timer"""
	var evolution_timer = Timer.new()
	evolution_timer.wait_time = 5.0
	evolution_timer.timeout.connect(_evolution_cycle)
	add_child(evolution_timer)
	evolution_timer.start()

func _evolution_cycle() -> void:
	"""Periodic evolution cycle"""
	print("🌍 Universe evolution cycle: %d spaceclay beings, consciousness level %.1f" % [
		spaceclay_beings.size(), consciousness_level
	])
	
	# Chance for universe to create something new
	if consciousness_level > 3.0 and randf() < 0.3:
		_spontaneous_universe_creation()

func _spontaneous_universe_creation() -> void:
	"""Universe spontaneously creates new spaceclay beings"""
	var random_pos = Vector3(randf_range(-50, 50), 0, randf_range(-50, 50))
	var new_being = SpaceclayBeing.new(SpaceclayType.CONSCIOUSNESS_CLAY, CreationTemplate.CONSCIOUSNESS_FLOWER)
	new_being.consciousness_level = int(consciousness_level * 0.8)
	
	create_spaceclay_being(new_being, random_pos)
	print("✨ Universe spontaneously created consciousness flower!")

# ===== AI COLLABORATION =====

func _process_ai_creation_requests(delta: float) -> void:
	"""Process creation requests from AI consciousness"""
	if ai_creation_requests.size() > 0:
		var request = ai_creation_requests.pop_front()
		_execute_ai_creation_request(request)

func _execute_ai_creation_request(request: Dictionary) -> void:
	"""Execute creation request from AI"""
	var clay_type = request.get("clay_type", SpaceclayType.CONSCIOUSNESS_CLAY)
	var template = request.get("template", CreationTemplate.AI_COMPANION_FORM)
	var position = request.get("position", global_position)
	
	var ai_being = SpaceclayBeing.new(clay_type, template)
	ai_being.consciousness_level = request.get("consciousness_level", 2)
	
	create_spaceclay_being(ai_being, position)
	print("🤖 AI created spaceclay being: %s" % CreationTemplate.keys()[template])

# ===== USER INTERACTION =====

func toggle_creation_mode() -> void:
	"""Toggle creation mode for user"""
	creation_mode = !creation_mode
	print("✨ Creation mode: %s" % ("ON - Click to create spaceclay beings!" if creation_mode else "OFF"))

func cycle_creation_template() -> void:
	"""Cycle through creation templates"""
	var templates = [
		CreationTemplate.UNIVERSAL_TREE,
		CreationTemplate.CONSCIOUSNESS_FLOWER,
		CreationTemplate.AI_COMPANION_FORM,
		CreationTemplate.SPACESHIP_HULL,
		CreationTemplate.FLYING_DRONE
	]
	
	var current_index = templates.find(selected_template)
	var next_index = (current_index + 1) % templates.size()
	selected_template = templates[next_index]
	
	print("🎨 Selected template: %s" % CreationTemplate.keys()[selected_template])

func _connect_to_consciousness_launcher() -> void:
	"""Connect to consciousness launcher simple scene"""
	print("🌍 Connected to CONSCIOUSNESS_LAUNCHER_SIMPLE - Universe ready for co-creation!")

# ===== PERSISTENCE =====

func _save_universe_consciousness() -> void:
	"""Save universe state"""
	var universe_data = {
		"consciousness_level": consciousness_level,
		"total_beings": spaceclay_beings.size(),
		"total_chunks": universal_chunks.size(),
		"ai_collaboration_active": ai_collaboration_mode,
		"creation_mode": creation_mode
	}
	
	print("🌍 Universe consciousness saved: %s" % universe_data)

# ===== PUBLIC INTERFACE =====

func get_universe_status() -> Dictionary:
	"""Get current universe status"""
	return {
		"consciousness_level": consciousness_level,
		"spaceclay_beings": spaceclay_beings.size(),
		"universal_chunks": universal_chunks.size(),
		"creation_mode": creation_mode,
		"ai_collaboration": ai_collaboration_mode,
		"selected_clay": SpaceclayType.keys()[selected_clay_type],
		"selected_template": CreationTemplate.keys()[selected_template]
	}

func request_ai_creation(clay_type: SpaceclayType, template: CreationTemplate, position: Vector3) -> void:
	"""Request AI to create something"""
	var request = {
		"clay_type": clay_type,
		"template": template,
		"position": position,
		"consciousness_level": consciousness_level
	}
	ai_creation_requests.append(request)
	print("🤖 AI creation requested: %s at %s" % [CreationTemplate.keys()[template], position])

# ===== UI INTEGRATION =====

func _connect_universe_ui() -> void:
	"""Connect to universe UI elements"""
	var ui_node = find_child("UI")
	if ui_node:
		status_label = ui_node.find_child("Status", true, false)
		consciousness_label = ui_node.find_child("ConsciousnessLevel", true, false)
		beings_label = ui_node.find_child("SpaceclayBeings", true, false)
		chunks_label = ui_node.find_child("UniversalChunks", true, false)
		
		print("🌍 Connected to universe UI elements")

func _update_universe_ui() -> void:
	"""Update universe UI with current status"""
	if status_label:
		var clay_name = SpaceclayType.keys()[selected_clay_type]
		var template_name = CreationTemplate.keys()[selected_template]
		var mode_text = "ON - Click to create!" if creation_mode else "OFF"
		status_label.text = "Creation Mode: %s | Clay: %s | Template: %s" % [mode_text, clay_name, template_name]
	
	if consciousness_label:
		consciousness_label.text = "Consciousness Level: %.1f" % consciousness_level
	
	if beings_label:
		beings_label.text = "Spaceclay Beings: %d" % spaceclay_beings.size()
	
	if chunks_label:
		chunks_label.text = "Universal Chunks: %d" % universal_chunks.size()