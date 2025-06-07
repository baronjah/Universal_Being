# Universe3D.gd - Main Universe Controller
extends Node3D

# === UNIVERSE CONSTANTS ===
# NOTE: Scaled for real-time simulation - 1 unit = 1000 km
const G = 6.67430e-11 * 1e15  # Gravitational constant (scaled for game)
const C = 299792.458  # Speed of light (km/s)
const UNIVERSE_SCALE = 1.0
const TIME_SCALE = 1.0  # Can be adjusted for time acceleration
const AU = 149597.870  # Astronomical Unit in our scale

# === CELESTIAL BODY TYPES ===
enum BodyType {
	STAR,
	PLANET,
	MOON,
	ASTEROID,
	BLACK_hole,
	NEBULA,
	COMET,
	GALAXY_CORE
}

# === UNIVERSE STATE ===
var celestial_bodies = []
var selected_body = null
var universe_time = 0.0
var time_multiplier = 1.0
var paused = false
var creation_mode = BodyType.PLANET
var placing_body = false
var preview_body = null

# === VISUAL SETTINGS ===
var show_orbits = true
var show_gravity_wells = false
var show_labels = true
var show_grid = false
var trail_length = 500
var star_brightness = 1.0

# === CAMERA SETTINGS ===
@onready var camera = $Camera3D
@onready var camera_pivot = $CameraPivot
var camera_distance = 1000.0
var camera_rotation = Vector2(0, -0.3)
var mouse_sensitivity = 0.002
var zoom_speed = 0.1
var pan_speed = 1.0

# === UI REFERENCES ===
@onready var hud = $HUD
@onready var info_panel = $HUD/InfoPanel
@onready var time_label = $HUD/TimeLabel
@onready var body_counter = $HUD/BodyCounter
@onready var creation_panel = $HUD/CreationPanel

# === RESOURCES ===
var star_material = preload("res://materials/star_material.tres")
var planet_material = preload("res://materials/planet_material.tres")
var black_hole_material = preload("res://materials/black_hole_material.tres")

# Celestial body scene
const CelestialBodyScene = preload("res://scenes/CelestialBody3D.tscn")

func _ready():
	# NOTE: Initialize universe with our solar system as example
	_setup_camera()
	_setup_environment()
	_create_solar_system()
	_setup_ui()
	
	# Connect signals
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	print("Universe initialized. Press H for controls help.")

func _setup_camera():
	# NOTE: Camera starts focused on origin, can follow selected bodies
	camera_pivot = Node3D.new()
	add_child(camera_pivot)
	
	camera = Camera3D.new()
	camera.fov = 60
	camera.near = 0.1
	camera.far = 1000000.0
	camera_pivot.add_child(camera)
	camera.position.z = camera_distance
	
	# Add camera light for close inspection
	var cam_light = OmniLight3D.new()
	cam_light.energy = 0.1
	cam_light.omni_range = 100
	camera.add_child(cam_light)

func _setup_environment():
	# NOTE: Space environment with stars and nebulae
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.01, 0.01, 0.02)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.05, 0.05, 0.1)
	env.ambient_light_energy = 0.1
	
	# Add glow for stars and effects
	env.glow_enabled = true
	env.glow_intensity = 1.5
	env.glow_bloom = 0.2
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	
	# Volumetric fog for nebula effects
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.001
	env.volumetric_fog_albedo = Color(0.2, 0.1, 0.3)
	env.volumetric_fog_emission = Color(0.1, 0.05, 0.15)
	
	var world_env = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	
	# Create starfield
	_create_starfield()

func _create_starfield():
	# NOTE: Background stars using MultiMeshInstance3D for performance
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = SphereMesh.new()
	multimesh.mesh.radial_segments = 4
	multimesh.mesh.rings = 2
	multimesh.mesh.radius = 50
	multimesh.instance_count = 10000
	
	var star_field = MultiMeshInstance3D.new()
	star_field.multimesh = multimesh
	
	# Scatter stars in sphere around origin
	for i in range(multimesh.instance_count):
		var transform = Transform3D()
		var pos = Vector3(
			randf_range(-50000, 50000),
			randf_range(-50000, 50000),
			randf_range(-50000, 50000)
		)
		# Ensure minimum distance from origin
		if pos.length() < 10000:
			pos = pos.normalized() * randf_range(10000, 50000)
		
		transform.origin = pos
		var scale = randf_range(0.5, 2.0)
		transform.basis = transform.basis.scaled(Vector3.ONE * scale)
		multimesh.set_instance_transform(i, transform)
		
		# Star color variation
		var color = Color(1, randf_range(0.8, 1), randf_range(0.7, 1))
		multimesh.set_instance_color(i, color)
	
	# Star material
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1)
	mat.emission_enabled = true
	mat.emission = Color(1, 1, 1)
	mat.emission_energy = 2.0
	star_field.material_override = mat
	
	add_child(star_field)

func _create_solar_system():
	# NOTE: Create a simplified solar system for starting reference
	# Sun
	var sun = _create_celestial_body(BodyType.STAR, Vector3.ZERO, Vector3.ZERO, 695.7, 1.989e30)
	sun.name = "Sol"
	sun.temperature = 5778
	sun.luminosity = 1.0
	
	# Planets with realistic orbital velocities
	var planets_data = [
		# Name, distance (AU), mass (Earth masses), radius (Earth radii), color
		["Mercury", 0.387, 0.0553, 0.383, Color(0.7, 0.6, 0.5)],
		["Venus", 0.723, 0.815, 0.949, Color(0.9, 0.8, 0.5)],
		["Earth", 1.0, 1.0, 1.0, Color(0.2, 0.4, 0.8)],
		["Mars", 1.524, 0.107, 0.532, Color(0.8, 0.3, 0.2)],
		["Jupiter", 5.203, 317.8, 11.21, Color(0.8, 0.7, 0.6)],
		["Saturn", 9.537, 95.2, 9.45, Color(0.9, 0.8, 0.6)],
	]
	
	for planet_data in planets_data:
		var distance = planet_data[1] * AU
		var orbital_velocity = sqrt(G * sun.mass / distance)
		var position = Vector3(distance, 0, 0)
		var velocity = Vector3(0, 0, orbital_velocity)
		
		var planet = _create_celestial_body(
			BodyType.PLANET,
			position,
			velocity,
			planet_data[3] * 6.371,  # Earth radius = 6371 km
			planet_data[2] * 5.972e24  # Earth mass
		)
		planet.name = planet_data[0]
		planet.base_color = planet_data[4]
		
		# Add moon to Earth
		if planet_data[0] == "Earth":
			var moon_dist = 384.4  # thousand km
			var moon_vel = sqrt(G * planet.mass / moon_dist)
			var moon = _create_celestial_body(
				BodyType.MOON,
				position + Vector3(moon_dist, 0, 0),
				velocity + Vector3(0, 0, moon_vel),
				1.737,
				7.342e22
			)
			moon.name = "Luna"
			moon.parent_body = planet

func _create_celestial_body(type: BodyType, position: Vector3, velocity: Vector3, radius: float, mass: float) -> Node3D:
	# NOTE: Factory method for creating different celestial objects
	var body = CelestialBodyScene.instantiate()
	body.body_type = type
	body.position = position
	body.velocity = velocity
	body.radius = radius
	body.mass = mass
	body.trail_length = trail_length
	
	# Set visual properties based on type
	match type:
		BodyType.STAR:
			body.emission_energy = 5.0
			body.base_color = Color(1, 0.95, 0.8)
			body.has_corona = true
		BodyType.PLANET:
			body.emission_energy = 0.0
			body.generate_terrain = true
		BodyType.MOON:
			body.emission_energy = 0.0
			body.base_color = Color(0.8, 0.8, 0.8)
		BodyType.ASTEROID:
			body.emission_energy = 0.0
			body.base_color = Color(0.6, 0.6, 0.6)
			body.is_irregular = true
		BodyType.BLACK_hole:
			body.emission_energy = 0.0
			body.base_color = Color(0, 0, 0)
			body.has_accretion_disk = true
			body.warps_space = true
		BodyType.COMET:
			body.emission_energy = 0.0
			body.base_color = Color(0.7, 0.8, 0.9)
			body.has_tail = true
	
	add_child(body)
	celestial_bodies.append(body)
	
	# Connect signals
	body.selected.connect(_on_body_selected)
	body.destroyed.connect(_on_body_destroyed)
	
	return body

func _physics_process(delta):
	if paused:
		return
	
	# NOTE: Main physics loop - N-body gravitation
	var scaled_delta = delta * time_multiplier * TIME_SCALE
	universe_time += scaled_delta
	
	# Update gravitational forces between all bodies
	for i in range(celestial_bodies.size()):
		var body1 = celestial_bodies[i]
		if not is_instance_valid(body1):
			continue
			
		body1.total_force = Vector3.ZERO
		
		for j in range(celestial_bodies.size()):
			if i == j:
				continue
				
			var body2 = celestial_bodies[j]
			if not is_instance_valid(body2):
				continue
			
			# Calculate gravitational force
			var distance_vec = body2.position - body1.position
			var distance = distance_vec.length()
			
			if distance > 0.1:  # Avoid division by zero
				var force_magnitude = G * body1.mass * body2.mass / (distance * distance)
				var force_direction = distance_vec.normalized()
				body1.total_force += force_direction * force_magnitude
				
				# NOTE: Check for collision
				if distance < body1.radius + body2.radius:
					_handle_collision(body1, body2)
	
	# Update positions using Verlet integration for stability
	for body in celestial_bodies:
		if is_instance_valid(body):
			body.update_physics(scaled_delta)
	
	# Update UI
	_update_hud()

func _handle_collision(body1: Node3D, body2: Node3D):
	# NOTE: Realistic collision - larger body absorbs smaller
	var larger = body1 if body1.mass > body2.mass else body2
	var smaller = body2 if body1.mass > body2.mass else body1
	
	# Conservation of momentum
	var total_momentum = body1.velocity * body1.mass + body2.velocity * body2.mass
	larger.velocity = total_momentum / (body1.mass + body2.mass)
	larger.mass += smaller.mass
	
	# Increase radius (volume-based)
	var total_volume = 4.0/3.0 * PI * pow(body1.radius, 3) + 4.0/3.0 * PI * pow(body2.radius, 3)
	larger.radius = pow(total_volume * 3.0 / (4.0 * PI), 1.0/3.0)
	
	# Create explosion effect
	_create_collision_effect(smaller.position, smaller.radius)
	
	# Remove smaller body
	celestial_bodies.erase(smaller)
	smaller.queue_free()

func _create_collision_effect(pos: Vector3, size: float):
	# NOTE: Particle explosion and shockwave
	var particles = GPUParticles3D.new()
	particles.amount = 1000
	particles.lifetime = 2.0
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.emission_enabled = true
	mat.emission = Color(1, 0.8, 0.3)
	mat.emission_energy = 3.0
	
	var sphere = SphereMesh.new()
	sphere.radius = size * 0.1
	particles.draw_pass_1 = sphere
	particles.material_override = mat
	
	add_child(particles)
	particles.emitting = true
	
	# Auto-remove after effect
	await get_tree().create_timer(3.0).timeout
	particles.queue_free()

func _input(event):
	# NOTE: Camera controls - mouse for rotation, wheel for zoom
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				camera_distance *= 0.9
				camera_distance = clamp(camera_distance, 10, 100000)
			MOUSE_BUTTON_WHEEL_DOWN:
				camera_distance *= 1.1
				camera_distance = clamp(camera_distance, 10, 100000)
			MOUSE_BUTTON_LEFT:
				if placing_body and preview_body:
					_confirm_body_placement()
				else:
					_handle_selection(event.position)
			MOUSE_BUTTON_RIGHT:
				if placing_body:
					_cancel_body_placement()
			MOUSE_BUTTON_MIDDLE:
				# Pan camera
				pass
	
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not placing_body:
			# Rotate camera
			camera_rotation.x -= event.relative.x * mouse_sensitivity
			camera_rotation.y -= event.relative.y * mouse_sensitivity
			camera_rotation.y = clamp(camera_rotation.y, -PI/2 + 0.1, PI/2 - 0.1)
		
		if placing_body and preview_body:
			_update_preview_position(event.position)
	
	# Keyboard shortcuts
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				paused = !paused
			KEY_H:
				_show_help()
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7:
				creation_mode = event.keycode - KEY_1
				_start_body_placement()
			KEY_DELETE:
				if selected_body:
					celestial_bodies.erase(selected_body)
					selected_body.queue_free()
					selected_body = null
			KEY_O:
				show_orbits = !show_orbits
			KEY_G:
				show_gravity_wells = !show_gravity_wells
			KEY_L:
				show_labels = !show_labels
			KEY_T:
				# Cycle time speed
				var speeds = [0.0, 1.0, 10.0, 100.0, 1000.0, 10000.0]
				var current_idx = speeds.find(time_multiplier)
				time_multiplier = speeds[(current_idx + 1) % speeds.size()]
			KEY_R:
				# Reset camera
				camera_rotation = Vector2(0, -0.3)
				camera_distance = 1000.0
				camera_pivot.position = Vector3.ZERO

func _update_camera():
	# NOTE: Smooth camera movement and following
	var target_pos = Vector3.ZERO
	if selected_body and is_instance_valid(selected_body):
		target_pos = selected_body.position
	
	camera_pivot.position = camera_pivot.position.lerp(target_pos, 0.1)
	camera_pivot.rotation.x = camera_rotation.y
	camera_pivot.rotation.y = camera_rotation.x
	
	camera.position = Vector3(0, 0, camera_distance)

func _process(delta):
	_update_camera()
	
	# Update visual effects
	if show_orbits:
		_draw_orbits()
	if show_gravity_wells:
		_draw_gravity_wells()

func _draw_orbits():
	# NOTE: Predict and draw future orbits
	# This is expensive, so only do it for selected body or all if few bodies
	if celestial_bodies.size() < 20 or selected_body:
		var bodies_to_draw = [selected_body] if selected_body else celestial_bodies
		
		for body in bodies_to_draw:
			if is_instance_valid(body) and body.body_type != BodyType.STAR:
				# Simple orbit prediction (assumes dominant central mass)
				var nearest_star = _find_nearest_star(body)
				if nearest_star:
					body.draw_predicted_orbit(nearest_star)

func _find_nearest_star(body: Node3D) -> Node3D:
	var nearest = null
	var min_dist = INF
	
	for other in celestial_bodies:
		if other.body_type == BodyType.STAR:
			var dist = body.position.distance_to(other.position)
			if dist < min_dist:
				min_dist = dist
				nearest = other
	
	return nearest

func _start_body_placement():
	# NOTE: Interactive placement mode for new bodies
	placing_body = true
	preview_body = _create_preview_body(creation_mode)
	
	# Show velocity helper
	var vel_helper = Node3D.new()
	vel_helper.name = "VelocityHelper"
	preview_body.add_child(vel_helper)

func _create_preview_body(type: BodyType) -> Node3D:
	# Simplified preview mesh
	var preview = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = 10  # Default size, adjustable
	preview.mesh = mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	preview.material_override = mat
	
	add_child(preview)
	return preview

func _update_preview_position(mouse_pos: Vector2):
	# Project mouse to 3D space
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 10000
	
	# Place on XZ plane for simplicity
	var plane = Plane(Vector3.UP, 0)
	var intersection = plane.intersects_ray(from, to - from)
	
	if intersection:
		preview_body.position = intersection

func _confirm_body_placement():
	# NOTE: Create actual body from preview
	var body = _create_celestial_body(
		creation_mode,
		preview_body.position,
		Vector3.ZERO,  # Will set velocity after
		10.0,  # Default radius
		1e24   # Default mass
	)
	
	# Set initial velocity based on nearest massive body
	var nearest = _find_nearest_star(body)
	if nearest:
		var dist = body.position.distance_to(nearest.position)
		var orbital_vel = sqrt(G * nearest.mass / dist)
		var tangent = (body.position - nearest.position).cross(Vector3.UP).normalized()
		body.velocity = tangent * orbital_vel
	
	_cancel_body_placement()
	selected_body = body

func _cancel_body_placement():
	placing_body = false
	if preview_body:
		preview_body.queue_free()
		preview_body = null

func _handle_selection(mouse_pos: Vector2):
	# NOTE: Raycast to select bodies
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100000
	
	var space_state = get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to
	
	var result = space_state.intersect_ray(ray_params)
	
	if result:
		var body = result.collider.get_parent()
		if body in celestial_bodies:
			_on_body_selected(body)
	else:
		selected_body = null

func _on_body_selected(body: Node3D):
	selected_body = body
	# Update info panel with body data
	_update_info_panel()

func _on_body_destroyed(body: Node3D):
	celestial_bodies.erase(body)
	if selected_body == body:
		selected_body = null

func _update_hud():
	# NOTE: Update time, body count, and stats
	if time_label:
		var years = universe_time / (365.25 * 24 * 3600)
		time_label.text = "Time: %.2f years | Speed: %dx" % [years, time_multiplier]
	
	if body_counter:
		body_counter.text = "Bodies: %d" % celestial_bodies.size()

func _update_info_panel():
	if not info_panel or not selected_body:
		return
	
	var info = """
	[b]%s[/b]
	Type: %s
	Mass: %e kg
	Radius: %.1f km
	Velocity: %.1f km/s
	""" % [
		selected_body.name,
		_get_type_name(selected_body.body_type),
		selected_body.mass,
		selected_body.radius,
		selected_body.velocity.length()
	]
	
	info_panel.get_node("Label").text = info

func _get_type_name(type: BodyType) -> String:
	match type:
		BodyType.STAR: return "Star"
		BodyType.PLANET: return "Planet"
		BodyType.MOON: return "Moon"
		BodyType.ASTEROID: return "Asteroid"
		BodyType.BLACK_hole: return "Black Hole"
		BodyType.NEBULA: return "Nebula"
		BodyType.COMET: return "Comet"
		BodyType.GALAXY_CORE: return "Galaxy Core"
		_: return "Unknown"

func _show_help():
	# NOTE: Display control help
	var help_text = """
	=== UNIVERSE CONTROLS ===
	Mouse: Rotate camera
	Scroll: Zoom in/out
	Left Click: Select body / Place body
	Right Click: Cancel placement
	
	1-7: Select body type to create
	Space: Pause/Resume
	T: Change time speed
	O: Toggle orbits
	G: Toggle gravity visualization
	L: Toggle labels
	Delete: Remove selected body
	R: Reset camera
	H: Show this help
	
	=== CURRENT MODE ===
	Creation: %s
	Time: %dx speed
	""" % [_get_type_name(creation_mode), time_multiplier]
	
	print(help_text)
	# TODO: Show in UI panel

func _setup_ui():
	# NOTE: Create basic UI - expand this with proper scenes
	hud = CanvasLayer.new()
	add_child(hud)
	
	# Time display
	time_label = Label.new()
	time_label.position = Vector2(10, 10)
	time_label.add_theme_font_size_override("font_size", 16)
	hud.add_child(time_label)
	
	# Body counter
	body_counter = Label.new()
	body_counter.position = Vector2(10, 40)
	body_counter.add_theme_font_size_override("font_size", 16)
	hud.add_child(body_counter)
	
	# Info panel (placeholder)
	info_panel = Panel.new()
	info_panel.position = Vector2(10, 100)
	info_panel.size = Vector2(300, 200)
	info_panel.visible = false
	hud.add_child(info_panel)
	
	var info_label = RichTextLabel.new()
	info_label.bbcode_enabled = true
	info_label.position = Vector2(10, 10)
	info_label.size = Vector2(280, 180)
	info_panel.add_child(info_label)

func _on_viewport_resized():
	# Handle window resize
	pass

# === ADVANCED FEATURES ===

func create_galaxy(center: Vector3, num_stars: int = 1000, radius: float = 50000):
	# NOTE: Procedural galaxy generation with spiral arms
	var num_arms = randi_range(2, 6)
	var arm_angle = TAU / num_arms
	
	# Central supermassive black hole
	var black_hole = _create_celestial_body(
		BodyType.BLACK_hole,
		center,
		Vector3.ZERO,
		100,
		4e30  # 2 million solar masses
	)
	black_hole.name = "Sagittarius A*"
	
	# Generate spiral arms
	for i in range(num_stars):
		var arm = i % num_arms
		var progress = float(i) / float(num_stars)
		var arm_offset = randf_range(-0.3, 0.3)
		
		# Logarithmic spiral
		var angle = arm * arm_angle + progress * TAU * 3 + arm_offset
		var dist = radius * (0.1 + progress * 0.9) * randf_range(0.8, 1.2)
		
		var pos = Vector3(
			cos(angle) * dist,
			randf_range(-radius * 0.1, radius * 0.1),  # Galactic disk
			sin(angle) * dist
		) + center
		
		# Orbital velocity for stable galaxy
		var orbital_speed = sqrt(G * black_hole.mass / dist)
		var tangent = Vector3(-sin(angle), 0, cos(angle))
		var velocity = tangent * orbital_speed * randf_range(0.9, 1.1)
		
		# Star properties vary by position
		var star_mass = randf_range(0.5, 3.0) * 1.989e30
		var star_radius = randf_range(0.5, 2.0) * 695.7
		
		var star = _create_celestial_body(
			BodyType.STAR,
			pos,
			velocity,
			star_radius,
			star_mass
		)
		
		# Color based on position (blue in arms, red in center)
		var color_temp = remap(dist, 0, radius, 3000, 8000)
		star.set_temperature(color_temp)

func simulate_big_bang(num_particles: int = 5000):
	# NOTE: Explosive universe creation from singularity
	paused = true
	
	# Clear existing bodies
	for body in celestial_bodies:
		body.queue_free()
	celestial_bodies.clear()
	
	# Create initial singularity
	var singularity = _create_celestial_body(
		BodyType.BLACK_hole,
		Vector3.ZERO,
		Vector3.ZERO,
		1,
		1e40  # Enormous mass
	)
	singularity.name = "Primordial Singularity"
	
	await get_tree().create_timer(1.0).timeout
	
	# Explosion!
	singularity.queue_free()
	celestial_bodies.erase(singularity)
	
	# Create expanding matter
	for i in range(num_particles):
		var direction = Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()
		
		var speed = randf_range(1000, 10000)  # Expansion speed
		var distance = randf_range(0, 100)
		
		var particle = _create_celestial_body(
			BodyType.ASTEROID if randf() > 0.1 else BodyType.STAR,
			direction * distance,
			direction * speed,
			randf_range(0.1, 10),
			randf_range(1e20, 1e25)
		)
		
		particle.name = "Primordial Matter %d" % i
	
	paused = false
	print("Big Bang simulation started! Watch the universe expand...")

# === SHADER MANAGEMENT ===

func get_star_shader_code() -> String:
	# NOTE: Returns shader code for star rendering
	return """
shader_type spatial;
render_mode unshaded, blend_add;

uniform float time_scale = 1.0;
uniform float temperature = 5778.0; // Kelvin
uniform float luminosity = 1.0;
uniform float corona_size = 1.5;

varying vec3 world_pos;
varying vec3 view_dir;

// Planck's law approximation for star color
vec3 planck_color(float temp) {
	vec3 color;
	
	// Simplified color temperature to RGB
	if (temp < 3500.0) {
		color = vec3(1.0, 0.6, 0.3); // Red giant
	} else if (temp < 5000.0) {
		color = vec3(1.0, 0.8, 0.6); // Orange
	} else if (temp < 6500.0) {
		color = vec3(1.0, 0.95, 0.85); // Yellow-white
	} else if (temp < 10000.0) {
		color = vec3(0.85, 0.9, 1.0); // White-blue
	} else {
		color = vec3(0.7, 0.8, 1.0); // Blue
	}
	
	return color;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	view_dir = normalize(CAMERA_POSITION_WORLD - world_pos);
}

void fragment() {
	float time = TIME * time_scale;
	
	// Star surface turbulence
	vec3 normal = normalize(NORMAL);
	float turbulence = sin(world_pos.x * 10.0 + time) * 
					  cos(world_pos.y * 10.0 - time * 0.7) * 
					  sin(world_pos.z * 10.0 + time * 1.3);
	turbulence = turbulence * 0.1 + 0.9;
	
	// Core color based on temperature
	vec3 star_color = planck_color(temperature);
	
	// Corona effect
	float rim = 1.0 - dot(normal, view_dir);
	rim = pow(rim, 2.0);
	
	// Combine effects
	vec3 final_color = star_color * turbulence * luminosity;
	final_color += star_color * rim * corona_size;
	
	// Solar flares (random bright spots)
	float flare = sin(world_pos.x * 50.0 + time * 5.0) * 
				  sin(world_pos.y * 50.0 - time * 3.0);
	flare = max(0.0, flare - 0.9) * 10.0;
	final_color += vec3(1.0, 0.9, 0.7) * flare;
	
	ALBEDO = final_color;
	EMISSION = final_color * 2.0;
}
"""

func get_black_hole_shader_code() -> String:
	# NOTE: Returns shader code for black hole rendering with gravitational lensing
	return """
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float event_horizon_radius = 10.0;
uniform float accretion_disk_radius = 50.0;
uniform float time_scale = 1.0;
uniform sampler2D screen_texture : hint_screen_texture;

varying vec3 world_pos;
varying vec3 view_dir;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	view_dir = normalize(CAMERA_POSITION_WORLD - world_pos);
}

void fragment() {
	float time = TIME * time_scale;
	vec3 normal = normalize(NORMAL);
	
	// Distance from center
	float dist = length(world_pos);
	
	// Event horizon (complete black)
	if (dist < event_horizon_radius) {
		ALBEDO = vec3(0.0);
		ALPHA = 1.0;
		return;
	}
	
	// Gravitational lensing effect
	vec2 screen_uv = SCREEN_UV;
	float lens_strength = event_horizon_radius / dist;
	lens_strength = pow(lens_strength, 2.0);
	
	// Distort space around black hole
	vec2 center = vec2(0.5);
	vec2 offset = screen_uv - center;
	float offset_dist = length(offset);
	vec2 distorted_uv = center + offset * (1.0 + lens_strength * offset_dist);
	
	// Accretion disk
	if (dist < accretion_disk_radius) {
		float disk_intensity = 1.0 - (dist - event_horizon_radius) / 
							  (accretion_disk_radius - event_horizon_radius);
		disk_intensity = pow(disk_intensity, 2.0);
		
		// Swirling pattern
		float angle = atan(world_pos.z, world_pos.x);
		float swirl = sin(angle * 5.0 - time * 2.0 + dist * 0.1) * 0.5 + 0.5;
		
		vec3 disk_color = mix(vec3(1.0, 0.3, 0.1), vec3(1.0, 1.0, 0.3), swirl);
		disk_color *= disk_intensity;
		
		ALBEDO = disk_color;
		EMISSION = disk_color * 3.0;
	} else {
		// Background distortion
		vec3 background = texture(screen_texture, distorted_uv).rgb;
		ALBEDO = background;
	}
}
"""

# === SAVE/LOAD SYSTEM ===

func save_universe(filepath: String):
	# NOTE: Save current universe state
	var save_data = {
		"version": "1.0",
		"time": universe_time,
		"bodies": []
	}
	
	for body in celestial_bodies:
		save_data.bodies.append({
			"name": body.name,
			"type": body.body_type,
			"position": var_to_str(body.position),
			"velocity": var_to_str(body.velocity),
			"mass": body.mass,
			"radius": body.radius,
			"color": var_to_str(body.base_color)
		})
	
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	
	print("Universe saved to: ", filepath)

func load_universe(filepath: String):
	# NOTE: Load universe from file
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file:
		print("Failed to load universe file: ", filepath)
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		print("Failed to parse universe file")
		return
	
	var save_data = json.data
	
	# Clear current universe
	for body in celestial_bodies:
		body.queue_free()
	celestial_bodies.clear()
	
	# Load bodies
	universe_time = save_data.time
	for body_data in save_data.bodies:
		var body = _create_celestial_body(
			body_data.type,
			str_to_var(body_data.position),
			str_to_var(body_data.velocity),
			body_data.radius,
			body_data.mass
		)
		body.name = body_data.name
		body.base_color = str_to_var(body_data.color)
	
	print("Universe loaded from: ", filepath)
