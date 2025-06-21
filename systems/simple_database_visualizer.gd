# Simple Living Database Visualizer - Working version
extends Node3D
class_name SimpleDatabaseVisualizer

@export var enabled: bool = true
var data_points: Array = []
var gravity_spheres: Array = []

# Materials
var consciousness_material: StandardMaterial3D
var gravity_material: StandardMaterial3D
var input_material: StandardMaterial3D

func _ready():
	setup_materials()
	create_initial_demo()
	print("🌌 Simple Database Visualizer ready!")

func _input(event):
	if not enabled:
		return
	
	# Handle precise clay molding with mouse clicks
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var click_position = get_precise_world_click_position(event.position)
			if click_position != Vector3.ZERO:
				create_spaceclay_at_exact_position(click_position)
				print("🎯 Spaceclay molded at exact click: %s" % click_position)
	
	# Handle camera movement (move the camera point, not the camera)
	if event is InputEventKey and event.pressed:
		var camera_point = get_tree().get_first_node_in_group("camera_points")
		if camera_point:
			var move_speed = 5.0
			match event.keycode:
				KEY_W:
					camera_point.position += camera_point.transform.basis.z * -move_speed
				KEY_S:
					camera_point.position += camera_point.transform.basis.z * move_speed
				KEY_A:
					camera_point.position += camera_point.transform.basis.x * -move_speed
				KEY_D:
					camera_point.position += camera_point.transform.basis.x * move_speed
				KEY_Q:
					camera_point.position.y += move_speed
				KEY_E:
					camera_point.position.y -= move_speed
		
		# Create input visualization for any key
		create_input_data_point(event)

func setup_materials():
	# Purple consciousness material
	consciousness_material = StandardMaterial3D.new()
	consciousness_material.albedo_color = Color(0.8, 0.3, 1.0, 0.8)
	consciousness_material.emission_enabled = true
	consciousness_material.emission = Color(0.5, 0.1, 0.8)
	
	# Orange gravity material
	gravity_material = StandardMaterial3D.new()
	gravity_material.albedo_color = Color(1.0, 0.6, 0.2, 0.4)
	gravity_material.emission_enabled = true
	gravity_material.emission = Color(1.0, 0.4, 0.0)
	
	# Green input material
	input_material = StandardMaterial3D.new()
	input_material.albedo_color = Color(0.2, 1.0, 0.3, 0.9)
	input_material.emission_enabled = true
	input_material.emission = Color(0.1, 0.8, 0.1)

func create_initial_demo():
	# Create gravity points
	create_gravity_point(Vector3(0, 3, 0), 5.0)
	create_gravity_point(Vector3(-5, 2, -5), 3.0)
	create_gravity_point(Vector3(5, 2, -5), 3.0)
	
	# Create some initial consciousness data
	for i in range(5):
		var pos = Vector3(randf_range(-3, 3), randf_range(2, 4), randf_range(-3, 3))
		create_consciousness_point(pos, "initial_data_" + str(i))

func create_gravity_point(position: Vector3, radius: float):
	var gravity_sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = radius
	gravity_sphere.mesh = sphere_mesh
	gravity_sphere.material_override = gravity_material
	gravity_sphere.position = position
	add_child(gravity_sphere)
	gravity_spheres.append(gravity_sphere)
	print("🌍 Created gravity point at %s with radius %.1f" % [position, radius])

func create_consciousness_point(position: Vector3, data: String):
	var consciousness_sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.2
	consciousness_sphere.mesh = sphere_mesh
	consciousness_sphere.material_override = consciousness_material
	consciousness_sphere.position = position
	add_child(consciousness_sphere)
	
	# Add movement
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(consciousness_sphere, "position:y", position.y + 1.0, 2.0)
	tween.tween_property(consciousness_sphere, "position:y", position.y, 2.0)
	
	data_points.append(consciousness_sphere)
	print("💭 Created consciousness point: %s at %s" % [data, position])

func create_input_data_point(event: InputEvent):
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Spawn near the center of view, slightly towards the player
	var spawn_pos = camera.global_position + camera.basis.z * -3.0
	spawn_pos += Vector3(randf_range(-0.5, 0.5), randf_range(-0.2, 0.2), 0)
	
	# Add a small flash effect to show where input came from
	create_input_flash(camera.global_position + camera.basis.z * -1.0)
	
	# Create different visual styles based on input type
	var input_visual = create_spell_like_input_visual(event, spawn_pos)
	add_child(input_visual)
	
	# Add text label with proper background
	var label = Label3D.new()
	if event is InputEventKey:
		label.text = OS.get_keycode_string(event.keycode)
		# Special handling for common keys and spell-like effects
		match event.keycode:
			KEY_SPACE:
				label.text = "SPACE·SPELL"
				create_spaceclay_burst(spawn_pos)
			KEY_ENTER:
				label.text = "CAST·ENTER"
				create_spell_casting_effect(spawn_pos)
			KEY_TAB:
				label.text = "TAB·WARP"
				create_reality_shift_effect(spawn_pos)
			KEY_ESCAPE:
				label.text = "ESC·VOID"
				create_void_bullet_effect(spawn_pos)
			_:
				# Letter keys become spell components
				if event.keycode >= KEY_A and event.keycode <= KEY_Z:
					label.text = "RUNE·" + label.text
					create_rune_manifestation(spawn_pos, label.text)
	else:
		label.text = "INPUT·STREAM"
	
	label.position = Vector3(0, 0.3, 0)
	label.modulate = get_spell_color_for_input(event)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	# Enhanced label visibility with magical glow
	label.outline_modulate = Color.BLACK
	label.outline_size = 3
	
	input_visual.add_child(label)
	
	# Animate flowing movement towards nearest gravity point with spell-like trajectory
	animate_spell_trajectory(input_visual, spawn_pos, event)
	
	print("🪄 Spell-input manifested: %s → casting towards gravity well" % label.text)

func create_input_flash(position: Vector3):
	"""Create a small flash effect at input origin"""
	var flash = MeshInstance3D.new()
	var flash_mesh = SphereMesh.new()
	flash_mesh.radius = 0.1
	flash.mesh = flash_mesh
	
	var flash_material = StandardMaterial3D.new()
	flash_material.albedo_color = Color.WHITE
	flash_material.emission_enabled = true
	flash_material.emission = Color.WHITE
	flash.material_override = flash_material
	flash.position = position
	add_child(flash)
	
	# Quick flash animation
	var flash_tween = create_tween()
	flash_tween.tween_property(flash, "scale", Vector3.ONE * 2.0, 0.1)
	flash_tween.tween_property(flash, "scale", Vector3.ZERO, 0.2)
	flash_tween.tween_callback(flash.queue_free)

func find_nearest_gravity_point(from_pos: Vector3) -> Vector3:
	"""Find the nearest gravity point to flow towards"""
	var nearest_pos = Vector3.ZERO
	var nearest_distance = INF
	
	for gravity_sphere in gravity_spheres:
		if gravity_sphere and is_instance_valid(gravity_sphere):
			var distance = from_pos.distance_to(gravity_sphere.position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_pos = gravity_sphere.position
	
	return nearest_pos

func _process(delta):
	if not enabled:
		return
	
	# Animate existing consciousness points
	for point in data_points:
		if point and is_instance_valid(point):
			point.rotation.y += delta * 0.5

# ===== SPELL-LIKE INPUT VISUALIZATIONS =====

func create_spell_like_input_visual(event: InputEvent, position: Vector3) -> Node3D:
	"""Create spell-like visual based on input type"""
	var visual_container = Node3D.new()
	visual_container.position = position
	
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				# Spaceclay burst - expanding sphere
				return create_spaceclay_visual(position)
			KEY_ENTER:
				# Spell casting - magical projectile
				return create_spell_bullet_visual(position)
			KEY_ESCAPE:
				# Void bullet - dark energy
				return create_void_bullet_visual(position)
			_:
				# Letter keys - rune crystals
				if event.keycode >= KEY_A and event.keycode <= KEY_Z:
					return create_rune_crystal_visual(position)
				else:
					return create_basic_spell_visual(position)
	else:
		return create_basic_spell_visual(position)

func create_spaceclay_visual(position: Vector3) -> Node3D:
	"""Create expanding spaceclay sphere"""
	var clay_sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.15
	clay_sphere.mesh = sphere_mesh
	
	var clay_material = StandardMaterial3D.new()
	clay_material.albedo_color = Color(0.8, 0.6, 0.4, 0.8)  # Clay color
	clay_material.emission_enabled = true
	clay_material.emission = Color(1.0, 0.8, 0.4)
	clay_material.roughness = 0.7
	clay_sphere.material_override = clay_material
	clay_sphere.position = position
	
	# Add expansion animation
	var expand_tween = create_tween()
	expand_tween.set_loops()
	expand_tween.tween_property(clay_sphere, "scale", Vector3.ONE * 1.5, 1.0)
	expand_tween.tween_property(clay_sphere, "scale", Vector3.ONE, 1.0)
	
	return clay_sphere

func create_spell_bullet_visual(position: Vector3) -> Node3D:
	"""Create magical bullet projectile"""
	var bullet = MeshInstance3D.new()
	var bullet_mesh = CylinderMesh.new()
	bullet_mesh.top_radius = 0.05
	bullet_mesh.bottom_radius = 0.1
	bullet_mesh.height = 0.3
	bullet.mesh = bullet_mesh
	
	var bullet_material = StandardMaterial3D.new()
	bullet_material.albedo_color = Color(0.2, 1.0, 0.8, 0.9)  # Magical cyan
	bullet_material.emission_enabled = true
	bullet_material.emission = Color(0.0, 0.8, 0.6)
	bullet_material.metallic = 0.8
	bullet.material_override = bullet_material
	bullet.position = position
	
	# Add spinning animation
	var spin_tween = create_tween()
	spin_tween.set_loops()
	spin_tween.tween_property(bullet, "rotation", Vector3(0, TAU, 0), 0.5)
	
	return bullet

func create_void_bullet_visual(position: Vector3) -> Node3D:
	"""Create dark void bullet"""
	var void_bullet = MeshInstance3D.new()
	var void_mesh = SphereMesh.new()
	void_mesh.radius = 0.12
	void_bullet.mesh = void_mesh
	
	var void_material = StandardMaterial3D.new()
	void_material.albedo_color = Color(0.1, 0.0, 0.2, 0.7)  # Dark purple
	void_material.emission_enabled = true
	void_material.emission = Color(0.3, 0.0, 0.5)
	void_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	void_bullet.material_override = void_material
	void_bullet.position = position
	
	# Add ominous pulsing
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(void_bullet, "scale", Vector3.ONE * 0.7, 0.8)
	pulse_tween.tween_property(void_bullet, "scale", Vector3.ONE * 1.3, 0.8)
	
	return void_bullet

func create_rune_crystal_visual(position: Vector3) -> Node3D:
	"""Create crystalline rune structure"""
	var crystal = MeshInstance3D.new()
	# FIX: PrismMesh doesn't exist in Godot 4, use BoxMesh instead
	var crystal_mesh = BoxMesh.new()
	crystal_mesh.size = Vector3(0.1, 0.2, 0.1)  # Equivalent to left_to_right, top_to_bottom, front_to_back
	crystal.mesh = crystal_mesh
	
	var crystal_material = StandardMaterial3D.new()
	crystal_material.albedo_color = Color(1.0, 0.7, 1.0, 0.8)  # Magical pink
	crystal_material.emission_enabled = true
	crystal_material.emission = Color(0.8, 0.4, 0.8)
	crystal_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal.material_override = crystal_material
	crystal.position = position
	
	# Add mystical rotation
	var rotate_tween = create_tween()
	rotate_tween.set_loops()
	rotate_tween.tween_property(crystal, "rotation", Vector3(TAU, 0, TAU), 2.0)
	
	return crystal

func create_basic_spell_visual(position: Vector3) -> Node3D:
	"""Create basic spell cube (fallback)"""
	var spell_cube = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(0.1, 0.1, 0.1)
	spell_cube.mesh = cube_mesh
	spell_cube.material_override = input_material
	spell_cube.position = position
	return spell_cube

func get_spell_color_for_input(event: InputEvent) -> Color:
	"""Get magical color based on input type"""
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				return Color.ORANGE  # Spaceclay
			KEY_ENTER:
				return Color.CYAN    # Spell casting
			KEY_ESCAPE:
				return Color.PURPLE  # Void magic
			_:
				if event.keycode >= KEY_A and event.keycode <= KEY_Z:
					return Color.MAGENTA  # Rune magic
				else:
					return Color.GREEN    # Basic spells
	else:
		return Color.WHITE

func animate_spell_trajectory(input_visual: Node3D, spawn_pos: Vector3, event: InputEvent):
	"""Animate spell-like trajectory towards gravity points"""
	var tween = create_tween()
	var target_pos = find_nearest_gravity_point(spawn_pos)
	
	# Different trajectory styles based on spell type
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				# Spaceclay expands then flows
				tween.tween_property(input_visual, "scale", Vector3.ONE * 2.0, 0.5)
				tween.parallel().tween_property(input_visual, "position", target_pos + Vector3(0, 2, 0), 3.0)
			KEY_ENTER:
				# Spell bullet shoots fast and straight
				if target_pos != Vector3.ZERO:
					tween.tween_property(input_visual, "position", target_pos + Vector3(0, 1, 0), 1.0)
				else:
					tween.tween_property(input_visual, "position", spawn_pos + Vector3(0, 5, 0), 1.5)
			KEY_ESCAPE:
				# Void bullet warps through space
				tween.tween_property(input_visual, "scale", Vector3.ZERO, 0.3)
				tween.tween_callback(func(): input_visual.position = target_pos + Vector3(0, 3, 0))
				tween.tween_property(input_visual, "scale", Vector3.ONE, 0.3)
			_:
				# Default mystical flow
				if target_pos != Vector3.ZERO:
					# Curved path like magic
					var mid_point = (spawn_pos + target_pos) * 0.5 + Vector3(0, 2, 0)
					tween.tween_property(input_visual, "position", mid_point, 1.0)
					tween.tween_property(input_visual, "position", target_pos + Vector3(0, 2, 0), 1.0)
				else:
					tween.tween_property(input_visual, "position", spawn_pos + Vector3(0, 4, 0), 2.5)
	
	tween.tween_callback(input_visual.queue_free)

# ===== SPELL EFFECT CREATORS =====

func create_spaceclay_burst(position: Vector3):
	"""Create a burst of spaceclay particles"""
	for i in range(3):
		var particle = MeshInstance3D.new()
		var particle_mesh = SphereMesh.new()
		particle_mesh.radius = 0.05
		particle.mesh = particle_mesh
		
		var particle_material = StandardMaterial3D.new()
		particle_material.albedo_color = Color(0.9, 0.7, 0.5, 0.6)
		particle_material.emission_enabled = true
		particle_material.emission = Color(1.0, 0.8, 0.4)
		particle.material_override = particle_material
		
		particle.position = position + Vector3(randf_range(-0.3, 0.3), randf_range(-0.1, 0.1), randf_range(-0.3, 0.3))
		add_child(particle)
		
		var particle_tween = create_tween()
		particle_tween.tween_property(particle, "position", particle.position + Vector3(randf_range(-2, 2), randf_range(1, 3), randf_range(-2, 2)), 2.0)
		particle_tween.parallel().tween_property(particle, "scale", Vector3.ZERO, 2.0)
		particle_tween.tween_callback(particle.queue_free)

func create_spell_casting_effect(position: Vector3):
	"""Create magical casting effect"""
	var casting_ring = MeshInstance3D.new()
	var ring_mesh = TorusMesh.new()
	ring_mesh.inner_radius = 0.1
	ring_mesh.outer_radius = 0.3
	casting_ring.mesh = ring_mesh
	
	var ring_material = StandardMaterial3D.new()
	ring_material.albedo_color = Color(0.2, 1.0, 0.8, 0.7)
	ring_material.emission_enabled = true
	ring_material.emission = Color(0.0, 0.8, 0.6)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	casting_ring.material_override = ring_material
	casting_ring.position = position
	add_child(casting_ring)
	
	var ring_tween = create_tween()
	ring_tween.tween_property(casting_ring, "scale", Vector3.ONE * 3.0, 1.0)
	ring_tween.parallel().tween_property(casting_ring, "rotation", Vector3(0, TAU, 0), 1.0)
	ring_tween.tween_callback(casting_ring.queue_free)

func create_reality_shift_effect(position: Vector3):
	"""Create reality warping effect"""
	var warp_cube = MeshInstance3D.new()
	var warp_mesh = BoxMesh.new()
	warp_mesh.size = Vector3(0.2, 0.2, 0.2)
	warp_cube.mesh = warp_mesh
	
	var warp_material = StandardMaterial3D.new()
	warp_material.albedo_color = Color(1.0, 1.0, 0.2, 0.8)
	warp_material.emission_enabled = true
	warp_material.emission = Color(1.0, 1.0, 0.0)
	warp_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	warp_cube.material_override = warp_material
	warp_cube.position = position
	add_child(warp_cube)
	
	var warp_tween = create_tween()
	warp_tween.tween_property(warp_cube, "scale", Vector3(3, 0.1, 3), 0.5)
	warp_tween.tween_property(warp_cube, "scale", Vector3.ZERO, 0.5)
	warp_tween.tween_callback(warp_cube.queue_free)

func create_void_bullet_effect(position: Vector3):
	"""Create void energy effect"""
	var void_sphere = MeshInstance3D.new()
	var void_mesh = SphereMesh.new()
	void_mesh.radius = 0.2
	void_sphere.mesh = void_mesh
	
	var void_material = StandardMaterial3D.new()
	void_material.albedo_color = Color(0.1, 0.0, 0.3, 0.5)
	void_material.emission_enabled = true
	void_material.emission = Color(0.3, 0.0, 0.5)
	void_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	void_sphere.material_override = void_material
	void_sphere.position = position
	add_child(void_sphere)
	
	var void_tween = create_tween()
	void_tween.tween_property(void_sphere, "scale", Vector3.ONE * 0.1, 0.3)
	void_tween.tween_property(void_sphere, "scale", Vector3.ONE * 2.0, 0.7)
	void_tween.parallel().tween_property(void_sphere.material_override, "albedo_color:a", 0.0, 0.7)
	void_tween.tween_callback(void_sphere.queue_free)

func create_rune_manifestation(position: Vector3, rune_text: String):
	"""Create mystical rune effect"""
	var rune_glow = MeshInstance3D.new()
	var glow_mesh = QuadMesh.new()
	glow_mesh.size = Vector2(0.5, 0.5)
	rune_glow.mesh = glow_mesh
	
	var glow_material = StandardMaterial3D.new()
	glow_material.albedo_color = Color(1.0, 0.7, 1.0, 0.6)
	glow_material.emission_enabled = true
	glow_material.emission = Color(0.8, 0.4, 0.8)
	glow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	rune_glow.material_override = glow_material
	rune_glow.position = position
	add_child(rune_glow)
	
	var rune_tween = create_tween()
	rune_tween.tween_property(rune_glow, "rotation", Vector3(0, 0, TAU), 1.5)
	rune_tween.parallel().tween_property(rune_glow, "scale", Vector3.ONE * 2.0, 1.5)
	rune_tween.tween_callback(rune_glow.queue_free)

# ===== PRECISE CLICK POSITIONING SYSTEM =====

func get_precise_world_click_position(screen_pos: Vector2) -> Vector3:
	"""Get exact 3D world position where user clicked"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return Vector3.ZERO
	
	# Cast ray from camera through click position
	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_direction = camera.project_ray_normal(screen_pos)
	
	# Perform raycast to find exact surface hit
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 100.0)
	var result = space_state.intersect_ray(query)
	
	if result:
		# Hit a surface - use exact hit point
		return result.position
	else:
		# No surface hit - project onto a reasonable distance
		return ray_origin + ray_direction * 10.0

func create_spaceclay_at_exact_position(position: Vector3):
	"""Create spaceclay formation at exact click position"""
	# Create main spaceclay sphere exactly where clicked
	var clay_center = create_spaceclay_visual(position)
	clay_center.scale = Vector3.ONE * 1.5  # Make it more visible
	add_child(clay_center)
	
	# Create clay formation around the center point
	create_spaceclay_formation(position)
	
	# Add precise targeting indicator
	create_targeting_indicator(position)
	
	print("🎯 Spaceclay formation created at precise coordinates: %s" % position)

func create_spaceclay_formation(center_pos: Vector3):
	"""Create a formation of spaceclay around the center point"""
	var formation_points = [
		Vector3(0.5, 0, 0), Vector3(-0.5, 0, 0),
		Vector3(0, 0.5, 0), Vector3(0, -0.5, 0),
		Vector3(0, 0, 0.5), Vector3(0, 0, -0.5),
		Vector3(0.3, 0.3, 0), Vector3(-0.3, -0.3, 0),
		Vector3(0.3, 0, 0.3), Vector3(-0.3, 0, -0.3)
	]
	
	for offset in formation_points:
		var clay_point = create_spaceclay_visual(center_pos + offset)
		clay_point.scale = Vector3.ONE * 0.8
		add_child(clay_point)
		
		# Add flowing connection to center
		create_clay_connection_beam(center_pos + offset, center_pos)

func create_clay_connection_beam(from_pos: Vector3, to_pos: Vector3):
	"""Create a flowing beam connection between clay points"""
	var beam = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 0.02
	cylinder_mesh.bottom_radius = 0.02
	
	var distance = from_pos.distance_to(to_pos)
	cylinder_mesh.height = distance
	beam.mesh = cylinder_mesh
	
	# Position beam between the two points
	beam.position = (from_pos + to_pos) * 0.5
	beam.look_at(to_pos, Vector3.UP)
	beam.rotate_object_local(Vector3.RIGHT, PI/2)
	
	var beam_material = StandardMaterial3D.new()
	beam_material.albedo_color = Color(1.0, 0.8, 0.4, 0.6)
	beam_material.emission_enabled = true
	beam_material.emission = Color(1.0, 0.6, 0.2)
	beam_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam.material_override = beam_material
	
	add_child(beam)
	
	# Animate the beam with flowing energy
	var beam_tween = create_tween()
	beam_tween.set_loops()
	beam_tween.tween_property(beam.material_override, "emission", Color(1.0, 1.0, 0.8), 0.5)
	beam_tween.tween_property(beam.material_override, "emission", Color(1.0, 0.6, 0.2), 0.5)
	
	# Remove beam after a while
	beam_tween.tween_delay(3.0)
	beam_tween.tween_callback(beam.queue_free)

func create_targeting_indicator(position: Vector3):
	"""Create visual indicator showing exact click target"""
	var indicator = MeshInstance3D.new()
	var torus_mesh = TorusMesh.new()
	torus_mesh.inner_radius = 0.1
	torus_mesh.outer_radius = 0.3
	indicator.mesh = torus_mesh
	
	var indicator_material = StandardMaterial3D.new()
	indicator_material.albedo_color = Color(1.0, 1.0, 1.0, 0.8)
	indicator_material.emission_enabled = true
	indicator_material.emission = Color(1.0, 1.0, 1.0)
	indicator_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	indicator.material_override = indicator_material
	indicator.position = position
	add_child(indicator)
	
	# Animate targeting ring
	var indicator_tween = create_tween()
	indicator_tween.tween_property(indicator, "scale", Vector3.ONE * 3.0, 1.0)
	indicator_tween.parallel().tween_property(indicator, "rotation", Vector3(0, TAU, 0), 1.0)
	indicator_tween.parallel().tween_property(indicator.material_override, "albedo_color:a", 0.0, 1.0)
	indicator_tween.tween_callback(indicator.queue_free)
