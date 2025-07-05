extends Node3D
class_name AstralSpaceFlight

# 🌌 ASTRAL SPACE FLIGHT 🌌
# Peaceful flight through beautiful cosmic space
# Stars, nebulae, planets, and cosmic wonder

signal entered_star_system(system_name: String)
signal discovered_cosmic_wonder(wonder_type: String)

# SPACE FLIGHT SETTINGS
@export var flight_speed: float = 20.0
@export var boost_multiplier: float = 3.0
@export var star_density: int = 1000

# COSMIC ELEMENTS
var flight_camera: Camera3D
var star_field: Node3D
var cosmic_wonders: Array[CosmicWonder] = []
var nebulae: Array[Nebula] = []

# ASTRAL BEING
var astral_form: MeshInstance3D
var astral_trail: GPUParticles3D

class CosmicWonder:
	var wonder_id: String
	var wonder_type: String
	var position: Vector3
	var scale_size: float
	var color_theme: Color
	
	func _init(id: String, type: String, pos: Vector3):
		wonder_id = id
		wonder_type = type
		position = pos
		scale_size = randf_range(1.0, 10.0)
		color_theme = _generate_cosmic_color()
	
	func _generate_cosmic_color() -> Color:
		var cosmic_colors = [
			Color(0.8, 0.4, 1.0),    # Purple nebula
			Color(0.4, 0.8, 1.0),    # Blue giant star
			Color(1.0, 0.6, 0.2),    # Orange star
			Color(0.2, 1.0, 0.4),    # Green aurora
			Color(1.0, 0.8, 0.4),    # Golden star
			Color(0.6, 0.2, 1.0)     # Deep space purple
		]
		return cosmic_colors[randi() % cosmic_colors.size()]

class Nebula:
	var nebula_id: String
	var center_position: Vector3
	var size: float
	var color: Color
	var particle_system: GPUParticles3D
	
	func _init(id: String, pos: Vector3):
		nebula_id = id
		center_position = pos
		size = randf_range(20.0, 100.0)
		color = Color(randf(), randf(), randf(), 0.3)

func _ready():
	name = "AstralSpaceFlight"
	print("🌌 ASTRAL SPACE FLIGHT INITIALIZING...")
	
	# Setup space environment
	setup_space_environment()
	
	# Create flight camera
	setup_astral_flight()
	
	# Generate star field
	generate_star_field()
	
	# Create cosmic wonders
	generate_cosmic_wonders()
	
	# Create nebulae
	generate_nebulae()
	
	print("✨ ASTRAL SPACE READY - FLY AMONG THE STARS!")

func setup_space_environment():
	"""Setup beautiful space environment"""
	var world_env = WorldEnvironment.new()
	var environment = Environment.new()
	
	# Deep space background
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.sky.sky_material = ProceduralSkyMaterial.new()
	environment.sky.sky_material.sky_top_color = Color(0.05, 0.05, 0.15)
	environment.sky.sky_material.sky_horizon_color = Color(0.1, 0.1, 0.3)
	environment.sky.sky_material.ground_bottom_color = Color(0.02, 0.02, 0.08)
	environment.sky.sky_material.ground_horizon_color = Color(0.05, 0.05, 0.2)
	
	# Ambient lighting for space
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.1, 0.1, 0.3)
	environment.ambient_light_energy = 0.2
	
	world_env.environment = environment
	add_child(world_env)

func setup_astral_flight():
	"""Setup astral being flight camera"""
	flight_camera = Camera3D.new()
	flight_camera.name = "AstralCamera"
	flight_camera.position = Vector3(0, 0, 0)
	add_child(flight_camera)
	
	# Make this the active camera
	get_viewport().set_camera_3d(flight_camera)
	
	# Create astral form visual (optional floating orb)
	astral_form = MeshInstance3D.new()
	astral_form.mesh = SphereMesh.new()
	astral_form.mesh.radius = 0.5
	
	var astral_material = StandardMaterial3D.new()
	astral_material.albedo_color = Color(0.6, 0.8, 1.0, 0.7)
	astral_material.emission_enabled = true
	astral_material.emission = Color(0.3, 0.6, 1.0)
	astral_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	astral_form.material_override = astral_material
	
	flight_camera.add_child(astral_form)
	
	print("👻 Astral form manifested for space flight")

func generate_star_field():
	"""Generate beautiful star field"""
	star_field = Node3D.new()
	star_field.name = "StarField"
	add_child(star_field)
	
	print("⭐ Generating", star_density, "stars...")
	
	for i in range(star_density):
		var star = create_star()
		star_field.add_child(star)
	
	print("✨ Star field complete")

func create_star() -> MeshInstance3D:
	"""Create individual star"""
	var star = MeshInstance3D.new()
	star.mesh = SphereMesh.new()
	star.mesh.radius = randf_range(0.1, 2.0)
	
	# Random position in large sphere around origin
	var distance = randf_range(50.0, 500.0)
	var theta = randf() * TAU
	var phi = randf() * PI
	
	star.position = Vector3(
		distance * sin(phi) * cos(theta),
		distance * cos(phi),
		distance * sin(phi) * sin(theta)
	)
	
	# Star material with color and glow
	var star_material = StandardMaterial3D.new()
	var star_color = _generate_star_color()
	star_material.albedo_color = star_color
	star_material.emission_enabled = true
	star_material.emission = star_color * 0.8
	star_material.emission_energy = randf_range(0.5, 2.0)
	
	star.material_override = star_material
	
	return star

func _generate_star_color() -> Color:
	"""Generate realistic star colors"""
	var star_colors = [
		Color(1.0, 1.0, 1.0),      # White dwarf
		Color(1.0, 0.8, 0.6),      # Yellow sun
		Color(1.0, 0.6, 0.3),      # Orange giant
		Color(1.0, 0.3, 0.2),      # Red giant
		Color(0.6, 0.8, 1.0),      # Blue giant
		Color(0.8, 0.9, 1.0)       # Blue-white
	]
	return star_colors[randi() % star_colors.size()]

func generate_cosmic_wonders():
	"""Generate cosmic wonders to discover"""
	print("🌟 Creating cosmic wonders...")
	
	var wonder_types = [
		"crystal_asteroid", "gas_giant", "binary_star", "space_station",
		"cosmic_garden", "energy_vortex", "star_nursery", "cosmic_temple"
	]
	
	for i in range(50):
		var pos = Vector3(
			randf_range(-300, 300),
			randf_range(-200, 200),
			randf_range(-300, 300)
		)
		
		var wonder_type = wonder_types[randi() % wonder_types.size()]
		var wonder = CosmicWonder.new("wonder_" + str(i), wonder_type, pos)
		
		_create_wonder_visual(wonder)
		cosmic_wonders.append(wonder)
	
	print("✨ Created", cosmic_wonders.size(), "cosmic wonders")

func _create_wonder_visual(wonder: CosmicWonder):
	"""Create visual for cosmic wonder"""
	var wonder_node = Node3D.new()
	wonder_node.name = wonder.wonder_id
	wonder_node.position = wonder.position
	
	var mesh_instance = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	material.albedo_color = wonder.color_theme
	material.emission_enabled = true
	material.emission = wonder.color_theme * 0.5
	
	match wonder.wonder_type:
		"crystal_asteroid":
			mesh_instance.mesh = BoxMesh.new()
			mesh_instance.mesh.size = Vector3.ONE * wonder.scale_size
			mesh_instance.rotation_degrees = Vector3(randf() * 360, randf() * 360, randf() * 360)
		"gas_giant":
			mesh_instance.mesh = SphereMesh.new()
			mesh_instance.mesh.radius = wonder.scale_size * 3
		"binary_star":
			# Create two stars
			var star1 = MeshInstance3D.new()
			star1.mesh = SphereMesh.new()
			star1.mesh.radius = wonder.scale_size
			star1.position = Vector3(wonder.scale_size * 2, 0, 0)
			star1.material_override = material
			wonder_node.add_child(star1)
			
			var star2 = MeshInstance3D.new()
			star2.mesh = SphereMesh.new()
			star2.mesh.radius = wonder.scale_size * 0.8
			star2.position = Vector3(-wonder.scale_size * 2, 0, 0)
			var material2 = material.duplicate()
			material2.albedo_color = Color(1.0, 0.4, 0.2)
			material2.emission = Color(1.0, 0.4, 0.2) * 0.5
			star2.material_override = material2
			wonder_node.add_child(star2)
			add_child(wonder_node)
			return
		"cosmic_garden":
			mesh_instance.mesh = SphereMesh.new()
			mesh_instance.mesh.radius = wonder.scale_size * 2
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color.a = 0.6
		_:
			mesh_instance.mesh = SphereMesh.new()
			mesh_instance.mesh.radius = wonder.scale_size
	
	mesh_instance.material_override = material
	wonder_node.add_child(mesh_instance)
	add_child(wonder_node)

func generate_nebulae():
	"""Generate beautiful nebulae"""
	print("🌌 Creating nebulae...")
	
	for i in range(10):
		var pos = Vector3(
			randf_range(-400, 400),
			randf_range(-300, 300),
			randf_range(-400, 400)
		)
		
		var nebula = Nebula.new("nebula_" + str(i), pos)
		_create_nebula_visual(nebula)
		nebulae.append(nebula)
	
	print("✨ Created", nebulae.size(), "nebulae")

func _create_nebula_visual(nebula: Nebula):
	"""Create visual nebula with particles"""
	var nebula_node = Node3D.new()
	nebula_node.name = nebula.nebula_id
	nebula_node.position = nebula.center_position
	
	# Create particle system for nebula
	var particles = GPUParticles3D.new()
	particles.emitting = true
	particles.amount = 1000
	particles.lifetime = 60.0
	
	# Create particle material
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 1, 0)
	particle_material.initial_velocity_min = 0.1
	particle_material.initial_velocity_max = 0.5
	particle_material.gravity = Vector3.ZERO
	particle_material.scale_min = 0.1
	particle_material.scale_max = 2.0
	
	particles.process_material = particle_material
	particles.draw_pass_1 = QuadMesh.new()
	
	nebula_node.add_child(particles)
	add_child(nebula_node)

func _physics_process(delta):
	_handle_astral_flight(delta)

func _handle_astral_flight(delta):
	"""Handle smooth astral flight"""
	var movement = Vector3.ZERO
	var speed = flight_speed
	
	# Check for boost
	if Input.is_action_pressed("ui_accept"):  # Space for boost
		speed *= boost_multiplier
	
	# Movement input
	if Input.is_action_pressed("move_forward"):
		movement.z -= 1
	if Input.is_action_pressed("move_backward"):
		movement.z += 1
	if Input.is_action_pressed("move_left"):
		movement.x -= 1
	if Input.is_action_pressed("move_right"):
		movement.x += 1
	if Input.is_action_pressed("ui_select"):  # Shift - fly up
		movement.y += 1
	if Input.is_action_pressed("ui_cancel"):  # Control - fly down
		movement.y -= 1
	
	# Apply movement relative to camera
	if movement.length() > 0:
		movement = movement.normalized()
		var camera_basis = flight_camera.global_transform.basis
		var world_movement = camera_basis * movement * speed * delta
		flight_camera.global_position += world_movement

func _input(event):
	if event is InputEventMouseMotion:
		# Smooth mouse look
		var sensitivity = 0.002
		flight_camera.rotate_y(-event.relative.x * sensitivity)
		flight_camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * sensitivity)
		
		# Clamp vertical rotation
		var rot = flight_camera.rotation_degrees
		rot.x = clamp(rot.x, -90, 90)
		flight_camera.rotation_degrees = rot
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F:
				_find_nearest_wonder()
			KEY_N:
				_navigate_to_random_wonder()
			KEY_ESCAPE:
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				else:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _find_nearest_wonder():
	"""Find and highlight nearest cosmic wonder"""
	var current_pos = flight_camera.global_position
	var nearest_wonder: CosmicWonder = null
	var nearest_distance = INF
	
	for wonder in cosmic_wonders:
		var distance = current_pos.distance_to(wonder.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_wonder = wonder
	
	if nearest_wonder:
		print("🌟 Nearest wonder:", nearest_wonder.wonder_type, "at distance:", int(nearest_distance))
		discovered_cosmic_wonder.emit(nearest_wonder.wonder_type)

func _navigate_to_random_wonder():
	"""Navigate to random cosmic wonder"""
	if cosmic_wonders.size() > 0:
		var random_wonder = cosmic_wonders[randi() % cosmic_wonders.size()]
		print("🚀 Navigating to:", random_wonder.wonder_type)
		
		# Smooth movement toward wonder (you can fly there manually)
		var direction = (random_wonder.position - flight_camera.global_position).normalized()
		print("📍 Direction:", direction)

func _enter_tree():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE