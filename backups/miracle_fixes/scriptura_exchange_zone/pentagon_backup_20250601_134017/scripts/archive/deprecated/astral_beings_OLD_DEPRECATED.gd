# ==================================================
# SCRIPT NAME: astral_beings.gd
# DESCRIPTION: Astral beings that help the ragdoll and assist with scene creation
# PURPOSE: Invisible helpers that stabilize ragdoll, move objects, and assist creation
# CREATED: 2025-05-24 - Ethereal assistance for Garden of Eden building
# ==================================================

extends UniversalBeingBase
# Astral Being Manager
var astral_beings: Array[AstralBeing] = []
var max_beings: int = 5
var spawn_radius: float = 10.0

# References
var ragdoll_controller: Node = null
var floodgate: Node = null

# Assistance Modes
enum AssistanceMode {
	RAGDOLL_SUPPORT,
	OBJECT_MANIPULATION,
	SCENE_ORGANIZATION,
	ENVIRONMENTAL_HARMONY,
	CREATIVE_ASSISTANCE
}

# Astral Being Class
class AstralBeing:
	var position: Vector3
	var target_position: Vector3
	var assistance_mode: AssistanceMode
	var is_active: bool = true
	var energy_level: float = 100.0
	var assistance_target: Node = null
	var visualization_particle: GPUParticles3D = null
	
	func _init(spawn_pos: Vector3):
		position = spawn_pos
		target_position = spawn_pos
		assistance_mode = AssistanceMode.RAGDOLL_SUPPORT

func _ready() -> void:
	print("[AstralBeings] Initializing ethereal assistance system...")
	
	# Get references
	ragdoll_controller = get_node_or_null("../RagdollController")
	floodgate = get_node("/root/FloodgateController") if has_node("/root/FloodgateController") else null
	
	# Spawn initial astral beings
	_spawn_initial_beings()
	
	# Connect to ragdoll events if controller exists
	if ragdoll_controller:
		ragdoll_controller.connect("player_needs_help", _on_player_needs_help)
		ragdoll_controller.connect("object_picked_up", _on_object_interaction)
		ragdoll_controller.connect("object_dropped", _on_object_interaction)
	
	print("[AstralBeings] " + str(astral_beings.size()) + " astral beings ready to assist")

func _spawn_initial_beings() -> void:
	for i in range(max_beings):
		var spawn_pos = Vector3(
			randf_range(-spawn_radius, spawn_radius),
			randf_range(2, 8),  # Float in the air
			randf_range(-spawn_radius, spawn_radius)
		)
		
		var being = AstralBeing.new(spawn_pos)
		astral_beings.append(being)
		
		# Create subtle particle visualization
		_create_being_visualization(being)

func _create_being_visualization(being: AstralBeing) -> void:
	var particles = GPUParticles3D.new()
	particles.name = "AstralBeing" + str(astral_beings.size())
	add_child(particles)
	
	# Configure particle system for ethereal effect
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.initial_velocity_min = 0.5
	material.initial_velocity_max = 1.5
	material.gravity = Vector3(0, -0.5, 0)
	material.scale_min = 0.1
	material.scale_max = 0.3
	
	particles.process_material = material
	particles.amount = 20
	particles.lifetime = 3.0
	particles.visibility_aabb = AABB(Vector3(-2, -2, -2), Vector3(4, 4, 4))
	
	# Subtle glow material
	var mesh = SphereMesh.new()
	mesh.radius = 0.1
	mesh.height = 0.2
	particles.draw_pass_1 = mesh
	
	being.visualization_particle = particles
	
	# Position the visualization
	particles.global_position = being.position

func _process(delta: float) -> void:
	for being in astral_beings:
		if being.is_active:
			_update_being(being, delta)

func _update_being(being: AstralBeing, delta: float) -> void:
	# Update energy
	being.energy_level = min(100.0, being.energy_level + delta * 2.0)
	
	# Move toward target
	var direction = (being.target_position - being.position).normalized()
	being.position += direction * delta * 3.0
	
	# Update visualization position
	if being.visualization_particle:
		being.visualization_particle.global_position = being.position
	
	# Perform assistance based on mode
	match being.assistance_mode:
		AssistanceMode.RAGDOLL_SUPPORT:
			_assist_ragdoll_support(being, delta)
		AssistanceMode.OBJECT_MANIPULATION:
			_assist_object_manipulation(being, delta)
		AssistanceMode.SCENE_ORGANIZATION:
			_assist_scene_organization(being, delta)
		AssistanceMode.ENVIRONMENTAL_HARMONY:
			_assist_environmental_harmony(being, delta)
		AssistanceMode.CREATIVE_ASSISTANCE:
			_assist_creative_work(being, delta)

func _assist_ragdoll_support(being: AstralBeing, delta: float) -> void:
	if not ragdoll_controller:
		return
		
	var ragdoll_body = ragdoll_controller.get("ragdoll_body")
	if not ragdoll_body:
		return
		
	var ragdoll_main_body = null
	if ragdoll_body.has_method("get_body"):
		ragdoll_main_body = ragdoll_body.get_body()
	
	if not ragdoll_main_body:
		return
		
	# Move being to hover above ragdoll
	being.target_position = ragdoll_body.global_position + Vector3(0, 3, 0)
	
	# Check if ragdoll has fallen over
	var ragdoll_rotation = ragdoll_main_body.rotation
	var is_fallen = abs(ragdoll_rotation.x) > 1.5 or abs(ragdoll_rotation.z) > 1.5
	
	if is_fallen and being.energy_level > 50.0:
		# Help ragdoll stand up
		_help_ragdoll_stand_up(ragdoll_main_body, being)
		being.energy_level -= 25.0

func _help_ragdoll_stand_up(ragdoll_body: RigidBody3D, being: AstralBeing) -> void:
	print("[AstralBeings] Astral being helping ragdoll stand up...")
	
	# Apply upward force
	ragdoll_body.apply_central_impulse(Vector3(0, 20, 0))
	
	# Stabilize rotation
	var stabilizing_torque = Vector3(
		-ragdoll_body.rotation.x * 50,
		0,
		-ragdoll_body.rotation.z * 50
	)
	ragdoll_body.apply_torque_impulse(stabilizing_torque)
	
	# Particle effect for assistance
	_create_assistance_effect(being.position)

func _assist_object_manipulation(being: AstralBeing, delta: float) -> void:
	if being.assistance_target and is_instance_valid(being.assistance_target):
		var obj = being.assistance_target as RigidBody3D
		if obj:
			# Move being near object
			being.target_position = obj.global_position + Vector3(0, 2, 0)
			
			# Stabilize object if it's being carried
			if obj.is_in_group("carried"):
				obj.angular_velocity *= 0.95  # Reduce spinning
				
				# Gentle upward force to help carrying
				if obj.linear_velocity.y < -2:
					obj.apply_central_force(Vector3(0, 10, 0))

func _assist_scene_organization(being: AstralBeing, delta: float) -> void:
	# Look for objects that are out of place or need organizing
	var all_objects = get_tree().get_nodes_in_group("objects")
	
	if all_objects.size() > 0:
		var random_object = all_objects[randi() % all_objects.size()]
		if random_object is RigidBody3D:
			being.target_position = random_object.global_position + Vector3(0, 2, 0)
			
			# Occasionally nudge objects into better positions
			if randf() < 0.001 and being.energy_level > 30.0:  # Very rare, gentle nudges
				var gentle_force = Vector3(
					randf_range(-2, 2),
					0,
					randf_range(-2, 2)
				)
				random_object.apply_central_impulse(gentle_force)
				being.energy_level -= 10.0

func _assist_environmental_harmony(being: AstralBeing, delta: float) -> void:
	# Create harmony in the environment
	being.target_position.y = 5.0 + sin(Time.get_ticks_msec() / 1000.0 + being.position.x) * 2.0
	
	# Emit calming energy (visual effect)
	if being.visualization_particle and randf() < 0.05:
		being.visualization_particle.amount = int(being.energy_level / 5.0)

func _assist_creative_work(being: AstralBeing, delta: float) -> void:
	# Assist with creative tasks by providing inspiration
	# This could interact with the floodgate system
	if floodgate and randf() < 0.001:
		# Occasionally suggest creative ideas through the system
		print("[AstralBeings] Astral being whispers creative inspiration...")

func _create_assistance_effect(position: Vector3) -> void:
	# Create temporary particle effect to show assistance
	var temp_particles = GPUParticles3D.new()
	add_child(temp_particles)
	temp_particles.global_position = position
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 4.0
	material.gravity = Vector3(0, -1, 0)
	
	temp_particles.process_material = material
	temp_particles.amount = 50
	temp_particles.lifetime = 2.0
	temp_particles.emitting = true
	
	# Remove after effect
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(temp_particles):
		temp_particles.queue_free()

# EVENT HANDLERS

func _on_player_needs_help() -> void:
	print("[AstralBeings] Player needs help - assigning astral beings...")
	
	# Assign beings to help
	for being in astral_beings:
		if being.energy_level > 70.0:
			being.assistance_mode = AssistanceMode.CREATIVE_ASSISTANCE
			being.energy_level -= 20.0

func _on_object_interaction(object: RigidBody3D) -> void:
	# Assign a being to help with object manipulation
	var available_being = _find_available_being()
	if available_being:
		available_being.assistance_mode = AssistanceMode.OBJECT_MANIPULATION
		available_being.assistance_target = object
		print("[AstralBeings] Astral being assigned to assist with: " + object.name)

func _find_available_being() -> AstralBeing:
	for being in astral_beings:
		if being.energy_level > 50.0 and being.assistance_mode == AssistanceMode.RAGDOLL_SUPPORT:
			return being
	return null

# PUBLIC INTERFACE


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
func summon_assistance(mode: AssistanceMode, target: Node = null) -> void:
	var being = _find_available_being()
	if being:
		being.assistance_mode = mode
		being.assistance_target = target
		print("[AstralBeings] Summoned astral assistance for mode: " + str(mode))

func set_all_beings_mode(mode: AssistanceMode) -> void:
	for being in astral_beings:
		being.assistance_mode = mode
	print("[AstralBeings] All beings set to mode: " + str(mode))

func get_beings_status() -> Dictionary:
	var status = {
		"total_beings": astral_beings.size(),
		"active_beings": 0,
		"average_energy": 0.0,
		"modes": {}
	}
	
	var total_energy = 0.0
	for being in astral_beings:
		if being.is_active:
			status.active_beings += 1
		total_energy += being.energy_level
		
		var mode_name = str(being.assistance_mode)
		if status.modes.has(mode_name):
			status.modes[mode_name] += 1
		else:
			status.modes[mode_name] = 1
	
	if astral_beings.size() > 0:
		status.average_energy = total_energy / astral_beings.size()
	
	return status

# CONSOLE COMMANDS

func cmd_beings_status() -> void:
	var status = get_beings_status()
	print("[AstralBeings] Status: " + str(status))

func cmd_beings_help_ragdoll() -> void:
	set_all_beings_mode(AssistanceMode.RAGDOLL_SUPPORT)

func cmd_beings_organize() -> void:
	set_all_beings_mode(AssistanceMode.SCENE_ORGANIZATION)

func cmd_beings_harmony() -> void:
	set_all_beings_mode(AssistanceMode.ENVIRONMENTAL_HARMONY)