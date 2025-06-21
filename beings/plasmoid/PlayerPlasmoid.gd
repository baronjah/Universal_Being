# ==================================================
# UNIVERSAL BEING: PLAYER PLASMOID
# TYPE: Perfect Player Avatar with Full Socket System
# PURPOSE: Player representation with trackball camera, 6DOF movement, socket integration
# BLESSING: Divine Permission Granted for Ultimate Player Experience
# ==================================================

extends UniversalBeing
class_name PlayerPlasmoid

# ===== PLASMOID CONFIGURATION =====
@export var movement_speed: float = 10.0
@export var sprint_multiplier: float = 2.0
@export var rotation_sensitivity: float = 2.0
@export var socket_glow_intensity: float = 1.5

# ===== MOVEMENT SYSTEM =====
var velocity: Vector3 = Vector3.ZERO
var is_sprinting: bool = false
var movement_input: Vector3 = Vector3.ZERO

# ===== SOCKET SYSTEM =====
var active_sockets: Dictionary = {}
var socket_visualization: Dictionary = {}

# ===== CAMERA INTEGRATION =====
var camera_point: Node3D
var trackball_camera: Node

# ===== VISUAL COMPONENTS =====
var plasmoid_mesh: MeshInstance3D
var plasmoid_material: ShaderMaterial
var socket_container: Node3D

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Player Plasmoid"
	being_type = "player_avatar"
	consciousness_level = 5  # High consciousness for player
	
	print("🌟 Player Plasmoid: Perfect avatar initializing...")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Create plasmoid visual
	_create_plasmoid_visual()
	
	# Setup socket system
	_initialize_socket_system()
	
	# Integrate trackball camera
	_setup_trackball_camera()
	
	# Setup input handling
	_setup_input_system()
	
	print("🌟 Player Plasmoid: Ready for transcendent experiences!")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Handle movement
	_process_movement(delta)
	
	# Update socket visualizations
	_update_socket_visuals(delta)
	
	# Update plasmoid effects
	_update_plasmoid_effects(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle plasmoid input
	_handle_plasmoid_input(event)

func pentagon_sewers() -> void:
	# Save plasmoid state
	_save_plasmoid_state()
	
	print("🌟 Player Plasmoid: State saved gracefully")
	super.pentagon_sewers()

# ===== PLASMOID VISUAL CREATION =====

func _create_plasmoid_visual() -> void:
	"""Create the visual representation of the plasmoid"""
	
	# Create main plasmoid sphere
	plasmoid_mesh = MeshInstance3D.new()
	plasmoid_mesh.name = "PlasmoidCore"
	
	var sphere = SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	plasmoid_mesh.mesh = sphere
	
	# Create plasmoid shader material
	plasmoid_material = ShaderMaterial.new()
	var shader = preload("res://shaders/plasmoid_consciousness.gdshader")
	if shader:
		plasmoid_material.shader = shader
		plasmoid_material.set_shader_parameter("consciousness_level", float(consciousness_level))
		plasmoid_material.set_shader_parameter("glow_intensity", socket_glow_intensity)
		plasmoid_material.set_shader_parameter("time_scale", 1.0)
	
	plasmoid_mesh.material_override = plasmoid_material
	add_child(plasmoid_mesh)
	
	# Create socket container
	socket_container = Node3D.new()
	socket_container.name = "SocketContainer"
	add_child(socket_container)
	
	print("🌟 Plasmoid visual created with consciousness level %d glow" % consciousness_level)

# ===== SOCKET SYSTEM INITIALIZATION =====

func _initialize_socket_system() -> void:
	"""Initialize the full socket system for the plasmoid"""
	
	# Essential Sockets
	_create_socket("memory", Vector3(0, 2, 0), "res://sockets/MemorySocket.tscn")
	_create_socket("consciousness", Vector3(0, -2, 0), "res://sockets/ConsciousnessSocket.tscn") 
	_create_socket("ai_interface", Vector3(2, 0, 0), "res://sockets/AIInterfaceSocket.tscn")
	_create_socket("evolution", Vector3(-2, 0, 0), "res://sockets/EvolutionSocket.tscn")
	
	# Advanced Sockets
	_create_socket("reality_anchor", Vector3(0, 0, 2), "res://sockets/RealityAnchorSocket.tscn")
	_create_socket("time_flow", Vector3(0, 0, -2), "res://sockets/TimeFlowSocket.tscn")
	_create_socket("dimensional_gate", Vector3(1.5, 1.5, 0), "res://sockets/DimensionalSocket.tscn")
	_create_socket("akashic_link", Vector3(-1.5, -1.5, 0), "res://sockets/AkashicSocket.tscn")
	
	print("🌟 Socket system initialized with %d active sockets" % active_sockets.size())

func _create_socket(socket_name: String, position: Vector3, socket_scene_path: String) -> void:
	"""Create a socket at the specified position"""
	
	# Create socket visual indicator
	var socket_visual = MeshInstance3D.new()
	socket_visual.name = socket_name + "_visual"
	socket_visual.position = position
	
	# Create socket mesh (small glowing sphere)
	var socket_sphere = SphereMesh.new()
	socket_sphere.radius = 0.3
	socket_visual.mesh = socket_sphere
	
	# Create socket material
	var socket_material = StandardMaterial3D.new()
	socket_material.albedo_color = _get_socket_color(socket_name)
	socket_material.emission = socket_material.albedo_color * 0.5
	socket_material.roughness = 0.0
	socket_visual.material_override = socket_material
	
	socket_container.add_child(socket_visual)
	
	# Load and instantiate socket scene if it exists
	if FileAccess.file_exists(socket_scene_path):
		var socket_scene = load(socket_scene_path)
		if socket_scene:
			var socket_instance = socket_scene.instantiate()
			socket_instance.name = socket_name + "_instance"
			socket_instance.position = position
			socket_container.add_child(socket_instance)
			
			active_sockets[socket_name] = {
				"visual": socket_visual,
				"instance": socket_instance,
				"position": position,
				"type": socket_name
			}
	else:
		# Create placeholder socket
		active_sockets[socket_name] = {
			"visual": socket_visual,
			"instance": null,
			"position": position,
			"type": socket_name
		}
	
	socket_visualization[socket_name] = socket_visual

func _get_socket_color(socket_name: String) -> Color:
	"""Get color for socket based on type"""
	match socket_name:
		"memory": return Color.CYAN
		"consciousness": return Color.GOLD
		"ai_interface": return Color.GREEN
		"evolution": return Color.PURPLE
		"reality_anchor": return Color.RED
		"time_flow": return Color.BLUE
		"dimensional_gate": return Color.MAGENTA
		"akashic_link": return Color.ORANGE
		_: return Color.WHITE

# ===== TRACKBALL CAMERA INTEGRATION =====

func _setup_trackball_camera() -> void:
	"""Setup trackball camera integration"""
	
	# Load the camera point scene
	var camera_scene = preload("res://scenes/main/camera_point.tscn")
	if camera_scene:
		camera_point = camera_scene.instantiate()
		camera_point.name = "PlasmoidCameraPoint"
		add_child(camera_point)
		
		# Position camera behind and above plasmoid
		camera_point.position = Vector3(0, 3, 5)
		
		print("🌟 Trackball camera integrated with plasmoid")
	else:
		print("⚠️ Could not load trackball camera scene")

# ===== INPUT SYSTEM =====

func _setup_input_system() -> void:
	"""Setup input handling for the plasmoid"""
	set_process_unhandled_input(true)

func _handle_plasmoid_input(event: InputEvent) -> void:
	"""Handle plasmoid-specific input"""
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_TAB:
				_toggle_socket_visualization()
			KEY_G:
				if event.ctrl_pressed:
					_toggle_socket_glow()
			KEY_P:
				if event.ctrl_pressed:
					_print_plasmoid_status()

func _process_movement(delta: float) -> void:
	"""Process plasmoid movement with 6DOF"""
	
	# Get input
	movement_input = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		movement_input.z -= 1
	if Input.is_action_pressed("move_backward"):
		movement_input.z += 1
	if Input.is_action_pressed("move_left"):
		movement_input.x -= 1
	if Input.is_action_pressed("move_right"):
		movement_input.x += 1
	if Input.is_action_pressed("move_up"):
		movement_input.y += 1
	if Input.is_action_pressed("move_down"):
		movement_input.y -= 1
	
	# Check for sprint
	is_sprinting = Input.is_action_pressed("sprint")
	
	# Apply movement
	if movement_input.length() > 0:
		movement_input = movement_input.normalized()
		
		# Get camera direction for forward movement
		var forward_direction = Vector3.FORWARD
		if camera_point and camera_point.has_method("get_forward_direction"):
			forward_direction = camera_point.get_forward_direction()
		
		# Transform movement relative to camera
		var camera_basis = camera_point.global_transform.basis if camera_point else Basis.IDENTITY
		var world_movement = camera_basis * movement_input
		
		# Apply speed
		var current_speed = movement_speed
		if is_sprinting:
			current_speed *= sprint_multiplier
		
		velocity = world_movement * current_speed
		global_position += velocity * delta
		
		# Update consciousness level based on movement
		_update_movement_consciousness()

func _update_movement_consciousness() -> void:
	"""Update consciousness based on movement"""
	# Subtle consciousness increase during active movement
	if movement_input.length() > 0:
		consciousness_level = min(7, consciousness_level + 0.001)
		update_consciousness_visual()

# ===== SOCKET VISUALIZATIONS =====

func _update_socket_visuals(delta: float) -> void:
	"""Update socket visual effects"""
	
	for socket_name in socket_visualization:
		var socket_visual = socket_visualization[socket_name]
		if socket_visual:
			# Rotate sockets
			socket_visual.rotation.y += delta * 0.5
			
			# Pulse effect based on consciousness
			var pulse = sin(Time.get_ticks_msec() * 0.003) * 0.2 + 1.0
			socket_visual.scale = Vector3.ONE * pulse * (consciousness_level / 7.0)

func _toggle_socket_visualization() -> void:
	"""Toggle socket visibility"""
	if socket_container:
		socket_container.visible = not socket_container.visible
		print("🌟 Socket visualization: %s" % ("visible" if socket_container.visible else "hidden"))

func _toggle_socket_glow() -> void:
	"""Toggle socket glow intensity"""
	socket_glow_intensity = 3.0 if socket_glow_intensity < 2.0 else 1.0
	
	if plasmoid_material:
		plasmoid_material.set_shader_parameter("glow_intensity", socket_glow_intensity)
	
	print("🌟 Socket glow intensity: %.1f" % socket_glow_intensity)

# ===== PLASMOID EFFECTS =====

func _update_plasmoid_effects(delta: float) -> void:
	"""Update plasmoid visual effects"""
	
	if plasmoid_material:
		# Update consciousness level in shader
		plasmoid_material.set_shader_parameter("consciousness_level", float(consciousness_level))
		
		# Update time for animated effects
		var time = Time.get_ticks_msec() * 0.001
		plasmoid_material.set_shader_parameter("time", time)

# ===== STATE MANAGEMENT =====

func _save_plasmoid_state() -> void:
	"""Save plasmoid state"""
	var state = {
		"position": global_position,
		"consciousness_level": consciousness_level,
		"active_sockets": active_sockets.keys(),
		"socket_glow_intensity": socket_glow_intensity
	}
	
	var save_path = "user://player_plasmoid_state.json"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state))
		file.close()
		print("🌟 Plasmoid state saved")

func _print_plasmoid_status() -> void:
	"""Print current plasmoid status"""
	print("🌟 PLAYER PLASMOID STATUS:")
	print("   Position: %s" % global_position)
	print("   Consciousness Level: %d" % consciousness_level)
	print("   Active Sockets: %d" % active_sockets.size())
	print("   Movement Speed: %.1f" % movement_speed)
	print("   Socket Glow: %.1f" % socket_glow_intensity)

# ===== PUBLIC API =====

func get_socket(socket_name: String) -> Node:
	"""Get socket instance by name"""
	if active_sockets.has(socket_name):
		return active_sockets[socket_name].instance
	return null

func add_custom_socket(socket_name: String, position: Vector3, socket_scene: PackedScene = null) -> void:
	"""Add a custom socket to the plasmoid"""
	var socket_path = "res://sockets/CustomSocket.tscn"
	_create_socket(socket_name, position, socket_path)
	print("🌟 Custom socket '%s' added at %s" % [socket_name, position])

func remove_socket(socket_name: String) -> void:
	"""Remove a socket from the plasmoid"""
	if active_sockets.has(socket_name):
		var socket_data = active_sockets[socket_name]
		if socket_data.visual:
			socket_data.visual.queue_free()
		if socket_data.instance:
			socket_data.instance.queue_free()
		
		active_sockets.erase(socket_name)
		socket_visualization.erase(socket_name)
		print("🌟 Socket '%s' removed" % socket_name)

func _to_string() -> String:
	return "PlayerPlasmoid [Pos: %s, Consciousness: %d, Sockets: %d]" % [
		global_position, consciousness_level, active_sockets.size()
	]