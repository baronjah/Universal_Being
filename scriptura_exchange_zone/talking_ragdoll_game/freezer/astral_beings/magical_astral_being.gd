# ==================================================
# SCRIPT NAME: magical_astral_being.gd
# DESCRIPTION: Simple magical beings that teleport and do tasks
# PURPOSE: Point A to B movement with magical effects
# CREATED: 2025-05-28 - Magic-based task system
# ==================================================

extends UniversalBeingBase
signal task_completed(task_name: String)
signal teleported(from: Vector3, to: Vector3)
signal magic_used(spell_name: String)

# Visual components
var mesh_instance: MeshInstance3D
var particles: GPUParticles3D
var glow_light: OmniLight3D
var trail: Node3D

# Properties
var being_name: String = "Astral Being"
var color: Color = Color(0.5, 0.8, 1.0, 0.8)
var size: float = 0.5
var glow_intensity: float = 2.0

# Task system
var current_task: Dictionary = {}
var task_queue: Array = []
var is_busy: bool = false

# Movement
var teleport_speed: float = 0.5  # Time to teleport
var float_amplitude: float = 0.2
var float_speed: float = 2.0
var rotation_speed: float = 1.0

# Magic abilities
var abilities = {
	"teleport": true,
	"levitate_objects": true,
	"create_light": true,
	"organize": true,
	"clean": true,
	"repair": true
}

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_visuals()
	_setup_particles()
	set_physics_process(true)
	print("[MagicalAstralBeing] %s manifested" % being_name)

func _create_visuals() -> void:
	# Main mesh (glowing sphere)
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.mesh.radial_segments = 16
	mesh_instance.mesh.rings = 8
	mesh_instance.mesh.radius = size
	mesh_instance.mesh.height = size * 2
	add_child(mesh_instance)
	
	# Glowing material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy = glow_intensity
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.8
	material.rim_enabled = true
	material.rim = 1.0
	material.rim_tint = 0.5
	mesh_instance.material_override = material
	
	# Glow light
	glow_light = OmniLight3D.new()
	glow_light.light_color = color
	glow_light.light_energy = glow_intensity
	glow_light.omni_range = 5.0
	add_child(glow_light)

func _setup_particles() -> void:
	particles = GPUParticles3D.new()
	particles.amount = 50
	particles.lifetime = 2.0
	particles.preprocess = 0.5
	
	# Create particle material
	var process_material = ParticleProcessMaterial.new()
	process_material.initial_velocity_min = 0.5
	process_material.initial_velocity_max = 1.5
	process_material.direction = Vector3(0, 1, 0)
	process_material.spread = 45.0
	process_material.gravity = Vector3(0, -0.5, 0)
	process_material.scale_min = 0.1
	process_material.scale_max = 0.3
	
	particles.process_material = process_material
	particles.draw_pass_1 = SphereMesh.new()
	particles.draw_pass_1.radius = 0.05
	particles.draw_pass_1.height = 0.1
	
	# Particle material
	var particle_mat = MaterialLibrary.get_material("default")
	particle_mat.albedo_color = color
	particle_mat.emission_enabled = true
	particle_mat.emission = color
	particle_mat.emission_energy = 2.0
	particles.material_override = particle_mat
	
	add_child(particles)


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Floating animation
	var time = Time.get_ticks_msec() / 1000.0
	position.y += sin(time * float_speed) * float_amplitude * delta
	
	# Gentle rotation
	rotate_y(rotation_speed * delta)
	
	# Process tasks
	if not is_busy and task_queue.size() > 0:
		_process_next_task()

# ================================
# TASK SYSTEM
# ================================


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

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
func add_task(task_type: String, params: Dictionary = {}) -> void:
	var task = {
		"type": task_type,
		"params": params,
		"id": Time.get_ticks_msec()
	}
	task_queue.append(task)
	print("[%s] Task queued: %s" % [being_name, task_type])

func _process_next_task() -> void:
	if task_queue.is_empty():
		return
	
	current_task = task_queue.pop_front()
	is_busy = true
	
	match current_task.type:
		"move_to":
			_task_move_to(current_task.params.get("position", Vector3.ZERO))
		"collect_objects":
			_task_collect_objects(current_task.params.get("radius", 5.0))
		"organize_area":
			_task_organize_area(current_task.params.get("center", position))
		"create_light":
			_task_create_light(current_task.params.get("position", position))
		"patrol":
			_task_patrol(current_task.params.get("points", []))
		"help_ragdoll":
			_task_help_ragdoll()
		"clean_scene":
			_task_clean_scene()
		_:
			print("[%s] Unknown task: %s" % [being_name, current_task.type])
			_complete_task()

# ================================
# TASK IMPLEMENTATIONS
# ================================

func _task_move_to(target_position: Vector3) -> void:
	print("[%s] Teleporting to %s" % [being_name, target_position])
	
	# Show teleport effect
	_create_teleport_effect(position)
	
	# Teleport with delay
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, teleport_speed * 0.5)
	tween.tween_callback(func(): position = target_position)
	tween.tween_callback(func(): _create_teleport_effect(target_position))
	tween.tween_property(self, "modulate:a", 1.0, teleport_speed * 0.5)
	tween.tween_callback(_complete_task)
	
	teleported.emit(position, target_position)
	magic_used.emit("teleport")

func _task_collect_objects(radius: float) -> void:
	print("[%s] Collecting objects within radius %f" % [being_name, radius])
	
	# Find all physics objects nearby
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = SphereShape3D.new()
	query.shape.radius = radius
	query.transform.origin = position
	
	var results = space_state.intersect_shape(query)
	var collected_count = 0
	
	for result in results:
		var body = result.collider
		if body is RigidBody3D and body.name != "Ground":
			# Levitate object
			_levitate_object(body)
			collected_count += 1
	
	print("[%s] Collected %d objects" % [being_name, collected_count])
	
	# Wait a bit then complete
	await get_tree().create_timer(2.0).timeout
	_complete_task()

func _task_organize_area(center: Vector3) -> void:
	print("[%s] Organizing area around %s" % [being_name, center])
	
	# Create magical organization effect
	_create_magic_circle(center)
	
	# Find and arrange objects
	var objects = _find_nearby_objects(center, 10.0)
	var angle_step = TAU / max(objects.size(), 1)
	var radius = 3.0
	
	for i in range(objects.size()):
		var obj = objects[i]
		var angle = i * angle_step
		var target_pos = center + Vector3(cos(angle) * radius, 1.0, sin(angle) * radius)
		
		# Magically move object
		_levitate_object_to(obj, target_pos)
	
	magic_used.emit("organize")
	
	await get_tree().create_timer(3.0).timeout
	_complete_task()

func _task_create_light(light_position: Vector3) -> void:
	print("[%s] Creating magical light at %s" % [being_name, light_position])
	
	# Move to position first
	await _teleport_to(light_position + Vector3(0, 2, 0))
	
	# Create light orb
	var light_orb = OmniLight3D.new()
	light_orb.light_color = Color(1, 0.9, 0.7)
	light_orb.light_energy = 3.0
	light_orb.omni_range = 15.0
	light_orb.position = light_position
	FloodgateController.universal_add_child(light_orb, get_tree().current_scene)
	
	# Add glow mesh
	var orb_mesh = MeshInstance3D.new()
	orb_mesh.mesh = SphereMesh.new()
	orb_mesh.mesh.radius = 0.3
	orb_mesh.mesh.height = 0.6
	FloodgateController.universal_add_child(orb_mesh, light_orb)
	
	var orb_mat = MaterialLibrary.get_material("default")
	orb_mat.emission_enabled = true
	orb_mat.emission = Color(1, 0.9, 0.7)
	orb_mat.emission_energy = 5.0
	orb_mesh.material_override = orb_mat
	
	magic_used.emit("create_light")
	_complete_task()

func _task_help_ragdoll() -> void:
	print("[%s] Helping ragdoll" % being_name)
	
	# Find ragdoll
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if ragdolls.is_empty():
		print("[%s] No ragdoll found to help" % being_name)
		_complete_task()
		return
	
	var ragdoll = ragdolls[0]
	
	# Teleport near ragdoll
	await _teleport_to(ragdoll.global_position + Vector3(2, 2, 0))
	
	# Heal/boost ragdoll
	_create_healing_effect(ragdoll.global_position)
	
	# Give ragdoll a boost
	if ragdoll.has_method("set_health"):
		ragdoll.set_health(100)
	
	magic_used.emit("heal")
	_complete_task()

func _task_clean_scene() -> void:
	print("[%s] Cleaning scene" % being_name)
	
	# Find all small objects
	var to_remove = []
	for node in get_tree().current_scene.get_children():
		if node is RigidBody3D and node.name.contains("debris"):
			to_remove.append(node)
	
	# Magically vanish them
	for obj in to_remove:
		_vanish_object(obj)
		await get_tree().create_timer(0.2).timeout
	
	print("[%s] Cleaned %d objects" % [being_name, to_remove.size()])
	magic_used.emit("clean")
	_complete_task()

func _task_patrol(points: Array) -> void:
	if points.is_empty():
		# Create default patrol points
		points = [
			position + Vector3(5, 0, 0),
			position + Vector3(0, 0, 5),
			position + Vector3(-5, 0, 0),
			position + Vector3(0, 0, -5)
		]
	
	print("[%s] Starting patrol with %d points" % [being_name, points.size()])
	
	# This task continues indefinitely
	_patrol_loop(points)

func _patrol_loop(points: Array) -> void:
	for point in points:
		await _teleport_to(point)
		await get_tree().create_timer(2.0).timeout
		
		# Check for things to do at this point
		var nearby_objects = _find_nearby_objects(point, 3.0)
		if nearby_objects.size() > 3:
			# Too messy, organize
			_task_organize_area(point)
			await get_tree().create_timer(3.0).timeout
	
	# Continue patrol
	if current_task.type == "patrol":
		_patrol_loop(points)

# ================================
# MAGICAL EFFECTS
# ================================

func _create_teleport_effect(pos: Vector3) -> void:
	# Create expanding ring
	var ring = MeshInstance3D.new()
	ring.mesh = TorusMesh.new()
	ring.mesh.inner_radius = 0.3
	ring.mesh.outer_radius = 0.5
	ring.position = pos
	FloodgateController.universal_add_child(ring, get_tree().current_scene)
	
	var ring_mat = MaterialLibrary.get_material("default")
	ring_mat.albedo_color = color
	ring_mat.emission_enabled = true
	ring_mat.emission = color
	ring_mat.emission_energy = 3.0
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.material_override = ring_mat
	
	# Animate
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector3.ONE * 3, 0.5)
	tween.tween_property(ring_mat, "albedo_color:a", 0.0, 0.5)
	tween.chain().tween_callback(ring.queue_free)

func _create_magic_circle(center: Vector3) -> void:
	# Create glowing circle on ground
	var circle = MeshInstance3D.new()
	circle.mesh = TorusMesh.new()
	circle.mesh.inner_radius = 2.8
	circle.mesh.outer_radius = 3.0
	circle.position = center
	circle.rotation.x = PI/2
	FloodgateController.universal_add_child(circle, get_tree().current_scene)
	
	var circle_mat = MaterialLibrary.get_material("default")
	circle_mat.albedo_color = Color(0.5, 0.8, 1.0)
	circle_mat.emission_enabled = true
	circle_mat.emission = Color(0.5, 0.8, 1.0)
	circle_mat.emission_energy = 2.0
	circle.material_override = circle_mat
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(circle_mat, "emission_energy", 0.0, 3.0)
	tween.tween_callback(circle.queue_free)

func _create_healing_effect(pos: Vector3) -> void:
	# Create healing particles
	var heal_particles = GPUParticles3D.new()
	heal_particles.amount = 100
	heal_particles.lifetime = 1.5
	heal_particles.position = pos
	heal_particles.emitting = true
	heal_particles.one_shot = true
	
	var heal_process = ParticleProcessMaterial.new()
	heal_process.initial_velocity_min = 1.0
	heal_process.initial_velocity_max = 2.0
	heal_process.direction = Vector3(0, 1, 0)
	heal_process.spread = 30.0
	heal_process.gravity = Vector3.ZERO
	heal_process.scale_min = 0.1
	heal_process.scale_max = 0.2
	
	heal_particles.process_material = heal_process
	heal_particles.draw_pass_1 = SphereMesh.new()
	heal_particles.draw_pass_1.radius = 0.05
	
	var heal_mat = MaterialLibrary.get_material("default")
	heal_mat.albedo_color = Color(0.5, 1.0, 0.5)
	heal_mat.emission_enabled = true
	heal_mat.emission = Color(0.5, 1.0, 0.5)
	heal_mat.emission_energy = 3.0
	heal_particles.material_override = heal_mat
	
	FloodgateController.universal_add_child(heal_particles, get_tree().current_scene)
	
	# Clean up after effect
	await get_tree().create_timer(2.0).timeout
	heal_particles.queue_free()

# ================================
# HELPER FUNCTIONS
# ================================

func _levitate_object(body: RigidBody3D) -> void:
	if not body:
		return
	
	# Disable gravity temporarily
	body.gravity_scale = 0.0
	
	# Float up
	var tween = create_tween()
	tween.tween_property(body, "position:y", body.position.y + 2.0, 1.0)
	tween.tween_callback(func(): body.gravity_scale = 1.0)

func _levitate_object_to(body: RigidBody3D, target_pos: Vector3) -> void:
	if not body:
		return
	
	body.freeze = true
	
	var tween = create_tween()
	tween.tween_property(body, "position", target_pos, 1.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): body.freeze = false)

func _vanish_object(obj: Node) -> void:
	if not obj:
		return
	
	# Shrink and fade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(obj, "scale", Vector3.ZERO, 0.5)
	if obj.has_method("set_modulate"):
		tween.tween_property(obj, "modulate:a", 0.0, 0.5)
	tween.chain().tween_callback(obj.queue_free)

func _find_nearby_objects(center: Vector3, radius: float) -> Array:
	var objects = []
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = SphereShape3D.new()
	query.shape.radius = radius
	query.transform.origin = center
	
	var results = space_state.intersect_shape(query)
	for result in results:
		if result.collider is RigidBody3D:
			objects.append(result.collider)
	
	return objects

func _teleport_to(pos: Vector3) -> void:
	_create_teleport_effect(position)
	await get_tree().create_timer(teleport_speed * 0.5).timeout
	position = pos
	_create_teleport_effect(position)
	await get_tree().create_timer(teleport_speed * 0.5).timeout

func _complete_task() -> void:
	print("[%s] Task completed: %s" % [being_name, current_task.type])
	task_completed.emit(current_task.type)
	current_task = {}
	is_busy = false

# ================================
# PUBLIC API
# ================================

func set_color(new_color: Color) -> void:
	color = new_color
	if mesh_instance and mesh_instance.material_override:
		mesh_instance.material_override.albedo_color = color
		mesh_instance.material_override.emission = color
	if glow_light:
		glow_light.light_color = color

func set_being_name(new_name: String) -> void:
	being_name = new_name
	name = new_name