extends Node3D
class_name SimpleAstralSpace

# 🌌 SIMPLE ASTRAL SPACE 🌌
# Just peaceful flight through beautiful stars
# No violence, just pure cosmic beauty

# SIMPLE FLIGHT
var camera: Camera3D
var flight_speed: float = 15.0

func _ready():
	name = "SimpleAstralSpace"
	print("🌌 Simple Astral Space starting...")
	
	# Create camera
	camera = Camera3D.new()
	camera.name = "AstralCamera"
	camera.position = Vector3(0, 0, 0)
	add_child(camera)
	camera.current = true
	
	# Create peaceful space environment
	create_space_environment()
	
	# Create beautiful stars
	create_stars()
	
	print("✨ Peaceful astral space ready! WASD to fly, mouse to look")

func create_space_environment():
	"""Create beautiful space environment"""
	var world_env = WorldEnvironment.new()
	var environment = Environment.new()
	
	# Deep space background
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.02, 0.02, 0.1)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.1, 0.1, 0.2)
	environment.ambient_light_energy = 0.2
	
	world_env.environment = environment
	add_child(world_env)

func create_stars():
	"""Create peaceful star field"""
	for i in range(1000):
		var star = MeshInstance3D.new()
		star.mesh = SphereMesh.new()
		star.mesh.radius = randf_range(0.1, 1.0)
		
		# Random position around player
		var distance = randf_range(20, 200)
		var angle1 = randf() * TAU
		var angle2 = randf() * PI
		
		star.position = Vector3(
			distance * sin(angle2) * cos(angle1),
			distance * cos(angle2),
			distance * sin(angle2) * sin(angle1)
		)
		
		# Beautiful star colors
		var material = StandardMaterial3D.new()
		var colors = [
			Color(1, 1, 1),      # White
			Color(1, 0.8, 0.6),  # Yellow
			Color(0.6, 0.8, 1),  # Blue
			Color(1, 0.6, 0.4)   # Orange
		]
		var color = colors[randi() % colors.size()]
		material.albedo_color = color
		material.emission_enabled = true
		material.emission = color * 0.8
		
		star.material_override = material
		add_child(star)

func _physics_process(delta):
	# Simple flight movement
	var movement = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_W):
		movement.z -= 1
	if Input.is_key_pressed(KEY_S):
		movement.z += 1
	if Input.is_key_pressed(KEY_A):
		movement.x -= 1
	if Input.is_key_pressed(KEY_D):
		movement.x += 1
	if Input.is_key_pressed(KEY_SPACE):
		movement.y += 1
	if Input.is_key_pressed(KEY_SHIFT):
		movement.y -= 1
	
	if movement.length() > 0:
		movement = movement.normalized()
		var camera_basis = camera.global_transform.basis
		camera.global_position += camera_basis * movement * flight_speed * delta

func _input(event):
	if event is InputEventMouseMotion:
		# Simple mouse look
		var sensitivity = 0.002
		camera.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * sensitivity)
		
		# Limit vertical rotation
		var rot = camera.rotation_degrees
		rot.x = clamp(rot.x, -90, 90)
		camera.rotation_degrees = rot

func _enter_tree():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE