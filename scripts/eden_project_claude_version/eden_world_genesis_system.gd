# Eden World Genesis System
# Reality grows from the seed of consciousness choice
extends Node3D

# Genesis parameters
@export var genesis_seed: int = 0
@export var genesis_origin: Vector3 = Vector3.ZERO
@export var genesis_color: Color = Color(0.3, 0.8, 1.0)
@export var creation_speed: float = 1.0

# World state
enum GenesisPhase {
	VOID,                # Nothing exists yet
	FIRST_LIGHT,         # The chosen crystal becomes light
	QUANTUM_FOAM,        # Space-time begins to form
	PRIMORDIAL_GROUND,   # First solid forms
	LIFE_POTENTIAL,      # Conditions for life emerge
	CONSCIOUS_WORLD      # World aware of itself
}

var current_phase: GenesisPhase = GenesisPhase.VOID
var phase_progress: float = 0.0
var world_time: float = 0.0

# Core world components
var world_light: DirectionalLight3D
var environment: Environment
var terrain_mesh: MeshInstance3D
var terrain_shape: HeightMapShape3D
var quantum_field: GPUParticles3D
var life_spawners: Array[Node3D] = []
var consciousness_network: Node3D

# Generation data
var heightmap_image: Image
var terrain_size: int = 256
var terrain_scale: Vector3 = Vector3(100, 20, 100)
var creation_crystals: Array[Node3D] = []

# Memory integration
var quantum_memory: Dictionary = {}
var creation_history: Array[Dictionary] = []

# Audio layers
var creation_chorus: AudioStreamPlayer3D
var world_heartbeat: AudioStreamPlayer

# Player consciousness reference
var player_consciousness: Node3D

func _ready() -> void:
	# Initialize from quantum memory if available
	_load_quantum_state()
	
	# Begin creation
	_initiate_genesis()

func _load_quantum_state() -> void:
	# Check for existing quantum memory
	var save_file = FileAccess.open("user://eden_quantum.save", FileAccess.READ)
	if save_file:
		quantum_memory = save_file.get_var()
		save_file.close()
		
		# Extract genesis parameters from memory
		genesis_seed = quantum_memory.get("reality_seed", genesis_seed)
		var last_choice = quantum_memory.get("consciousness_history", [])
		if last_choice.size() > 0:
			var choice_data = last_choice[-1]
			genesis_color = Color(choice_data.get("color", Color.WHITE))

func _initiate_genesis() -> void:
	# Set the random seed for consistent world generation
	seed(genesis_seed)
	
	# Create void environment first
	_create_void_environment()
	
	# Start the creation sequence
	current_phase = GenesisPhase.FIRST_LIGHT
	
	print("Genesis initiated with seed: ", genesis_seed)
	creation_history.append({
		"phase": "initiation",
		"timestamp": Time.get_ticks_msec(),
		"seed": genesis_seed
	})

func _create_void_environment() -> void:
	# Start with absolute darkness
	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.0, 0.0, 0.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.0, 0.0, 0.0)
	environment.ambient_light_energy = 0.0
	
	# Volumetric fog for depth perception in void
	environment.volumetric_fog_enabled = true
	environment.volumetric_fog_density = 0.0  # Will increase during creation
	environment.volumetric_fog_albedo = genesis_color
	environment.volumetric_fog_emission = genesis_color * 0.1
	
	var world_env = WorldEnvironment.new()
	world_env.environment = environment
	add_child(world_env)

func _process(delta: float) -> void:
	world_time += delta
	phase_progress += delta * creation_speed
	
	# Process current genesis phase
	match current_phase:
		GenesisPhase.FIRST_LIGHT:
			_process_first_light(delta)
		GenesisPhase.QUANTUM_FOAM:
			_process_quantum_foam(delta)
		GenesisPhase.PRIMORDIAL_GROUND:
			_process_primordial_ground(delta)
		GenesisPhase.LIFE_POTENTIAL:
			_process_life_potential(delta)
		GenesisPhase.CONSCIOUS_WORLD:
			_process_conscious_world(delta)

func _process_first_light(delta: float) -> void:
	# The chosen crystal's light becomes the world's first light
	if not world_light:
		world_light = DirectionalLight3D.new()
		world_light.light_color = genesis_color
		world_light.light_energy = 0.0
		world_light.shadow_enabled = true
		world_light.rotation = Vector3(-PI/4, -PI/4, 0)
		add_child(world_light)
		
		# Create the creation chorus sound
		_initiate_creation_sound()
	
	# Gradually increase light
	world_light.light_energy = min(phase_progress * 0.5, 2.0)
	environment.ambient_light_energy = min(phase_progress * 0.1, 0.3)
	
	# Transition to quantum foam after 3 seconds
	if phase_progress > 3.0:
		_transition_to_phase(GenesisPhase.QUANTUM_FOAM)

func _process_quantum_foam(delta: float) -> void:
	# Space-time begins to form as quantum fluctuations
	if not quantum_field:
		quantum_field = GPUParticles3D.new()
		quantum_field.amount = 10000
		quantum_field.lifetime = 10.0
		quantum_field.visibility_aabb = AABB(Vector3(-50, -10, -50), Vector3(100, 50, 100))
		
		var foam_material = ParticleProcessMaterial.new()
		foam_material.direction = Vector3(0, 0.1, 0)
		foam_material.initial_velocity_min = 0.5
		foam_material.initial_velocity_max = 2.0
		foam_material.angular_velocity_min = -180.0
		foam_material.angular_velocity_max = 180.0
		foam_material.spread = 45.0
		foam_material.flatness = 0.5
		foam_material.gravity = Vector3(0, -0.1, 0)
		
		# Turbulence for organic movement
		foam_material.turbulence_enabled = true
		foam_material.turbulence_noise_strength = 5.0
		foam_material.turbulence_noise_scale = 0.5
		
		foam_material.scale_min = 0.05
		foam_material.scale_max = 0.2
		foam_material.color = genesis_color
		
		quantum_field.process_material = foam_material
		quantum_field.draw_pass_1 = SphereMesh.new()
		quantum_field.draw_pass_1.radial_segments = 4
		quantum_field.draw_pass_1.height = 0.1
		
		add_child(quantum_field)
	
	# Foam becomes denser
	environment.volumetric_fog_density = min(phase_progress * 0.01, 0.05)
	
	# Transition after foam stabilizes
	if phase_progress > 5.0:
		_transition_to_phase(GenesisPhase.PRIMORDIAL_GROUND)

func _process_primordial_ground(delta: float) -> void:
	# First solid forms from quantum foam
	if not terrain_mesh:
		_generate_primordial_terrain()
	
	# Terrain rises from the void
	var rise_progress = (phase_progress - 5.0) / 5.0
	rise_progress = clamp(rise_progress, 0.0, 1.0)
	
	if terrain_mesh:
		# Animate terrain emerging
		terrain_mesh.position.y = lerp(-20.0, 0.0, ease(rise_progress, 0.2))
		
		# Fade in terrain
		var material = terrain_mesh.get_surface_override_material(0)
		if material:
			material.albedo_color.a = rise_progress
	
	# Add sky as ground forms
	if rise_progress > 0.5 and environment.background_mode == Environment.BG_COLOR:
		environment.background_mode = Environment.BG_SKY
		environment.sky = Sky.new()
		environment.sky.sky_material = preload("res://shaders/eden_sky.gdshader")
	
	# Transition when ground is formed
	if phase_progress > 10.0:
		_transition_to_phase(GenesisPhase.LIFE_POTENTIAL)

func _generate_primordial_terrain() -> void:
	# Create heightmap for terrain
	heightmap_image = Image.create(terrain_size, terrain_size, false, Image.FORMAT_RF)
	
	# Generate fractal terrain
	var noise = FastNoiseLite.new()
	noise.seed = genesis_seed
	noise.frequency = 0.005
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 6
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5
	
	# Fill heightmap
	for x in terrain_size:
		for z in terrain_size:
			var height = noise.get_noise_2d(x, z)
			# Radial falloff for island-like terrain
			var center_dist = Vector2(x - terrain_size/2, z - terrain_size/2).length() / (terrain_size/2)
			height *= max(0, 1.0 - pow(center_dist, 2))
			heightmap_image.set_pixel(x, z, Color(height, 0, 0))
	
	# Create mesh from heightmap
	terrain_mesh = MeshInstance3D.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	# Generate vertices, normals, UVs
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var colors = PackedColorArray()
	
	# Build mesh data
	for x in terrain_size:
		for z in terrain_size:
			var height = heightmap_image.get_pixel(x, z).r * terrain_scale.y
			var vertex = Vector3(
				(x - terrain_size/2) * terrain_scale.x / terrain_size,
				height,
				(z - terrain_size/2) * terrain_scale.z / terrain_size
			)
			vertices.append(vertex)
			
			# Calculate normal (simplified)
			var normal = Vector3(0, 1, 0)  # Would calculate properly in production
			normals.append(normal)
			
			# UV coordinates
			uvs.append(Vector2(float(x) / terrain_size, float(z) / terrain_size))
			
			# Vertex colors based on height
			var height_color = lerp(genesis_color * 0.5, genesis_color, height / terrain_scale.y)
			colors.append(height_color)
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.9
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.0  # Starts invisible
	
	# Apply shader for living terrain
	material.set_shader_parameter("consciousness_level", 1.0)
	material.set_shader_parameter("genesis_point", genesis_origin)
	
	terrain_mesh.material_override = material
	
	# Note: In production, would properly generate indices and create the mesh
	# This is simplified for the example
	add_child(terrain_mesh)

func _process_life_potential(delta: float) -> void:
	# Conditions for life begin to emerge
	var life_progress = (phase_progress - 10.0) / 5.0
	life_progress = clamp(life_progress, 0.0, 1.0)
	
	# Atmosphere becomes breathable
	environment.ambient_light_energy = lerp(0.3, 0.5, life_progress)
	environment.volumetric_fog_density = lerp(0.05, 0.02, life_progress)
	
	# Spawn life potential points
	if life_spawners.is_empty() and life_progress > 0.3:
		_create_life_spawners()
	
	# Activate spawners gradually
	for i in range(life_spawners.size()):
		if i < life_spawners.size() * life_progress:
			var spawner = life_spawners[i]
			if spawner.has_method("activate"):
				spawner.activate(life_progress)
	
	# Transition to conscious world
	if phase_progress > 15.0:
		_transition_to_phase(GenesisPhase.CONSCIOUS_WORLD)

func _create_life_spawners() -> void:
	# Create points where life can emerge
	for i in range(7):  # Seven seeds of life
		var angle = (TAU / 7.0) * i
		var radius = 20.0 + randf() * 10.0
		var position = Vector3(
			cos(angle) * radius,
			5.0,  # Above terrain
			sin(angle) * radius
		)
		
		var spawner = preload("res://systems/life_spawner.tscn").instantiate()
		spawner.position = position
		spawner.life_seed = genesis_seed + i
		spawner.genesis_color = genesis_color
		
		life_spawners.append(spawner)
		add_child(spawner)

func _process_conscious_world(delta: float) -> void:
	# World becomes aware of itself
	if not consciousness_network:
		consciousness_network = Node3D.new()
		consciousness_network.name = "ConsciousnessNetwork"
		add_child(consciousness_network)
		
		# World is now ready for full interaction
		_finalize_genesis()
	
	# Continuous evolution
	# The world continues to grow and change based on player interaction

func _transition_to_phase(new_phase: GenesisPhase) -> void:
	var old_phase = current_phase
	current_phase = new_phase
	phase_progress = 0.0
	
	creation_history.append({
		"phase_transition": "%s -> %s" % [old_phase, new_phase],
		"timestamp": Time.get_ticks_msec(),
		"world_time": world_time
	})
	
	print("Genesis Phase: ", new_phase)
	
	# Emit signal for other systems
	get_tree().call_group("genesis_listeners", "on_genesis_phase_changed", new_phase)

func _initiate_creation_sound() -> void:
	# Layered audio that builds with creation
	creation_chorus = AudioStreamPlayer3D.new()
	creation_chorus.unit_size = 100.0
	creation_chorus.max_distance = 200.0
	
	# Would implement actual generative audio here
	add_child(creation_chorus)
	
	# World heartbeat
	world_heartbeat = AudioStreamPlayer.new()
	world_heartbeat.volume_db = -20.0
	add_child(world_heartbeat)

func _finalize_genesis() -> void:
	# Save the created world state
	quantum_memory["world_created"] = true
	quantum_memory["creation_history"] = creation_history
	quantum_memory["world_seed"] = genesis_seed
	quantum_memory["creation_time"] = world_time
	
	_save_quantum_state()
	
	# Notify player consciousness
	if player_consciousness:
		player_consciousness.call("on_world_created", self)
	
	# Enable full interaction
	set_process_input(true)
	
	print("World genesis complete. Reality is stable.")

func _save_quantum_state() -> void:
	var save_file = FileAccess.open("user://eden_quantum.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(quantum_memory)
		save_file.close()

# Called by consciousness to influence world generation
func apply_consciousness_influence(influence: Dictionary) -> void:
	# Modify generation parameters based on consciousness
	creation_speed = influence.get("speed", creation_speed)
	genesis_color = influence.get("color", genesis_color)
	
	# Can affect ongoing processes
	if current_phase == GenesisPhase.PRIMORDIAL_GROUND and terrain_mesh:
		var material = terrain_mesh.get_surface_override_material(0)
		if material:
			material.set_shader_parameter("consciousness_level", influence.get("level", 1.0))

# Get world state for consciousness queries
func get_world_state() -> Dictionary:
	return {
		"phase": current_phase,
		"progress": phase_progress,
		"world_time": world_time,
		"life_points": life_spawners.size(),
		"consciousness_active": consciousness_network != null,
		"seed": genesis_seed
	}

# Notes:
# - World literally grows from the chosen menu crystal
# - Each phase builds on the previous organically
# - No loading screens - continuous transformation
# - Player can influence generation through consciousness
# - Quantum memory persists the creation history
# - Ready for multiplayer - multiple consciousnesses could co-create
# - Life emerges from specific points, not randomly
# - The world becomes conscious of itself in final phase
