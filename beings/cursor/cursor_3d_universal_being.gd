# 3D CURSOR UNIVERSAL BEING - PLASMOID ENERGY CROSSHAIR SYSTEM
# Sacred rule: True 3D cursor with consciousness and plasmoid energy
extends UniversalBeing
class_name Cursor3DUniversalBeing

signal cursor_moved(new_position: Vector3)
signal target_acquired(target_node: Node3D)
signal target_lost()
signal cursor_mode_changed(new_mode: String)

# Cursor states
enum CursorMode {
	NORMAL,
	TARGETING,
	PLASMOID_ENERGY,
	TEXT_SELECTION,
	COSMIC_NAVIGATION
}

var current_mode: CursorMode = CursorMode.NORMAL
var cursor_position: Vector3 = Vector3.ZERO
var target_object: Node3D = null
var is_visible: bool = true

# 3D Cursor components
var cursor_core: MeshInstance3D = null
var crosshair_rings: Array = []
var energy_particles: GPUParticles3D = null
var targeting_beam: MeshInstance3D = null
var distance_indicator: Label3D = null

# Visual styling
var cursor_colors = {
	CursorMode.NORMAL: Color.CYAN,
	CursorMode.TARGETING: Color.RED,
	CursorMode.PLASMOID_ENERGY: Color.MAGENTA,
	CursorMode.TEXT_SELECTION: Color.YELLOW,
	CursorMode.COSMIC_NAVIGATION: Color.WHITE
}

# Cursor configuration
var cursor_size: float = 0.5
var ring_count: int = 3
var pulse_speed: float = 2.0
var energy_intensity: float = 1.0
var max_targeting_distance: float = 100.0

# Pentagon lifecycle
func pentagon_init():
	super.pentagon_init()
	being_type = "cursor_3d"
	being_name = "3D Cursor Universal Being"
	consciousness_level = 2
	print("🎯 3D Cursor: Initializing plasmoid crosshair system...")

func pentagon_ready():
	super.pentagon_ready()
	create_3d_cursor_system()
	set_cursor_mode(CursorMode.NORMAL)
	print("✨ 3D Cursor: Plasmoid energy cursor ready!")

func pentagon_process(delta: float):
	super.pentagon_process(delta)
	update_cursor_animation(delta)
	update_targeting_system(delta)
	update_plasmoid_energy(delta)

func pentagon_input(event: InputEvent):
	super.pentagon_input(event)
	handle_cursor_input(event)

func pentagon_sewers():
	hide_cursor()
	super.pentagon_sewers()

func create_3d_cursor_system():
	"""Create the complete 3D cursor system"""
	print("🌌 Creating 3D plasmoid cursor system...")
	
	# Create cursor core
	create_cursor_core()
	
	# Create crosshair rings
	create_crosshair_rings()
	
	# Create plasmoid energy particles
	create_energy_particles()
	
	# Create targeting beam
	create_targeting_beam()
	
	# Create distance indicator
	create_distance_indicator()
	
	print("🎯 3D Cursor system created successfully")

func create_cursor_core():
	"""Create the central cursor core"""
	cursor_core = MeshInstance3D.new()
	cursor_core.name = "CursorCore"
	
	var sphere = SphereMesh.new()
	sphere.radius = cursor_size * 0.3
	sphere.height = cursor_size * 0.6
	cursor_core.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = cursor_colors[CursorMode.NORMAL]
	material.emission_enabled = true
	material.emission = cursor_colors[CursorMode.NORMAL] * 2.0
	material.emission_energy = 1.5
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.8
	cursor_core.material_override = material
	
	add_child(cursor_core)

func create_crosshair_rings():
	"""Create rotating crosshair rings"""
	crosshair_rings.clear()
	
	for i in range(ring_count):
		var ring = MeshInstance3D.new()
		ring.name = "CrosshairRing_" + str(i)
		
		var torus = TorusMesh.new()
		torus.inner_radius = cursor_size + i * 0.5
		torus.outer_radius = torus.inner_radius + 0.1
		ring.mesh = torus
		
		var ring_material = StandardMaterial3D.new()
		ring_material.albedo_color = cursor_colors[CursorMode.NORMAL] * (1.0 - i * 0.2)
		ring_material.emission_enabled = true
		ring_material.emission = ring_material.albedo_color * 1.5
		ring_material.emission_energy = 0.8
		ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring_material.albedo_color.a = 0.6 - i * 0.1
		ring.material_override = ring_material
		
		add_child(ring)
		crosshair_rings.append(ring)

func create_energy_particles():
	"""Create plasmoid energy particle system"""
	energy_particles = GPUParticles3D.new()
	energy_particles.name = "CursorEnergyParticles"
	energy_particles.amount = 50
	energy_particles.lifetime = 2.0
	energy_particles.emitting = true
	
	var particle_mat = ParticleProcessMaterial.new()
	particle_mat.direction = Vector3(0, 0, 0)
	particle_mat.initial_velocity_min = 0.5
	particle_mat.initial_velocity_max = 2.0
	particle_mat.gravity = Vector3.ZERO
	particle_mat.scale_min = 0.05
	particle_mat.scale_max = 0.15
	particle_mat.color = cursor_colors[CursorMode.NORMAL]
	energy_particles.process_material = particle_mat
	
	add_child(energy_particles)

func create_targeting_beam():
	"""Create targeting beam for object selection"""
	targeting_beam = MeshInstance3D.new()
	targeting_beam.name = "TargetingBeam"
	targeting_beam.visible = false
	
	var cylinder = CylinderMesh.new()
	cylinder.height = 1.0
	cylinder.top_radius = 0.02
	cylinder.bottom_radius = 0.05
	targeting_beam.mesh = cylinder
	
	var beam_material = StandardMaterial3D.new()
	beam_material.albedo_color = Color(1, 0, 0, 0.6)
	beam_material.emission_enabled = true
	beam_material.emission = Color.RED * 3.0
	beam_material.emission_energy = 1.0
	beam_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_material.flags_unshaded = true
	targeting_beam.material_override = beam_material
	
	add_child(targeting_beam)

func create_distance_indicator():
	"""Create distance indicator label"""
	distance_indicator = Label3D.new()
	distance_indicator.name = "DistanceIndicator"
	distance_indicator.text = ""
	distance_indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	distance_indicator.position = Vector3(0, 2, 0)
	distance_indicator.modulate = Color.WHITE
	distance_indicator.pixel_size = 0.01
	distance_indicator.visible = false
	
	add_child(distance_indicator)

var animation_time: float = 0.0

func update_cursor_animation(delta: float):
	"""Update cursor animation and pulsing effects"""
	animation_time += delta * pulse_speed
	
	# Animate cursor core pulsing
	if cursor_core:
		var pulse_scale = 1.0 + sin(animation_time * 2.0) * 0.2
		cursor_core.scale = Vector3.ONE * pulse_scale
	
	# Rotate crosshair rings
	for i in range(crosshair_rings.size()):
		var ring = crosshair_rings[i]
		var rotation_speed = 1.0 + i * 0.5
		ring.rotation += Vector3(
			delta * rotation_speed,
			delta * rotation_speed * 1.5,
			delta * rotation_speed * 0.7
		)
	
	# Update energy particle intensity
	if energy_particles and energy_particles.process_material:
		var particle_mat = energy_particles.process_material as ParticleProcessMaterial
		var intensity = energy_intensity * (1.0 + sin(animation_time * 3.0) * 0.3)
		particle_mat.initial_velocity_max = 2.0 * intensity

func update_targeting_system(delta: float):
	"""Update targeting system and object detection with scale-aware raycasting"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var forward = -camera.global_transform.basis.z
	
	# Calculate scale-aware max distance
	var world_scale = _estimate_world_scale()
	var player_scale = _estimate_player_scale(camera)
	var adaptive_max_distance = _calculate_adaptive_distance(world_scale, player_scale)
	
	# Perform raycast
	var to = from + (forward * adaptive_max_distance)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_position = result.get("position")
		var target = result.get("collider")
		var hit_distance = from.distance_to(hit_position)
		
		# Adjust cursor position based on hit
		var cursor_distance = min(hit_distance - 1.0, adaptive_max_distance * 0.5)
		cursor_distance = max(cursor_distance, 2.0)  # Minimum distance from player
		
		cursor_position = from + (forward * cursor_distance)
		global_position = cursor_position
		
		# Set target if in targeting mode
		if (current_mode == CursorMode.TARGETING or current_mode == CursorMode.PLASMOID_ENERGY):
			if target and target != target_object:
				set_target_object(target as Node3D, hit_position)
	else:
		# No hit - place cursor at comfortable distance
		var comfortable_distance = min(adaptive_max_distance * 0.3, 15.0)
		cursor_position = from + (forward * comfortable_distance)
		global_position = cursor_position
		
		if target_object:
			clear_target_object()
	
	cursor_moved.emit(cursor_position)

func update_plasmoid_energy(delta: float):
	"""Update plasmoid energy effects"""
	if current_mode == CursorMode.PLASMOID_ENERGY:
		# Intensify energy effects
		energy_intensity = 2.0
		
		# Create energy trails
		if energy_particles:
			energy_particles.amount = 100
			
		# Enhanced core glow
		if cursor_core and cursor_core.material_override:
			var material = cursor_core.material_override as StandardMaterial3D
			material.emission_energy = 2.0 + sin(animation_time * 4.0) * 0.5
	else:
		energy_intensity = 1.0
		if energy_particles:
			energy_particles.amount = 50

func handle_cursor_input(event: InputEvent):
	"""Handle cursor-specific input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_C:
				cycle_cursor_mode()
			KEY_T:
				set_cursor_mode(CursorMode.TARGETING)
			KEY_P:
				set_cursor_mode(CursorMode.PLASMOID_ENERGY)
			KEY_N:
				set_cursor_mode(CursorMode.NORMAL)
			KEY_H:
				toggle_cursor_visibility()
	
	if event is InputEventMouseMotion:
		update_cursor_position_from_camera()

func cycle_cursor_mode():
	"""Cycle through cursor modes"""
	var modes = [
		CursorMode.NORMAL,
		CursorMode.TARGETING,
		CursorMode.PLASMOID_ENERGY,
		CursorMode.TEXT_SELECTION,
		CursorMode.COSMIC_NAVIGATION
	]
	
	var current_index = modes.find(current_mode)
	var next_index = (current_index + 1) % modes.size()
	set_cursor_mode(modes[next_index])

func set_cursor_mode(new_mode: CursorMode):
	"""Set cursor mode and update visual appearance"""
	current_mode = new_mode
	var mode_color = cursor_colors[new_mode]
	
	# Update cursor core color
	if cursor_core and cursor_core.material_override:
		var material = cursor_core.material_override as StandardMaterial3D
		material.albedo_color = mode_color
		material.emission = mode_color * 2.0
	
	# Update rings color
	for i in range(crosshair_rings.size()):
		var ring = crosshair_rings[i]
		if ring.material_override:
			var ring_material = ring.material_override as StandardMaterial3D
			ring_material.albedo_color = mode_color * (1.0 - i * 0.2)
			ring_material.emission = ring_material.albedo_color * 1.5
	
	# Update particles color
	if energy_particles and energy_particles.process_material:
		var particle_mat = energy_particles.process_material as ParticleProcessMaterial
		particle_mat.color = mode_color
	
	# Show/hide targeting beam
	if targeting_beam:
		targeting_beam.visible = (new_mode == CursorMode.TARGETING or new_mode == CursorMode.PLASMOID_ENERGY)
	
	cursor_mode_changed.emit(get_mode_name(new_mode))
	print("🎯 Cursor mode changed to: " + get_mode_name(new_mode))

func get_mode_name(mode: CursorMode) -> String:
	"""Get human-readable mode name"""
	match mode:
		CursorMode.NORMAL:
			return "Normal"
		CursorMode.TARGETING:
			return "Targeting"
		CursorMode.PLASMOID_ENERGY:
			return "Plasmoid Energy"
		CursorMode.TEXT_SELECTION:
			return "Text Selection"
		CursorMode.COSMIC_NAVIGATION:
			return "Cosmic Navigation"
		_:
			return "Unknown"

func set_target_object(target: Node3D, hit_position: Vector3):
	"""Set target object and update targeting display"""
	target_object = target
	
	# Update targeting beam
	if targeting_beam and target_object:
		targeting_beam.visible = true
		var distance = global_position.distance_to(hit_position)
		targeting_beam.scale = Vector3(1, distance, 1)
		targeting_beam.look_at(hit_position, Vector3.UP)
		targeting_beam.position = global_position + (hit_position - global_position) * 0.5
	
	# Update distance indicator
	if distance_indicator:
		distance_indicator.visible = true
		var distance = global_position.distance_to(hit_position)
		distance_indicator.text = "🎯 TARGET: " + target.name + "\nDistance: %.1f" % distance
	
	target_acquired.emit(target)

func clear_target_object():
	"""Clear current target object"""
	target_object = null
	
	if targeting_beam:
		targeting_beam.visible = false
	
	if distance_indicator:
		distance_indicator.visible = false
	
	target_lost.emit()

func update_cursor_position_from_camera():
	"""Update cursor position based on camera direction"""
	var camera = get_viewport().get_camera_3d()
	if camera:
		var from = camera.global_position
		var forward = -camera.global_transform.basis.z
		cursor_position = from + forward * 10.0  # 10 units in front of camera
		global_position = cursor_position
		cursor_moved.emit(cursor_position)

func show_cursor():
	"""Show the cursor"""
	is_visible = true
	visible = true
	print("🎯 3D Cursor: Visible")

func hide_cursor():
	"""Hide the cursor"""
	is_visible = false
	visible = false
	print("👻 3D Cursor: Hidden")

func toggle_cursor_visibility():
	"""Toggle cursor visibility"""
	if is_visible:
		hide_cursor()
	else:
		show_cursor()

func set_cursor_position(new_position: Vector3):
	"""Set cursor position manually"""
	cursor_position = new_position
	global_position = new_position
	cursor_moved.emit(cursor_position)

func get_cursor_position() -> Vector3:
	"""Get current cursor position"""
	return cursor_position

func get_target_object() -> Node3D:
	"""Get currently targeted object"""
	return target_object

func is_targeting() -> bool:
	"""Check if cursor is in targeting mode"""
	return current_mode == CursorMode.TARGETING or current_mode == CursorMode.PLASMOID_ENERGY

# Public interface
func enable_plasmoid_mode():
	"""Public interface to enable plasmoid energy mode"""
	set_cursor_mode(CursorMode.PLASMOID_ENERGY)

func enable_targeting_mode():
	"""Public interface to enable targeting mode"""
	set_cursor_mode(CursorMode.TARGETING)

func enable_normal_mode():
	"""Public interface to enable normal mode"""
	set_cursor_mode(CursorMode.NORMAL)

func _estimate_world_scale() -> float:
	"""Estimate the scale of the world for adaptive cursor distance"""
	# Look for largest objects in scene to estimate world scale
	var max_distance = 50.0  # Default
	var scene_root = get_tree().current_scene
	
	if scene_root:
		var bounds = _get_scene_bounds(scene_root)
		max_distance = bounds.size().length() * 0.1
	
	return clamp(max_distance, 10.0, 500.0)

func _estimate_player_scale(camera: Camera3D) -> float:
	"""Estimate player scale based on camera height and movement speed"""
	var camera_height = camera.global_position.y
	var estimated_scale = max(abs(camera_height) * 0.1, 1.0)
	return clamp(estimated_scale, 0.5, 10.0)

func _calculate_adaptive_distance(world_scale: float, player_scale: float) -> float:
	"""Calculate adaptive max cursor distance"""
	var base_distance = world_scale * 0.2
	var player_adjusted = base_distance * player_scale
	return clamp(player_adjusted, 5.0, 200.0)

func _get_scene_bounds(node: Node) -> AABB:
	"""Get bounding box of scene"""
	var bounds = AABB()
	var first = true
	
	_collect_bounds(node, bounds, first)
	
	if first:  # No bounds found, return default
		bounds = AABB(Vector3(-50, -50, -50), Vector3(100, 100, 100))
	
	return bounds

func _collect_bounds(node: Node, bounds: AABB, first: bool):
	"""Recursively collect bounds from scene nodes"""
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		if mesh_instance.mesh:
			var mesh_bounds = mesh_instance.get_aabb()
			mesh_bounds = mesh_instance.global_transform * mesh_bounds
			
			if first:
				bounds = mesh_bounds
				first = false
			else:
				bounds = bounds.merge(mesh_bounds)
	
	for child in node.get_children():
		_collect_bounds(child, bounds, first)

func get_cursor_info() -> Dictionary:
	"""Get comprehensive cursor information"""
	return {
		"mode": get_mode_name(current_mode),
		"position": cursor_position,
		"target": target_object.name if target_object else null,
		"visible": is_visible,
		"energy_intensity": energy_intensity,
		"adaptive_distance": _calculate_adaptive_distance(_estimate_world_scale(), 1.0)
	}