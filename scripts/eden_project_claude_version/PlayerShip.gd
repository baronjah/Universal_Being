# PlayerShip.gd
extends UniversalBeing
class_name PlayerShip

# Movement properties
@export var thrust_power: float = 1000.0
@export var rotation_speed: float = 2.0
@export var max_velocity: float = 500.0
@export var drag: float = 0.99
@export var strafe_power: float = 800.0
@export var vertical_power: float = 600.0

# Ship state
var velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO
var energy: float = 100.0
var max_energy: float = 100.0
var shields: float = 100.0
var max_shields: float = 100.0

# Consciousness integration
signal consciousness_resonance_changed(frequency: float)
signal mining_target_acquired(target: Node3D)
signal energy_depleted()
signal ship_damaged(amount: float)

var consciousness_frequency: float = 432.0
var perception_radius: float = 100.0
var mining_target: Node3D = null
var mining_beam_active: bool = false

# Visual components
var ship_mesh: MeshInstance3D
var engine_particles: GPUParticles3D
var shield_effect: MeshInstance3D
var mining_beam: MeshInstance3D
var consciousness_aura: GPUParticles3D

# Camera system
var camera_pivot: Node3D
var camera: Camera3D
var camera_distance: float = 30.0
var camera_height: float = 10.0
var mouse_sensitivity: float = 0.002

# HUD references
var hud: Control = null
var crosshair: TextureRect = null

# Input state
var mouse_captured: bool = true
var input_vector: Vector3 = Vector3.ZERO
var rotation_input: Vector3 = Vector3.ZERO

# Pentagon implementation
func pentagon_init() -> void:
	super.pentagon_init()
	name = "PlayerShip"
	consciousness_level = 1  # Player starts aware
	_initialize_ship_components()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_setup_camera_system()
	_setup_visual_effects()
	_setup_collision()
	_connect_to_systems()
	_capture_mouse()
	
	# Register with FloodGates
	if FloodGates:
		FloodGates.register_being(self)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_gather_input()
	_apply_physics(delta)
	_update_consciousness_frequency(delta)
	_update_energy_systems(delta)
	_update_visual_effects(delta)
	_update_camera(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event is InputEventMouseMotion and mouse_captured:
		_handle_mouse_look(event)
	elif event.is_action_pressed("toggle_mouse"):
		_toggle_mouse_capture()
	elif event.is_action_pressed("target_nearest"):
		_target_nearest_asteroid()
	elif event.is_action_pressed("boost"):
		_activate_boost()

func pentagon_sewers() -> void:
	_save_ship_state()
	if FloodGates:
		FloodGates.unregister_being(self)
	super.pentagon_sewers()

# Initialization
func _initialize_ship_components() -> void:
	# Set up socket connections for modular ship parts
	socket_manager.create_socket("engine_socket", "engine_component")
	socket_manager.create_socket("weapon_socket", "weapon_component")
	socket_manager.create_socket("shield_socket", "shield_component")
	socket_manager.create_socket("scanner_socket", "scanner_component")

func _setup_camera_system() -> void:
	# Create camera pivot for smooth rotation
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	
	# Create camera
	camera = Camera3D.new()
	camera.name = "ShipCamera"
	camera.position = Vector3(0, camera_height, camera_distance)
	camera.look_at(global_position, Vector3.UP)
	camera.fov = 75
	camera.near = 0.1
	camera.far = 10000.0
	camera_pivot.add_child(camera)

func _setup_visual_effects() -> void:
	# Ship mesh
	ship_mesh = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(4, 2, 6)
	ship_mesh.mesh = box_mesh
	
	var ship_material = StandardMaterial3D.new()
	ship_material.albedo_color = Color(0.5, 0.7, 1.0)
	ship_material.metallic = 0.8
	ship_material.roughness = 0.2
	ship_mesh.material_override = ship_material
	add_child(ship_mesh)
	
	# Engine particles
	engine_particles = GPUParticles3D.new()
	engine_particles.amount = 100
	engine_particles.lifetime = 1.0
	engine_particles.position = Vector3(0, 0, 3)
	
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 0, 1)
	particle_material.initial_velocity_min = 10.0
	particle_material.initial_velocity_max = 20.0
	particle_material.color = Color(0.5, 0.8, 1.0)
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_material.emission_box_extents = Vector3(1, 0.5, 0.1)
	engine_particles.process_material = particle_material
	engine_particles.draw_pass_1 = SphereMesh.new()
	engine_particles.draw_pass_1.radius = 0.1
	engine_particles.draw_pass_1.height = 0.2
	add_child(engine_particles)
	
	# Shield effect
	_create_shield_effect()
	
	# Mining beam (initially hidden)
	_create_mining_beam()
	
	# Consciousness aura
	_create_consciousness_aura()

func _create_shield_effect() -> void:
	shield_effect = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 5.0
	sphere_mesh.height = 10.0
	shield_effect.mesh = sphere_mesh
	
	var shield_material = StandardMaterial3D.new()
	shield_material.albedo_color = Color(0.5, 0.8, 1.0, 0.3)
	shield_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shield_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	shield_material.rim_enabled = true
	shield_material.rim = 1.0
	shield_material.rim_tint = 0.5
	shield_effect.material_override = shield_material
	shield_effect.visible = false
	add_child(shield_effect)

func _create_mining_beam() -> void:
	mining_beam = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 0.1
	cylinder_mesh.bottom_radius = 2.0
	cylinder_mesh.height = 50.0
	mining_beam.mesh = cylinder_mesh
	mining_beam.position = Vector3(0, -1, -25)
	mining_beam.rotation.x = PI/2
	
	var beam_material = StandardMaterial3D.new()
	beam_material.albedo_color = Color(1.0, 0.8, 0.3, 0.5)
	beam_material.emission_enabled = true
	beam_material.emission = Color(1.0, 0.8, 0.3)
	beam_material.emission_energy = 2.0
	beam_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mining_beam.material_override = beam_material
	mining_beam.visible = false
	add_child(mining_beam)

func _create_consciousness_aura() -> void:
	consciousness_aura = GPUParticles3D.new()
	consciousness_aura.amount = 50
	consciousness_aura.lifetime = 3.0
	consciousness_aura.visibility_aabb = AABB(Vector3(-10, -10, -10), Vector3(20, 20, 20))
	
	var aura_material = ParticleProcessMaterial.new()
	aura_material.direction = Vector3(0, 1, 0)
	aura_material.initial_velocity_min = 0.5
	aura_material.initial_velocity_max = 1.0
	aura_material.angular_velocity_min = -180.0
	aura_material.angular_velocity_max = 180.0
	aura_material.spread = 45.0
	aura_material.gravity = Vector3.ZERO
	aura_material.scale_min = 0.1
	aura_material.scale_max = 0.3
	aura_material.color = Color(0.7, 0.8, 1.0, 0.5)
	consciousness_aura.process_material = aura_material
	consciousness_aura.draw_pass_1 = SphereMesh.new()
	consciousness_aura.draw_pass_1.radius = 0.2
	consciousness_aura.draw_pass_1.height = 0.4
	add_child(consciousness_aura)

func _setup_collision() -> void:
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(4, 2, 6)
	collision_shape.shape = box_shape
	add_child(collision_shape)
	
	# Set collision layers
	collision_layer = 1  # Player layer
	collision_mask = 30  # Everything except player

func _connect_to_systems() -> void:
	# Connect to consciousness system if available
	var consciousness_system = get_node_or_null("/root/SpaceGame/ConsciousnessSystem")
	if consciousness_system:
		consciousness_resonance_changed.connect(consciousness_system.tune_frequency)

# Input handling
func _gather_input() -> void:
	input_vector = Vector3.ZERO
	
	# Forward/backward
	if Input.is_action_pressed("thrust_forward"):
		input_vector.z -= 1.0
	if Input.is_action_pressed("thrust_backward"):
		input_vector.z += 1.0
	
	# Strafe left/right
	if Input.is_action_pressed("strafe_left"):
		input_vector.x -= 1.0
	if Input.is_action_pressed("strafe_right"):
		input_vector.x += 1.0
	
	# Up/down
	if Input.is_action_pressed("thrust_up"):
		input_vector.y += 1.0
	if Input.is_action_pressed("thrust_down"):
		input_vector.y -= 1.0
	
	# Rotation (keyboard backup)
	rotation_input = Vector3.ZERO
	if Input.is_action_pressed("pitch_up"):
		rotation_input.x -= 1.0
	if Input.is_action_pressed("pitch_down"):
		rotation_input.x += 1.0
	if Input.is_action_pressed("yaw_left"):
		rotation_input.y -= 1.0
	if Input.is_action_pressed("yaw_right"):
		rotation_input.y += 1.0
	if Input.is_action_pressed("roll_left"):
		rotation_input.z -= 1.0
	if Input.is_action_pressed("roll_right"):
		rotation_input.z += 1.0
	
	# Mining
	mining_beam_active = Input.is_action_pressed("mining_beam") and mining_target != null

func _handle_mouse_look(event: InputEventMouseMotion) -> void:
	if not mouse_captured:
		return
	
	# Apply mouse movement to rotation
	rotate_y(-event.relative.x * mouse_sensitivity)
	
	# Pitch is applied to camera pivot for better control
	var pitch_delta = -event.relative.y * mouse_sensitivity
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x + pitch_delta, -PI/3, PI/3)

# Physics
func _apply_physics(delta: float) -> void:
	# Apply thrust
	if input_vector.length() > 0 and energy > 0:
		var thrust_dir = transform.basis * input_vector.normalized()
		
		# Different power for different directions
		var thrust = Vector3.ZERO
		thrust += transform.basis.z * input_vector.z * thrust_power
		thrust += transform.basis.x * input_vector.x * strafe_power
		thrust += transform.basis.y * input_vector.y * vertical_power
		
		velocity += thrust * delta
		
		# Consume energy
		_consume_energy(delta * 5.0)
		
		# Update engine particles
		engine_particles.amount_ratio = input_vector.length()
	else:
		engine_particles.amount_ratio = 0.2
	
	# Apply rotation
	if rotation_input.length() > 0:
		angular_velocity += rotation_input * rotation_speed * delta
	
	# Apply angular velocity
	rotate_x(angular_velocity.x * delta)
	rotate_y(angular_velocity.y * delta)
	rotate_z(angular_velocity.z * delta)
	
	# Damping
	angular_velocity *= 0.95
	
	# Limit velocity
	if velocity.length() > max_velocity:
		velocity = velocity.normalized() * max_velocity
	
	# Apply velocity
	global_position += velocity * delta
	
	# Apply drag
	velocity *= drag

# Ship systems
func _update_consciousness_frequency(delta: float) -> void:
	# Frequency can be tuned
	if Input.is_action_pressed("frequency_up"):
		consciousness_frequency += delta * 50
	elif Input.is_action_pressed("frequency_down"):
		consciousness_frequency -= delta * 50
	
	consciousness_frequency = clamp(consciousness_frequency, 100.0, 1000.0)
	
	# Update visual based on frequency
	var freq_normalized = (consciousness_frequency - 100.0) / 900.0
	consciousness_aura.process_material.color = Color(
		0.7 - freq_normalized * 0.2,
		0.8,
		1.0 - freq_normalized * 0.3,
		0.5
	)
	
	# Emit signal if changed significantly
	static var last_emitted_freq = 432.0
	if abs(consciousness_frequency - last_emitted_freq) > 5.0:
		consciousness_resonance_changed.emit(consciousness_frequency)
		last_emitted_freq = consciousness_frequency

func _update_energy_systems(delta: float) -> void:
	# Regenerate energy
	if energy < max_energy and not mining_beam_active:
		energy += delta * 10.0  # 10 energy per second regen
		energy = min(energy, max_energy)
	
	# Shield regeneration
	if shields < max_shields:
		shields += delta * 5.0
		shields = min(shields, max_shields)
	
	# Mining beam energy consumption
	if mining_beam_active:
		_consume_energy(delta * 20.0)  # 20 energy per second
		if energy <= 0:
			mining_beam_active = false
			energy_depleted.emit()

func _update_visual_effects(delta: float) -> void:
	# Shield visibility based on shield level
	shield_effect.visible = shields < max_shields * 0.5
	if shield_effect.visible:
		var shield_alpha = (max_shields - shields) / max_shields
		shield_effect.material_override.albedo_color.a = shield_alpha * 0.3
	
	# Mining beam
	mining_beam.visible = mining_beam_active
	if mining_beam_active and mining_target:
		# Point beam at target
		mining_beam.look_at(mining_target.global_position, Vector3.UP)
		
		# Adjust beam length
		var distance = global_position.distance_to(mining_target.global_position)
		var mesh = mining_beam.mesh as CylinderMesh
		mesh.height = distance
		mining_beam.position.z = -distance / 2
	
	# Engine glow based on thrust
	var thrust_amount = input_vector.length()
	engine_particles.amount_ratio = thrust_amount
	if ship_mesh:
		var emission_color = Color(0.5, 0.8, 1.0) * thrust_amount * 0.5
		ship_mesh.material_override.emission = emission_color

func _update_camera(delta: float) -> void:
	# Smooth camera follow
	var target_pos = global_position
	camera_pivot.global_position = camera_pivot.global_position.lerp(target_pos, delta * 10.0)
	
	# Dynamic camera distance based on speed
	var speed_factor = velocity.length() / max_velocity
	var target_distance = camera_distance + speed_factor * 20.0
	camera.position.z = lerp(camera.position.z, target_distance, delta * 2.0)

# Ship functions
func apply_thrust(amount: float) -> void:
	if energy > 0:
		velocity += transform.basis.z * -amount * thrust_power * get_process_delta_time()
		_consume_energy(abs(amount) * 2.0)

func take_damage(amount: float) -> void:
	shields -= amount
	if shields < 0:
		# Damage passes through to hull
		var hull_damage = -shields
		shields = 0
		# Implement hull damage here
		ship_damaged.emit(hull_damage)

func _consume_energy(amount: float) -> void:
	energy -= amount
	energy = max(energy, 0)
	if energy == 0:
		energy_depleted.emit()

func repair_shields(amount: float) -> void:
	shields = min(shields + amount, max_shields)

func refill_energy(amount: float) -> void:
	energy = min(energy + amount, max_energy)

# Mining system
func _target_nearest_asteroid() -> void:
	var asteroids = get_tree().get_nodes_in_group("asteroids")
	var nearest = null
	var nearest_distance = INF
	
	for asteroid in asteroids:
		if asteroid is Node3D:
			var distance = global_position.distance_to(asteroid.global_position)
			if distance < nearest_distance and distance < 200.0:  # Max targeting range
				nearest = asteroid
				nearest_distance = distance
	
	if nearest:
		mining_target = nearest
		mining_target_acquired.emit(mining_target)

func has_mining_target() -> bool:
	return mining_target != null and is_instance_valid(mining_target)

func get_mining_target() -> Node3D:
	return mining_target

# Special abilities
func _activate_boost() -> void:
	if energy >= 20.0:
		velocity += transform.basis.z * -thrust_power * 2.0
		_consume_energy(20.0)
		
		# Visual effect
		var tween = create_tween()
		tween.tween_property(engine_particles, "amount", 500, 0.1)
		tween.tween_property(engine_particles, "amount", 100, 0.5)

# Utility functions
func _capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func _toggle_mouse_capture() -> void:
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_captured = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_captured = true

func _save_ship_state() -> void:
	if AkashicRecordsSystem:
		var ship_data = {
			"position": global_position,
			"rotation": rotation,
			"velocity": velocity,
			"energy": energy,
			"shields": shields,
			"consciousness_frequency": consciousness_frequency
		}
		AkashicRecordsSystem.save_player_ship_data(ship_data)

func load_ship_state(data: Dictionary) -> void:
	global_position = data.get("position", Vector3.ZERO)
	rotation = data.get("rotation", Vector3.ZERO)
	velocity = data.get("velocity", Vector3.ZERO)
	energy = data.get("energy", max_energy)
	shields = data.get("shields", max_shields)
	consciousness_frequency = data.get("consciousness_frequency", 432.0)

# Consciousness integration
func receive_consciousness_energy(amount: float) -> void:
	consciousness_level += amount * 0.1
	consciousness_level = min(consciousness_level, 7)
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property(consciousness_aura, "amount", 200, 0.2)
	tween.tween_property(consciousness_aura, "amount", 50, 0.8)

# Socket connections for upgrades
func install_upgrade(upgrade_type: String, component: Node) -> bool:
	match upgrade_type:
		"engine":
			return connect_to_socket("engine_socket", component)
		"weapon":
			return connect_to_socket("weapon_socket", component)
		"shield":
			return connect_to_socket("shield_socket", component)
		"scanner":
			return connect_to_socket("scanner_socket", component)
		_:
			return false

# HUD connection
func connect_hud(hud_instance: Control) -> void:
	hud = hud_instance
	
	# Update HUD with ship data
	if hud:
		hud.set_energy(energy, max_energy)
		hud.set_shields(shields, max_shields)
		hud.set_consciousness_level(consciousness_level)
		hud.set_frequency(consciousness_frequency)

# Debug
func _on_debug_key_pressed() -> void:
	print("=== PLAYER SHIP DEBUG ===")
	print("Position: ", global_position)
	print("Velocity: ", velocity, " (", velocity.length(), " m/s)")
	print("Energy: ", energy, "/", max_energy)
	print("Shields: ", shields, "/", max_shields)
	print("Consciousness: Level ", consciousness_level, " @ ", consciousness_frequency, "Hz")
	print("Mining Target: ", mining_target)
	print("=======================")

# Get ship status for UI
func get_ship_status() -> Dictionary:
	return {
		"energy": energy,
		"max_energy": max_energy,
		"shields": shields,
		"max_shields": max_shields,
		"velocity": velocity.length(),
		"consciousness_level": consciousness_level,
		"consciousness_frequency": consciousness_frequency,
		"position": global_position
	}
