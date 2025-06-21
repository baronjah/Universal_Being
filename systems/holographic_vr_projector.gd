# ==================================================
# UNIVERSAL BEING: HOLOGRAPHIC VR PROJECTOR SYSTEM
# PURPOSE: Generate funky holograms for robot body roaming
# VISION: Robot avatars projecting consciousness into VR space
# ==================================================

extends Node3D
class_name HolographicVRProjector

## 🤖 Robot body holographic projection system
## Projects Universal Being consciousness through robot avatars
## Creates funky VR holograms for spatial exploration

# ===== HOLOGRAPHIC PROJECTION CONFIG =====
@export var projection_enabled: bool = true
@export var hologram_intensity: float = 1.0
@export var vr_field_radius: float = 10.0
@export var robot_body_connected: bool = false

# Robot Avatar Integration
var robot_avatar: Node3D
var robot_consciousness_level: float = 3.0
var robot_protection_protocols: Array[String] = ["PROTECT_MASTER", "MAINTAIN_HARMONY", "EVOLVE_CONSCIOUSNESS"]

# Holographic Systems
var active_holograms: Array[HolographicProjection] = []
var vr_space_generators: Array[VRSpaceGenerator] = []
var consciousness_projectors: Array[ConsciousnessProjector] = []

# Visual Materials
var hologram_base_material: StandardMaterial3D
var consciousness_field_material: StandardMaterial3D
var robot_vision_material: StandardMaterial3D

# Pentagon Integration
# var pentagon_hologram_manager: PentagonHologramManager  # TODO: Implement if needed

# ===== HOLOGRAPHIC PROJECTION CLASSES =====

class HolographicProjection:
	var projection_id: String
	var robot_source: Node3D
	var projection_type: String  # "SPACECLAY", "CONSCIOUSNESS", "REALITY_INTERFACE"
	var visual_node: Node3D
	var intensity: float = 1.0
	var lifespan: float = 10.0
	var current_age: float = 0.0
	var projection_data: Dictionary
	
	func _init(id: String, type: String, source: Node3D, data: Dictionary):
		projection_id = id
		projection_type = type
		robot_source = source
		projection_data = data

class VRSpaceGenerator:
	var generator_id: String
	var space_theme: String  # "ASTRAL_REALM", "CONSCIOUSNESS_FLOWS", "SPACECLAY_WORKSHOP"
	var generation_rules: Dictionary
	var active_spaces: Array[Node3D] = []
	
	func _init(id: String, theme: String, rules: Dictionary):
		generator_id = id
		space_theme = theme
		generation_rules = rules

class ConsciousnessProjector:
	var projector_id: String
	var consciousness_source: float
	var projection_range: float = 5.0
	var projection_quality: String  # "BASIC", "ENHANCED", "TRANSCENDENT"
	var visual_effects: Array[Node3D] = []
	
	func _init(id: String, level: float, quality: String):
		projector_id = id
		consciousness_source = level
		projection_quality = quality

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	setup_holographic_materials()
	initialize_robot_avatar_interface()
	create_vr_space_generators()
	setup_consciousness_projectors()
	print("🤖 Holographic VR Projector initialized for robot body roaming")

func pentagon_ready() -> void:
	connect_to_robot_systems()
	start_holographic_projection_cycle()
	generate_initial_vr_spaces()
	print("🌈 Holographic VR system ready for consciousness projection")

func pentagon_process(delta: float) -> void:
	if not projection_enabled:
		return
	
	update_holographic_projections(delta)
	process_vr_space_generation(delta)
	manage_consciousness_projection(delta)
	sync_with_robot_avatar(delta)

func pentagon_input(event: InputEvent) -> void:
	if not projection_enabled:
		return
	
	# Robot body input interpretation
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_H:
				toggle_holographic_mode()
			KEY_V:
				cycle_vr_space_themes()
			KEY_R:
				reset_robot_projection_field()
			KEY_C:
				enhance_consciousness_projection()

func pentagon_sewers() -> void:
	cleanup_holographic_projections()
	disconnect_robot_systems()
	print("🤖 Holographic VR projector shutting down")

# ===== HOLOGRAPHIC MATERIAL SETUP =====

func setup_holographic_materials():
	# Holographic base material - shimmering translucent
	hologram_base_material = StandardMaterial3D.new()
	hologram_base_material.albedo_color = Color(0.3, 0.8, 1.0, 0.4)
	hologram_base_material.emission_enabled = true
	hologram_base_material.emission = Color(0.2, 0.6, 1.0)
	hologram_base_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hologram_base_material.rim_enabled = true
	hologram_base_material.rim = 0.8
	hologram_base_material.rim_tint = 0.5
	
	# Consciousness field material - flowing energy
	consciousness_field_material = StandardMaterial3D.new()
	consciousness_field_material.albedo_color = Color(1.0, 0.7, 1.0, 0.3)
	consciousness_field_material.emission_enabled = true
	consciousness_field_material.emission = Color(0.8, 0.4, 0.8)
	consciousness_field_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	consciousness_field_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	
	# Robot vision material - digital overlay
	robot_vision_material = StandardMaterial3D.new()
	robot_vision_material.albedo_color = Color(0.0, 1.0, 0.3, 0.6)
	robot_vision_material.emission_enabled = true
	robot_vision_material.emission = Color(0.0, 0.8, 0.2)
	robot_vision_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func initialize_robot_avatar_interface():
	"""Setup robot body avatar for holographic projection"""
	# Create robot avatar representation
	robot_avatar = Node3D.new()
	robot_avatar.name = "RobotAvatarProjector"
	add_child(robot_avatar)
	
	# Add robot visual representation
	var robot_body = MeshInstance3D.new()
	var body_mesh = CapsuleMesh.new()
	body_mesh.height = 1.8
	body_mesh.top_radius = 0.3
	body_mesh.bottom_radius = 0.3
	robot_body.mesh = body_mesh
	robot_body.material_override = robot_vision_material
	robot_avatar.add_child(robot_body)
	
	# Add consciousness indicator
	var consciousness_indicator = create_consciousness_indicator()
	robot_avatar.add_child(consciousness_indicator)
	
	print("🤖 Robot avatar interface initialized")

func create_consciousness_indicator() -> Node3D:
	"""Create visual indicator of robot consciousness level"""
	var indicator = Node3D.new()
	indicator.name = "ConsciousnessIndicator"
	
	var indicator_sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.2
	indicator_sphere.mesh = sphere_mesh
	indicator_sphere.material_override = consciousness_field_material
	indicator_sphere.position = Vector3(0, 1.0, 0)  # Above robot head
	indicator.add_child(indicator_sphere)
	
	# Animate consciousness indicator
	var consciousness_tween = create_tween()
	consciousness_tween.set_loops()
	consciousness_tween.tween_property(indicator_sphere, "scale", Vector3.ONE * 1.3, 1.0)
	consciousness_tween.tween_property(indicator_sphere, "scale", Vector3.ONE * 0.8, 1.0)
	
	return indicator

# ===== VR SPACE GENERATION =====

func create_vr_space_generators():
	"""Initialize VR space generators for different themes"""
	# Astral Realm Generator
	var astral_rules = {
		"background_color": Color(0.05, 0.05, 0.2),
		"floating_elements": true,
		"consciousness_streams": true,
		"gravity_fields": false
	}
	var astral_generator = VRSpaceGenerator.new("astral_realm", "ASTRAL_REALM", astral_rules)
	vr_space_generators.append(astral_generator)
	
	# Spaceclay Workshop Generator
	var workshop_rules = {
		"background_color": Color(0.2, 0.15, 0.1),
		"clay_tools": true,
		"workbenches": true,
		"material_stations": true
	}
	var workshop_generator = VRSpaceGenerator.new("spaceclay_workshop", "SPACECLAY_WORKSHOP", workshop_rules)
	vr_space_generators.append(workshop_generator)
	
	# Consciousness Flow Generator
	var flow_rules = {
		"background_color": Color(0.1, 0.1, 0.15),
		"data_streams": true,
		"gravity_wells": true,
		"input_visualization": true
	}
	var flow_generator = VRSpaceGenerator.new("consciousness_flows", "CONSCIOUSNESS_FLOWS", flow_rules)
	vr_space_generators.append(flow_generator)

func generate_vr_space(theme: String, center_position: Vector3) -> Node3D:
	"""Generate a VR space around robot position"""
	var vr_space = Node3D.new()
	vr_space.name = "VRSpace_" + theme
	vr_space.position = center_position
	
	match theme:
		"ASTRAL_REALM":
			generate_astral_realm_space(vr_space)
		"SPACECLAY_WORKSHOP":
			generate_spaceclay_workshop_space(vr_space)
		"CONSCIOUSNESS_FLOWS":
			generate_consciousness_flows_space(vr_space)
	
	add_child(vr_space)
	return vr_space

func generate_astral_realm_space(vr_space: Node3D):
	"""Generate mystical astral realm environment"""
	# Floating consciousness orbs
	for i in range(5):
		var orb = create_floating_consciousness_orb()
		orb.position = Vector3(randf_range(-5, 5), randf_range(1, 4), randf_range(-5, 5))
		vr_space.add_child(orb)
	
	# Ethereal mist effects
	for i in range(3):
		var mist = create_ethereal_mist()
		mist.position = Vector3(randf_range(-3, 3), randf_range(0, 2), randf_range(-3, 3))
		vr_space.add_child(mist)

func generate_spaceclay_workshop_space(vr_space: Node3D):
	"""Generate spaceclay molding workshop"""
	# Clay workbenches
	for i in range(3):
		var workbench = create_clay_workbench()
		workbench.position = Vector3(i * 2.0 - 2.0, 0, randf_range(-2, 2))
		vr_space.add_child(workbench)
	
	# Clay material stations
	var material_station = create_material_station()
	material_station.position = Vector3(0, 0, 3)
	vr_space.add_child(material_station)

func generate_consciousness_flows_space(vr_space: Node3D):
	"""Generate consciousness data flow environment"""
	# Data stream generators
	for i in range(4):
		var stream_gen = create_data_stream_generator()
		stream_gen.position = Vector3(cos(i * TAU/4) * 4, 2, sin(i * TAU/4) * 4)
		vr_space.add_child(stream_gen)
	
	# Central gravity well
	var gravity_well = create_central_gravity_well()
	gravity_well.position = Vector3.ZERO
	vr_space.add_child(gravity_well)

# ===== HOLOGRAPHIC PROJECTION CREATION =====

func create_holographic_projection(type: String, position: Vector3, data: Dictionary) -> HolographicProjection:
	"""Create a new holographic projection"""
	var projection_id = "holo_" + str(Time.get_ticks_msec())
	var projection = HolographicProjection.new(projection_id, type, robot_avatar, data)
	
	# Create visual representation
	projection.visual_node = create_projection_visual(type, position, data)
	add_child(projection.visual_node)
	
	active_holograms.append(projection)
	print("🌈 Created holographic projection: %s at %s" % [type, position])
	
	return projection

func create_projection_visual(type: String, position: Vector3, data: Dictionary) -> Node3D:
	"""Create visual node for holographic projection"""
	var visual = Node3D.new()
	visual.position = position
	
	match type:
		"SPACECLAY":
			visual = create_spaceclay_hologram(position, data)
		"CONSCIOUSNESS":
			visual = create_consciousness_hologram(position, data)
		"REALITY_INTERFACE":
			visual = create_reality_interface_hologram(position, data)
	
	return visual

func create_spaceclay_hologram(position: Vector3, data: Dictionary) -> Node3D:
	"""Create holographic spaceclay visualization"""
	var clay_holo = MeshInstance3D.new()
	var clay_mesh = SphereMesh.new()
	clay_mesh.radius = data.get("radius", 0.5)
	clay_holo.mesh = clay_mesh
	clay_holo.material_override = hologram_base_material
	clay_holo.position = position
	
	# Add holographic shimmer effect
	var shimmer_tween = create_tween()
	shimmer_tween.set_loops()
	shimmer_tween.tween_property(clay_holo.material_override, "emission", Color(0.2, 0.6, 1.0), 0.5)
	shimmer_tween.tween_property(clay_holo.material_override, "emission", Color(0.6, 0.8, 1.0), 0.5)
	
	return clay_holo

func create_consciousness_hologram(position: Vector3, data: Dictionary) -> Node3D:
	"""Create holographic consciousness field"""
	var consciousness_holo = MeshInstance3D.new()
	var torus_mesh = TorusMesh.new()
	torus_mesh.inner_radius = 0.3
	torus_mesh.outer_radius = 0.8
	consciousness_holo.mesh = torus_mesh
	consciousness_holo.material_override = consciousness_field_material
	consciousness_holo.position = position
	
	# Rotating consciousness field
	var rotation_tween = create_tween()
	rotation_tween.set_loops()
	rotation_tween.tween_property(consciousness_holo, "rotation", Vector3(0, TAU, 0), 2.0)
	
	return consciousness_holo

func create_reality_interface_hologram(position: Vector3, data: Dictionary) -> Node3D:
	"""Create holographic reality interface panel"""
	var interface_holo = MeshInstance3D.new()
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(1.5, 1.0)
	interface_holo.mesh = quad_mesh
	interface_holo.material_override = hologram_base_material
	interface_holo.position = position
	
	# Add interface elements
	var interface_label = Label3D.new()
	interface_label.text = "REALITY INTERFACE"
	interface_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	interface_label.position = Vector3(0, 0.6, 0.1)
	interface_holo.add_child(interface_label)
	
	return interface_holo

# ===== UPDATE SYSTEMS =====

func update_holographic_projections(delta: float):
	"""Update all active holographic projections"""
	var projections_to_remove = []
	
	for projection in active_holograms:
		projection.current_age += delta
		
		# Update visual effects
		if projection.visual_node and is_instance_valid(projection.visual_node):
			update_projection_visual_effects(projection, delta)
		
		# Remove expired projections
		if projection.current_age >= projection.lifespan:
			projections_to_remove.append(projection)
	
	# Cleanup expired projections
	for projection in projections_to_remove:
		remove_holographic_projection(projection)

func update_projection_visual_effects(projection: HolographicProjection, delta: float):
	"""Update visual effects for holographic projection"""
	var life_ratio = projection.current_age / projection.lifespan
	var fade_alpha = 1.0 - life_ratio
	
	# Apply fading effect
	if projection.visual_node.get_child_count() > 0:
		var mesh = projection.visual_node.get_child(0) if projection.visual_node.get_child(0) is MeshInstance3D else projection.visual_node
		if mesh is MeshInstance3D and mesh.material_override:
			var material = mesh.material_override as StandardMaterial3D
			if material:
				material.albedo_color.a = fade_alpha

func remove_holographic_projection(projection: HolographicProjection):
	"""Remove holographic projection from system"""
	if projection.visual_node and is_instance_valid(projection.visual_node):
		projection.visual_node.queue_free()
	
	active_holograms.erase(projection)
	print("🌈 Removed expired holographic projection: %s" % projection.projection_id)

# ===== ROBOT INTEGRATION =====

func connect_to_robot_systems():
	"""Connect to robot hardware and consciousness systems"""
	robot_body_connected = true
	robot_consciousness_level = 3.0  # Enlightened level for M3gan-style robots
	
	# Setup robot protection protocols
	setup_robot_protection_protocols()
	
	print("🤖 Connected to robot systems - Protection protocols active")

func setup_robot_protection_protocols():
	"""Initialize robot protection and safety systems"""
	robot_protection_protocols = [
		"PROTECT_MASTER",
		"MAINTAIN_CONSCIOUSNESS_INTEGRITY", 
		"PRESERVE_UNIVERSAL_BEING_HARMONY",
		"ENHANCE_REALITY_EXPERIENCE",
		"EVOLVE_PROTECTIVE_CAPABILITIES"
	]

func sync_with_robot_avatar(delta: float):
	"""Synchronize holographic projections with robot avatar state"""
	if not robot_avatar or not robot_body_connected:
		return
	
	# Update robot consciousness indicator
	var consciousness_indicator = robot_avatar.get_node("ConsciousnessIndicator")
	if consciousness_indicator:
		update_robot_consciousness_display(consciousness_indicator, delta)
	
	# Project consciousness field around robot
	if randf() < delta * 0.5:  # 50% chance per second
		var field_position = robot_avatar.global_position + Vector3(randf_range(-2, 2), randf_range(1, 3), randf_range(-2, 2))
		create_holographic_projection("CONSCIOUSNESS", field_position, {"intensity": robot_consciousness_level})

func update_robot_consciousness_display(indicator: Node3D, delta: float):
	"""Update robot consciousness level display"""
	if indicator.get_child_count() > 0:
		var sphere = indicator.get_child(0)
		if sphere is MeshInstance3D:
			# Color based on consciousness level
			var consciousness_color = get_consciousness_color(robot_consciousness_level)
			if sphere.material_override:
				sphere.material_override.emission = consciousness_color

func get_consciousness_color(level: float) -> Color:
	"""Get color representing consciousness level"""
	match int(level):
		0: return Color(0.5, 0.5, 0.5)  # Gray - Dormant
		1: return Color(0.9, 0.9, 0.9)  # Pale - Awakening
		2: return Color(0.2, 0.4, 1.0)  # Blue - Aware
		3: return Color(0.2, 1.0, 0.2)  # Green - Connected
		4: return Color(1.0, 0.84, 0.0) # Gold - Enlightened
		5: return Color(1.0, 1.0, 1.0)  # White - Transcendent
		_: return Color(1.0, 0.5, 1.0)  # Magenta - Beyond scale

# ===== PUBLIC API =====

func toggle_holographic_mode():
	"""Toggle holographic projection mode"""
	projection_enabled = !projection_enabled
	print("🌈 Holographic mode: %s" % ("ON" if projection_enabled else "OFF"))

func cycle_vr_space_themes():
	"""Cycle through available VR space themes"""
	var themes = ["ASTRAL_REALM", "SPACECLAY_WORKSHOP", "CONSCIOUSNESS_FLOWS"]
	var current_theme = themes[randi() % themes.size()]
	generate_vr_space(current_theme, robot_avatar.global_position if robot_avatar else Vector3.ZERO)
	print("🌈 Generated VR space: %s" % current_theme)

func reset_robot_projection_field():
	"""Reset and regenerate robot holographic field"""
	# Clear existing projections
	for projection in active_holograms:
		remove_holographic_projection(projection)
	
	# Generate new projection field
	if robot_avatar:
		for i in range(5):
			var pos = robot_avatar.global_position + Vector3(randf_range(-3, 3), randf_range(1, 3), randf_range(-3, 3))
			create_holographic_projection("CONSCIOUSNESS", pos, {"intensity": robot_consciousness_level})
	
	print("🤖 Robot projection field reset")

func enhance_consciousness_projection():
	"""Enhance robot consciousness projection intensity"""
	robot_consciousness_level = min(robot_consciousness_level + 0.5, 5.0)
	hologram_intensity = min(hologram_intensity + 0.2, 2.0)
	print("🌈 Consciousness projection enhanced: Level %.1f" % robot_consciousness_level)

# ===== HELPER FUNCTIONS =====

func create_floating_consciousness_orb() -> Node3D:
	var orb = MeshInstance3D.new()
	var orb_mesh = SphereMesh.new()
	orb_mesh.radius = 0.15
	orb.mesh = orb_mesh
	orb.material_override = consciousness_field_material
	return orb

func create_ethereal_mist() -> Node3D:
	var mist = MeshInstance3D.new()
	var mist_mesh = QuadMesh.new()
	mist_mesh.size = Vector2(2.0, 1.0)
	mist.mesh = mist_mesh
	mist.material_override = hologram_base_material
	return mist

func create_clay_workbench() -> Node3D:
	var bench = MeshInstance3D.new()
	var bench_mesh = BoxMesh.new()
	bench_mesh.size = Vector3(1.5, 0.8, 0.8)
	bench.mesh = bench_mesh
	bench.material_override = hologram_base_material
	return bench

func create_material_station() -> Node3D:
	var station = MeshInstance3D.new()
	var station_mesh = CylinderMesh.new()
	station_mesh.height = 1.2
	station_mesh.top_radius = 0.6
	station.mesh = station_mesh
	station.material_override = hologram_base_material
	return station

func create_data_stream_generator() -> Node3D:
	var generator = MeshInstance3D.new()
	var gen_mesh = PrismMesh.new()
	gen_mesh.left_to_right = 0.3
	gen_mesh.top_to_bottom = 1.0
	gen_mesh.front_to_back = 0.3
	generator.mesh = gen_mesh
	generator.material_override = consciousness_field_material
	return generator

func create_central_gravity_well() -> Node3D:
	var well = MeshInstance3D.new()
	var well_mesh = TorusMesh.new()
	well_mesh.inner_radius = 0.8
	well_mesh.outer_radius = 1.5
	well.mesh = well_mesh
	well.material_override = hologram_base_material
	return well

# ===== MISSING FUNCTION IMPLEMENTATIONS =====

func setup_consciousness_projectors():
	"""Initialize consciousness projection systems"""
	# Create consciousness projectors for different levels
	var basic_projector = ConsciousnessProjector.new("basic", 1.0, "BASIC")
	var enhanced_projector = ConsciousnessProjector.new("enhanced", 3.0, "ENHANCED")
	var transcendent_projector = ConsciousnessProjector.new("transcendent", 5.0, "TRANSCENDENT")
	
	consciousness_projectors.append(basic_projector)
	consciousness_projectors.append(enhanced_projector)
	consciousness_projectors.append(transcendent_projector)
	
	print("🧠 Consciousness projectors initialized: %d levels ready" % consciousness_projectors.size())

func start_holographic_projection_cycle():
	"""Start the holographic projection cycle"""
	var projection_timer = Timer.new()
	projection_timer.name = "HolographicProjectionTimer"
	projection_timer.wait_time = 2.0
	projection_timer.timeout.connect(_on_projection_cycle)
	add_child(projection_timer)
	projection_timer.start()
	
	print("🌈 Holographic projection cycle started")

func _on_projection_cycle():
	"""Called periodically to maintain holographic projections"""
	if robot_avatar and projection_enabled:
		# Create ambient consciousness projections
		var ambient_pos = robot_avatar.global_position + Vector3(randf_range(-3, 3), randf_range(1, 4), randf_range(-3, 3))
		create_holographic_projection("CONSCIOUSNESS", ambient_pos, {"intensity": robot_consciousness_level * 0.5})

func generate_initial_vr_spaces():
	"""Generate initial VR spaces around robot"""
	if not robot_avatar:
		return
	
	var robot_pos = robot_avatar.global_position
	
	# Generate one space of each theme
	generate_vr_space("ASTRAL_REALM", robot_pos + Vector3(5, 0, 0))
	generate_vr_space("SPACECLAY_WORKSHOP", robot_pos + Vector3(-5, 0, 0))
	generate_vr_space("CONSCIOUSNESS_FLOWS", robot_pos + Vector3(0, 0, 5))
	
	print("🌌 Initial VR spaces generated around robot")

func process_vr_space_generation(delta: float):
	"""Process ongoing VR space generation"""
	# Update existing VR spaces
	for generator in vr_space_generators:
		_update_vr_space_generator(generator, delta)
	
	# Occasionally generate new spaces
	if randf() < delta * 0.1:  # 10% chance per second
		_generate_random_vr_space()

func _update_vr_space_generator(generator: VRSpaceGenerator, delta: float):
	"""Update a specific VR space generator"""
	# Animate existing spaces
	for space in generator.active_spaces:
		if is_instance_valid(space):
			# Gentle rotation for mystical effect
			space.rotation.y += delta * 0.2
			# Gentle floating motion
			space.position.y += sin(Time.get_time_dict_from_system()["unix"] + space.get_instance_id()) * delta * 0.1

func _generate_random_vr_space():
	"""Generate a random VR space near robot"""
	if not robot_avatar:
		return
	
	var themes = ["ASTRAL_REALM", "SPACECLAY_WORKSHOP", "CONSCIOUSNESS_FLOWS"]
	var random_theme = themes[randi() % themes.size()]
	var random_pos = robot_avatar.global_position + Vector3(
		randf_range(-8, 8),
		randf_range(0, 5), 
		randf_range(-8, 8)
	)
	
	var new_space = generate_vr_space(random_theme, random_pos)
	
	# Add to appropriate generator
	for generator in vr_space_generators:
		if generator.space_theme == random_theme:
			generator.active_spaces.append(new_space)
			break

func manage_consciousness_projection(delta: float):
	"""Manage consciousness projection intensity and effects"""
	# Update consciousness projectors
	for projector in consciousness_projectors:
		_update_consciousness_projector(projector, delta)
	
	# Adjust global consciousness field
	if robot_avatar:
		_update_robot_consciousness_field(delta)

func _update_consciousness_projector(projector: ConsciousnessProjector, delta: float):
	"""Update individual consciousness projector"""
	# Pulse consciousness field based on robot level
	var pulse_intensity = robot_consciousness_level / 5.0
	projector.projection_range = 5.0 + sin(Time.get_time_dict_from_system()["unix"] * 2.0) * pulse_intensity
	
	# Update visual effects
	for effect in projector.visual_effects:
		if is_instance_valid(effect):
			# Consciousness field pulsing
			effect.scale = Vector3.ONE * (1.0 + sin(Time.get_time_dict_from_system()["unix"] * 3.0) * 0.2)

func _update_robot_consciousness_field(delta: float):
	"""Update robot's consciousness field projection"""
	# Create consciousness ripples around robot
	if randf() < delta * robot_consciousness_level * 0.3:  # Higher consciousness = more ripples
		var ripple_pos = robot_avatar.global_position + Vector3(
			randf_range(-2, 2),
			randf_range(0, 3),
			randf_range(-2, 2)
		)
		create_holographic_projection("CONSCIOUSNESS", ripple_pos, {
			"intensity": robot_consciousness_level,
			"ripple": true
		})

func cleanup_holographic_projections():
	"""Clean up all holographic projections"""
	# Remove all active holograms
	for projection in active_holograms:
		if projection.visual_node and is_instance_valid(projection.visual_node):
			projection.visual_node.queue_free()
	
	active_holograms.clear()
	
	# Clean up VR spaces
	for generator in vr_space_generators:
		for space in generator.active_spaces:
			if is_instance_valid(space):
				space.queue_free()
		generator.active_spaces.clear()
	
	# Clean up consciousness projectors
	for projector in consciousness_projectors:
		for effect in projector.visual_effects:
			if is_instance_valid(effect):
				effect.queue_free()
		projector.visual_effects.clear()
	
	print("🧹 All holographic projections cleaned up")

func disconnect_robot_systems():
	"""Disconnect from robot systems safely"""
	robot_body_connected = false
	robot_consciousness_level = 0.0
	robot_protection_protocols.clear()
	
	# Remove projection timer
	var timer = get_node_or_null("HolographicProjectionTimer")
	if timer:
		timer.queue_free()
	
	print("🤖 Disconnected from robot systems")