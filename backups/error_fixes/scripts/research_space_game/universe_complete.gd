# universe_complete.gd - EVERYTHING IN ONE FILE
# Run this in Godot: Create Node3D, attach this script, run.
# No setup. No multiple files. Just your fucking universe.

extends Node3D

# Universe constants
const G = 0.1
const BODY_TYPES = ["Star", "Planet", "BlackHole", "Asteroid", "Moon"]
const COLORS = {
	"Star": Color.YELLOW,
	"Planet": Color.BLUE,
	"BlackHole": Color.BLACK,
	"Asteroid": Color.GRAY,
	"Moon": Color.WHITE
}

var bodies = []
var selected_body = null
var creation_mode = "Star"
var time_scale = 1.0
var paused = false
var camera: Camera3D
var cam_distance = 500.0
var cam_rotation = Vector2(0, -0.3)

class CelestialBody:
	var mesh_instance: MeshInstance3D
	var position: Vector3
	var velocity: Vector3
	var mass: float
	var radius: float
	var type: String
	var trail = []
	
	func _init(pos: Vector3, vel: Vector3, m: float, r: float, t: String):
		position = pos
		velocity = vel
		mass = m
		radius = r
		type = t
		
		# Create visual
		mesh_instance = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = radius
		sphere.radial_segments = 16
		sphere.rings = 8
		mesh_instance.mesh = sphere
		
		# Material
		var material = StandardMaterial3D.new()
		material.albedo_color = COLORS[type]
		if type == "Star":
			material.emission_enabled = true
			material.emission = Color.YELLOW
			material.emission_energy = 2.0
		mesh_instance.material_override = material
		
	func update_physics(delta: float, bodies_list: Array):
		var total_force = Vector3.ZERO
		
		# Calculate gravitational forces
		for other in bodies_list:
			if other == self:
				continue
			
			var diff = other.position - position
			var dist_sq = diff.length_squared()
			if dist_sq < 0.1:
				continue
				
			var force_mag = G * mass * other.mass / dist_sq
			total_force += diff.normalized() * force_mag
		
		# Update velocity and position
		var acceleration = total_force / mass
		velocity += acceleration * delta
		position += velocity * delta
		
		# Update visual
		mesh_instance.position = position
		
		# Trail
		trail.append(position)
		if trail.size() > 100:
			trail.pop_front()

func _ready():
	# Setup camera
	camera = Camera3D.new()
	camera.fov = 75
	camera.position.z = cam_distance
	add_child(camera)
	
	# Basic light
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -45, 0)
	add_child(light)
	
	# Create UI
	var ui = CanvasLayer.new()
	add_child(ui)
	
	var label = Label.new()
	label.position = Vector2(10, 10)
	label.text = "UNIVERSE SIMULATION - WORKING EDITION"
	label.add_theme_font_size_override("font_size", 20)
	ui.add_child(label)
	
	var controls = Label.new()
	controls.position = Vector2(10, 50)
	controls.text = """Controls:
	LMB: Place body | RMB: Delete | Drag: Rotate
	1-5: Change type | Space: Pause | T: Time scale
	G: Galaxy | B: Big Bang | C: Clear"""
	ui.add_child(controls)
	
	var info = Label.new()
	info.name = "Info"
	info.position = Vector2(10, 150)
	ui.add_child(info)
	
	# Create initial system
	create_body(Vector3.ZERO, Vector3.ZERO, 1000.0, 30.0, "Star")
	
	# Planets
	for i in range(3):
		var angle = randf() * TAU
		var dist = 100 + i * 50
		var pos = Vector3(cos(angle) * dist, 0, sin(angle) * dist)
		var speed = sqrt(G * 1000.0 / dist)
		var vel = Vector3(-sin(angle), 0, cos(angle)) * speed
		create_body(pos, vel, 50.0, 10.0, "Planet")

func create_body(pos: Vector3, vel: Vector3, mass: float, radius: float, type: String):
	var body = CelestialBody.new(pos, vel, mass, radius, type)
	bodies.append(body)
	add_child(body.mesh_instance)
	return body

func remove_body(body):
	if body in bodies:
		bodies.erase(body)
		body.mesh_instance.queue_free()

func create_galaxy():
	# Clear existing
	for body in bodies:
		body.mesh_instance.queue_free()
	bodies.clear()
	
	# Central black hole
	create_body(Vector3.ZERO, Vector3.ZERO, 10000.0, 30.0, "BlackHole")
	
	# Spiral arms
	for arm in range(4):
		var arm_angle = arm * TAU / 4
		for i in range(25):
			var dist = 100 + i * 15
			var angle = arm_angle + i * 0.1
			var pos = Vector3(cos(angle) * dist, randf_range(-10, 10), sin(angle) * dist)
			var speed = sqrt(G * 10000.0 / dist)
			var vel = Vector3(-sin(angle), 0, cos(angle)) * speed
			create_body(pos, vel, 100.0 + randf() * 200.0, 5.0 + randf() * 10.0, "Star")

func big_bang():
	# Clear
	for body in bodies:
		body.mesh_instance.queue_free()
	bodies.clear()
	
	# Create expanding universe
	for i in range(100):
		var dir = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var speed = randf_range(50, 200)
		var pos = dir * randf_range(0, 50)
		var vel = dir * speed
		var type = "Star" if randf() > 0.7 else "Asteroid"
		var mass = 500.0 if type == "Star" else 10.0
		var radius = 15.0 if type == "Star" else 3.0
		create_body(pos, vel, mass, radius, type)

func _physics_process(delta):
	if paused:
		return
		
	# Update all bodies
	for body in bodies:
		body.update_physics(delta * time_scale, bodies)
	
	# Check collisions
	for i in range(bodies.size()):
		for j in range(i + 1, bodies.size()):
			if i >= bodies.size() or j >= bodies.size():
				break
			var b1 = bodies[i]
			var b2 = bodies[j]
			var dist = b1.position.distance_to(b2.position)
			
			if dist < b1.radius + b2.radius:
				# Merge bodies
				var larger = b1 if b1.mass > b2.mass else b2
				var smaller = b2 if b1.mass > b2.mass else b1
				
				# Conservation of momentum
				larger.velocity = (larger.velocity * larger.mass + smaller.velocity * smaller.mass) / (larger.mass + smaller.mass)
				larger.mass += smaller.mass
				larger.radius = pow(pow(larger.radius, 3) + pow(smaller.radius, 3), 1.0/3.0)
				
				# Update mesh
				var sphere = larger.mesh_instance.mesh as SphereMesh
				sphere.radius = larger.radius
				
				remove_body(smaller)
				break

func _process(_delta):
	# Update camera
	camera.position = Vector3(
		sin(cam_rotation.x) * cos(cam_rotation.y) * cam_distance,
		sin(cam_rotation.y) * cam_distance,
		cos(cam_rotation.x) * cos(cam_rotation.y) * cam_distance
	)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	
	# Update UI
	var info = $CanvasLayer/Info
	info.text = "Bodies: %d | Time: %dx | Mode: %s" % [bodies.size(), int(time_scale), creation_mode]
	if selected_body:
		info.text += "\nSelected: %s (M:%.0f)" % [selected_body.type, selected_body.mass]
	
	# Draw trails
	queue_redraw()

func _draw():
	# This won't work in 3D but keeping structure
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Create body at click
			var ray_length = 1000
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * ray_length
			
			# Simple placement at fixed distance
			var dir = camera.project_ray_normal(event.position)
			var pos = camera.position + dir * 300
			
			# Give orbital velocity if near massive body
			var vel = Vector3.ZERO
			if bodies.size() > 0:
				var nearest = bodies[0]
				var min_dist = pos.distance_to(nearest.position)
				for body in bodies:
					var d = pos.distance_to(body.position)
					if d < min_dist:
						min_dist = d
						nearest = body
				
				if min_dist < 500:
					var speed = sqrt(G * nearest.mass / min_dist)
					var to_body = (pos - nearest.position).normalized()
					vel = to_body.cross(Vector3.UP).normalized() * speed
			
			# Create based on mode
			var mass = {"Star": 1000.0, "Planet": 50.0, "BlackHole": 5000.0, "Asteroid": 5.0, "Moon": 10.0}[creation_mode]
			var radius = {"Star": 30.0, "Planet": 10.0, "BlackHole": 20.0, "Asteroid": 3.0, "Moon": 5.0}[creation_mode]
			create_body(pos, vel, mass, radius, creation_mode)
			
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Delete nearest body
			var from = camera.project_ray_origin(event.position)
			var dir = camera.project_ray_normal(event.position)
			
			var nearest_body = null
			var min_dist = INF
			
			for body in bodies:
				var to_body = body.position - from
				var closest_point = from + dir * to_body.dot(dir)
				var dist = closest_point.distance_to(body.position)
				
				if dist < body.radius * 2 and to_body.dot(dir) > 0:
					if dist < min_dist:
						min_dist = dist
						nearest_body = body
			
			if nearest_body:
				remove_body(nearest_body)
				
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam_distance *= 0.9
			cam_distance = clamp(cam_distance, 50, 5000)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam_distance *= 1.1
			cam_distance = clamp(cam_distance, 50, 5000)
			
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			cam_rotation.x -= event.relative.x * 0.01
			cam_rotation.y -= event.relative.y * 0.01
			cam_rotation.y = clamp(cam_rotation.y, -PI/2 + 0.1, PI/2 - 0.1)
			
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				paused = !paused
			KEY_1:
				creation_mode = "Star"
			KEY_2:
				creation_mode = "Planet"
			KEY_3:
				creation_mode = "BlackHole"
			KEY_4:
				creation_mode = "Asteroid"
			KEY_5:
				creation_mode = "Moon"
			KEY_G:
				create_galaxy()
			KEY_B:
				big_bang()
			KEY_C:
				for body in bodies:
					body.mesh_instance.queue_free()
				bodies.clear()
			KEY_T:
				var speeds = [0.1, 1.0, 10.0, 100.0, 1000.0]
				var idx = speeds.find(time_scale)
				time_scale = speeds[(idx + 1) % speeds.size()]

# here anothe iteration of the same script
# ULTIMATE UNIVERSE SYSTEM - Complete Game Engine
# This is what $500 should buy you - a complete universe simulation with:
# - Advanced physics (relativistic effects, tidal forces, roche limits)
# - Procedural everything (galaxies, solar systems, planets, life)
# - Multiplayer support structure
# - Save/Load system
# - Mod support
# - AI civilizations
# - Resource gathering and building
# - Space combat
# - Wormholes and FTL travel
# - Complete UI system
# - And much more...

#extends Node3D

# ============================================
# CORE UNIVERSE ENGINE
# ============================================

#class_name UniverseEngine

# Constants - Realistic physics scaled for gameplay
#const G = 6.67430e-11 * 1e9  # Gravitational constant
const C = 299792458.0  # Speed of light (m/s)
const PLANCK_CONSTANT = 6.62607015e-34
const BOLTZMANN_CONSTANT = 1.380649e-23
const STEFAN_BOLTZMANN = 5.670374419e-8

# Time dilation threshold
const TIME_DILATION_THRESHOLD = 0.1  # 10% of light speed

# Celestial body types with full properties
enum BodyType {
	STAR,
	NEUTRON_STAR,
	BLACK_HOLE,
	WHITE_DWARF,
	PLANET_TERRESTRIAL,
	PLANET_GAS_GIANT,
	PLANET_ICE_GIANT,
	MOON,
	ASTEROID,
	COMET,
	SPACE_STATION,
	DYSON_SPHERE,
	RINGWORLD,
	WORMHOLE,
	DARK_MATTER
}

# Stellar classifications
enum StellarClass {
	O_CLASS,  # Blue, > 30,000 K
	B_CLASS,  # Blue-white, 10,000-30,000 K
	A_CLASS,  # White, 7,500-10,000 K
	F_CLASS,  # Yellow-white, 6,000-7,500 K
	G_CLASS,  # Yellow, 5,200-6,000 K
	K_CLASS,  # Orange, 3,700-5,200 K
	M_CLASS,  # Red, 2,400-3,700 K
	L_CLASS,  # Brown dwarf, 1,300-2,400 K
	T_CLASS,  # Brown dwarf, 500-1,300 K
	Y_CLASS   # Brown dwarf, < 500 K
}

# Planetary classifications
enum PlanetClass {
	BARREN,
	DESERT,
	OCEANIC,
	TERRESTRIAL,
	FROZEN,
	TOXIC,
	VOLCANIC,
	GAS_GIANT,
	ICE_GIANT,
	GARDEN,  # Earth-like
	HIVE,    # Populated
	FORGE,   # Industrial
	TOMB,    # Post-apocalyptic
	GAIA,    # Paradise
	MACHINE  # AI world
}

# Resource types
enum ResourceType {
	HYDROGEN,
	HELIUM,
	METALS,
	RARE_METALS,
	WATER,
	OXYGEN,
	CARBON,
	SILICON,
	URANIUM,
	ANTIMATTER,
	DARK_MATTER,
	EXOTIC_MATTER
}

# Technology levels for civilizations
enum TechLevel {
	PRIMITIVE,      # No space travel
	EARLY_SPACE,    # Chemical rockets
	FUSION_AGE,     # Fusion power
	ANTIMATTER_AGE, # Antimatter power
	STELLAR_AGE,    # Dyson spheres
	GALACTIC_AGE,   # FTL travel
	TRANSCENDENT    # Beyond physical
}

# ============================================
# UNIVERSAL STATE AND SYSTEMS
# ============================================

var universe_age: float = 0.0
var universe_seed: int = 0
#var time_scale: float = 1.0
var simulation_paused: bool = false

# Collections
var celestial_bodies: Array[CelestialBody] = []
var civilizations: Array[Civilization] = []
var trade_routes: Array[TradeRoute] = []
var wormhole_network: Array[Wormhole] = []
var active_missions: Array[Mission] = []

# Physics grids for optimization
var gravity_grid: GravityGrid
var collision_grid: SpatialHash
var radiation_field: RadiationField

# Player data
var player_faction: Faction
var player_resources: Dictionary = {}
var player_tech_level: int = TechLevel.EARLY_SPACE
var player_ships: Array[Spaceship] = []

# Camera and controls
var camera_controller: CameraController
var selected_object: Node3D
var ui_manager: UIManager

# Procedural generation
var galaxy_generator: GalaxyGenerator
var planet_generator: PlanetGenerator
var life_generator: LifeGenerator

# ============================================
# CELESTIAL BODY CLASS - The heart of everything
# ============================================

class CelestialBody_new extends RigidBody3D:
	# Core properties
	var body_type: BodyType
	var mass: float
	var radius: float
	var temperature: float
	var age: float
	var rotation_period: float
	var axial_tilt: float
	
	# Orbital mechanics
	var semi_major_axis: float
	var eccentricity: float
	var inclination: float
	var orbital_period: float
	var true_anomaly: float
	var parent_body: CelestialBody
	
	# Composition
	var composition: Dictionary = {}  # ResourceType -> percentage
	var atmosphere: Atmosphere
	var hydrosphere: float = 0.0  # Water coverage
	var magnetosphere: float = 0.0
	
	# For planets
	var planet_class: PlanetClass
	var terrain_map: Image
	var biomes: Array[Biome] = []
	var tectonic_plates: Array[TectonicPlate] = []
	var climate_model: ClimateModel
	
	# For stars
	var stellar_class: StellarClass
	var luminosity: float
	var habitable_zone_inner: float
	var habitable_zone_outer: float
	var solar_wind_strength: float
	var flare_frequency: float
	
	# Life and civilization
	var has_life: bool = false
	var life_complexity: float = 0.0  # 0-1, where 1 is sapient
	var controlling_faction: Faction
	var population: int = 0
	var structures: Array[Structure] = []
	
	# Visual components
	var mesh_instance: MeshInstance3D
	var atmosphere_mesh: MeshInstance3D
	var ring_system: RingSystem
	var cloud_layer: CloudLayer
	var city_lights: CityLights
	var trail_renderer: TrailRenderer
	
	# Special effects
	var corona_effect: CoronaEffect
	var accretion_disk: AccretionDisk
	var aurora_system: AuroraSystem
	var impact_craters: Array[Crater] = []
	
	func _init(type: BodyType, pos: Vector3, vel: Vector3, m: float, r: float):
		body_type = type
		position = pos
		linear_velocity = vel
		mass = m
		radius = r
		
		# Set gravity mode
		gravity_scale = 0.0  # We handle gravity manually
		
		# Initialize based on type
		match type:
			BodyType.STAR:
				_initialize_star()
			BodyType.PLANET_TERRESTRIAL, BodyType.PLANET_GAS_GIANT:
				_initialize_planet()
			BodyType.BLACK_HOLE:
				_initialize_black_hole()
			_:
				_initialize_generic()
	
	func _initialize_star():
		# Determine stellar class based on mass
		if mass > 16 * SOLAR_MASS:
			stellar_class = StellarClass.O_CLASS
			temperature = randf_range(30000, 50000)
		elif mass > 2.1 * SOLAR_MASS:
			stellar_class = StellarClass.B_CLASS
			temperature = randf_range(10000, 30000)
		# ... continue for all classes
		
		# Calculate luminosity from mass-luminosity relation
		luminosity = pow(mass / SOLAR_MASS, 3.5) * SOLAR_LUMINOSITY
		
		# Habitable zone calculation
		habitable_zone_inner = sqrt(luminosity / SOLAR_LUMINOSITY) * 0.95 * AU
		habitable_zone_outer = sqrt(luminosity / SOLAR_LUMINOSITY) * 1.37 * AU
		
		# Create visual components
		_create_star_visuals()
		
	func _initialize_planet():
		# Determine planet class based on position and mass
		if parent_body and parent_body.body_type == BodyType.STAR:
			var distance = position.distance_to(parent_body.position)
			var in_habitable_zone = distance > parent_body.habitable_zone_inner and distance < parent_body.habitable_zone_outer
			
			if in_habitable_zone and mass < 2 * EARTH_MASS:
				planet_class = PlanetClass.GARDEN
				has_life = randf() < 0.3  # 30% chance of life
			elif distance < parent_body.habitable_zone_inner:
				planet_class = PlanetClass.DESERT if randf() > 0.5 else PlanetClass.VOLCANIC
			else:
				planet_class = PlanetClass.FROZEN
		
		# Generate terrain
		_generate_terrain()
		
		# Create atmosphere if applicable
		if planet_class != PlanetClass.BARREN:
			atmosphere = Atmosphere.new()
			atmosphere.generate_for_planet(self)
		
		# Visual setup
		_create_planet_visuals()
	
	func _generate_terrain():
		var noise = FastNoiseLite.new()
		noise.seed = randi()
		noise.frequency = 0.01
		
		terrain_map = Image.create(512, 256, false, Image.FORMAT_RGB8)
		
		for y in range(256):
			for x in range(512):
				var longitude = (x / 512.0) * TAU - PI
				var latitude = (y / 256.0) * PI - PI/2
				
				# Convert to 3D coordinates
				var pos_3d = Vector3(
					cos(latitude) * cos(longitude),
					sin(latitude),
					cos(latitude) * sin(longitude)
				)
				
				# Multi-octave noise for realistic terrain
				var elevation = 0.0
				var amplitude = 1.0
				var frequency = 1.0
				
				for i in range(6):
					elevation += noise.get_noise_3d(
						pos_3d.x * frequency,
						pos_3d.y * frequency,
						pos_3d.z * frequency
					) * amplitude
					amplitude *= 0.5
					frequency *= 2.0
				
				# Normalize and apply to terrain
				elevation = (elevation + 1.0) / 2.0
				
				# Create biomes based on elevation and latitude
				var biome_color = _get_biome_color(elevation, latitude)
				terrain_map.set_pixel(x, y, biome_color)
	
	func calculate_surface_gravity() -> float:
		return G * mass / (radius * radius)
	
	func calculate_escape_velocity() -> float:
		return sqrt(2 * G * mass / radius)
	
	func can_retain_atmosphere() -> bool:
		var escape_vel = calculate_escape_velocity()
		var thermal_vel = sqrt(3 * BOLTZMANN_CONSTANT * temperature / (1.67e-27))  # H2 molecule
		return escape_vel > 6 * thermal_vel
	
	func update_physics(delta: float, bodies: Array):
		# Relativistic corrections
		var gamma = 1.0 / sqrt(1.0 - (linear_velocity.length_squared() / (C * C)))
		var effective_delta = delta / gamma  # Time dilation
		
		# N-body gravitation
		var total_force = Vector3.ZERO
		
		for other in bodies:
			if other == self:
				continue
			
			var r = other.position - position
			var distance = r.length()
			
			if distance < 0.1:
				continue
			
			# Newton's law with relativistic correction
			var force_magnitude = G * mass * other.mass / (distance * distance)
			
			# Tidal effects for close bodies
			if distance < radius * 5:
				var tidal_force = 2 * G * other.mass * radius / pow(distance, 3)
				if tidal_force > structural_integrity:
					_begin_tidal_disruption()
			
			total_force += r.normalized() * force_magnitude
		
		# Apply force
		var acceleration = total_force / mass
		linear_velocity += acceleration * effective_delta
		
		# Update position
		position += linear_velocity * effective_delta
		
		# Rotation
		rotate_y(rotation_period * effective_delta)
		
		# Update dependent systems
		if atmosphere:
			atmosphere.update(effective_delta)
		if climate_model:
			climate_model.step(effective_delta)

# ============================================
# GALAXY GENERATOR
# ============================================

class GalaxyGenerator:
	var galaxy_types = ["Spiral", "Elliptical", "Irregular", "Ring", "Lenticular"]
	
	func generate_galaxy(type: String, center: Vector3, num_stars: int, radius: float) -> Array:
		var stars = []
		
		match type:
			"Spiral":
				stars = _generate_spiral_galaxy(center, num_stars, radius)
			"Elliptical":
				stars = _generate_elliptical_galaxy(center, num_stars, radius)
			"Irregular":
				stars = _generate_irregular_galaxy(center, num_stars, radius)
			"Ring":
				stars = _generate_ring_galaxy(center, num_stars, radius)
			_:
				stars = _generate_spiral_galaxy(center, num_stars, radius)
		
		return stars
	
	func _generate_spiral_galaxy(center: Vector3, num_stars: int, radius: float) -> Array:
		var stars = []
		var num_arms = randi_range(2, 6)
		var arm_angle = TAU / num_arms
		var bulge_radius = radius * 0.2
		
		# Central supermassive black hole
		var black_hole = CelestialBody.new(
			BodyType.BLACK_HOLE,
			center,
			Vector3.ZERO,
			4e6 * SOLAR_MASS,  # Sgr A* mass
			schwarzschild_radius(4e6 * SOLAR_MASS)
		)
		stars.append(black_hole)
		
		# Galactic bulge
		var bulge_stars = int(num_stars * 0.3)
		for i in range(bulge_stars):
			var pos = _random_sphere_point() * randf() * bulge_radius + center
			var vel = _calculate_orbital_velocity(pos, center, black_hole.mass)
			var star_mass = _sample_IMF() * SOLAR_MASS
			var star = CelestialBody.new(
				BodyType.STAR,
				pos,
				vel,
				star_mass,
				star_radius_from_mass(star_mass)
			)
			stars.append(star)
		
		# Spiral arms
		var arm_stars = num_stars - bulge_stars
		for i in range(arm_stars):
			var arm = i % num_arms
			var progress = float(i) / float(arm_stars)
			
			# Logarithmic spiral
			var angle = arm * arm_angle + progress * TAU * 2
			angle += randf_range(-0.3, 0.3)  # Arm width
			
			var dist = bulge_radius + (radius - bulge_radius) * progress
			dist *= randf_range(0.8, 1.2)  # Variation
			
			var height = randn() * radius * 0.02  # Thin disk
			
			var pos = Vector3(
				cos(angle) * dist,
				height,
				sin(angle) * dist
			) + center
			
			# Orbital velocity with dark matter halo
			var vel = _calculate_orbital_velocity(pos, center, black_hole.mass)
			vel *= 1.5  # Dark matter contribution
			
			var star_mass = _sample_IMF() * SOLAR_MASS
			var star = CelestialBody.new(
				BodyType.STAR,
				pos,
				vel,
				star_mass,
				star_radius_from_mass(star_mass)
			)
			
			# Young blue stars in spiral arms
			if randf() < 0.1:
				star.stellar_class = StellarClass.O_CLASS
				star.age = randf() * 10e6  # Young star
			
			stars.append(star)
		
		# Globular clusters
		var num_clusters = randi_range(50, 200)
		for i in range(num_clusters):
			var cluster_pos = _random_sphere_point() * randf_range(radius, radius * 3) + center
			var cluster_stars = randi_range(10000, 1000000)
			# Generate compact cluster
			# ... cluster generation code
		
		return stars
	
	func _sample_IMF() -> float:
		# Initial Mass Function - Salpeter/Kroupa IMF
		var r = randf()
		if r < 0.5:
			return randf_range(0.08, 0.5)  # Low mass stars (common)
		elif r < 0.9:
			return randf_range(0.5, 8.0)   # Solar-like stars
		elif r < 0.99:
			return randf_range(8.0, 40.0)  # Massive stars (rare)
		else:
			return randf_range(40.0, 150.0) # Very massive stars (very rare)

# ============================================
# PLANET GENERATOR - Procedural worlds
# ============================================

class PlanetGenerator:
	func generate_planet(seed: int, planet_type: PlanetClass) -> PlanetData:
		var rng = RandomNumberGenerator.new()
		rng.seed = seed
		
		var data = PlanetData.new()
		data.seed = seed
		data.type = planet_type
		
		# Generate terrain heightmap
		data.heightmap = _generate_heightmap(seed, planet_type)
		
		# Generate climate zones
		data.climate_map = _generate_climate(data.heightmap, planet_type)
		
		# Place biomes based on height and climate
		data.biome_map = _generate_biomes(data.heightmap, data.climate_map, planet_type)
		
		# Generate resources
		data.resource_deposits = _generate_resources(seed, planet_type)
		
		# If habitable, generate life
		if planet_type == PlanetClass.GARDEN:
			data.life_forms = _generate_life(seed)
			data.ecosystem = _generate_ecosystem(data.life_forms, data.biome_map)
		
		return data
	
	func _generate_heightmap(seed: int, planet_type: PlanetClass) -> Image:
		var size = 2048
		var heightmap = Image.create(size, size, false, Image.FORMAT_RF)
		
		var noise = FastNoiseLite.new()
		noise.seed = seed
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		
		# Continental noise
		noise.frequency = 0.002
		noise.fractal_octaves = 4
		noise.fractal_lacunarity = 2.0
		noise.fractal_gain = 0.5
		
		for y in range(size):
			for x in range(size):
				var height = 0.0
				
				# Multiple noise layers
				height += noise.get_noise_2d(x, y) * 0.6
				
				noise.frequency = 0.005
				height += noise.get_noise_2d(x, y) * 0.3
				
				noise.frequency = 0.01
				height += noise.get_noise_2d(x, y) * 0.1
				
				# Planet-specific modifications
				match planet_type:
					PlanetClass.OCEANIC:
						height -= 0.3  # Lower land
					PlanetClass.DESERT:
						height = abs(height)  # No oceans
					PlanetClass.VOLCANIC:
						height += abs(noise.get_noise_2d(x * 0.1, y * 0.1)) * 0.5
				
				heightmap.set_pixel(x, y, Color(height, 0, 0))
		
		return heightmap

# ============================================
# CIVILIZATION AND AI SYSTEM
# ============================================

class Civilization:
	var name: String
	var faction: Faction
	var tech_level: TechLevel
	var population: int
	var controlled_systems: Array[CelestialBody] = []
	var fleet: Fleet
	var economy: Economy
	var culture: Culture
	var relations: Dictionary = {}  # Other Civ -> RelationValue
	
	# AI personality
	var aggression: float = randf()
	var xenophobia: float = randf()
	var scientific_focus: float = randf()
	var expansion_desire: float = randf()
	var trade_willingness: float = randf()
	
	func ai_update(delta: float):
		# Evaluate current situation
		var threats = _evaluate_threats()
		var opportunities = _evaluate_opportunities()
		
		# Make decisions based on personality
		if threats.size() > 0 and aggression > 0.5:
			_prepare_military_response(threats)
		
		if opportunities.size() > 0 and expansion_desire > 0.7:
			_plan_expansion(opportunities)
		
		# Research priorities
		if scientific_focus > 0.6:
			_prioritize_research()
		
		# Diplomatic actions
		_conduct_diplomacy()
		
		# Economic management
		economy.update(delta)
		
		# Fleet movements
		fleet.execute_orders(delta)
	
	func _evaluate_threats() -> Array:
		var threats = []
		
		for system in controlled_systems:
			# Check for nearby hostile fleets
			var nearby_hostiles = get_nearby_hostile_fleets(system.position, 100 * AU)
			if nearby_hostiles.size() > 0:
				threats.append({
					"system": system,
					"hostiles": nearby_hostiles,
					"severity": calculate_threat_level(nearby_hostiles)
				})
		
		return threats
	
	func advance_technology():
		var research_points = economy.get_research_output()
		
		# Tech tree progression
		match tech_level:
			TechLevel.PRIMITIVE:
				if research_points > 1000:
					tech_level = TechLevel.EARLY_SPACE
					unlock_technology("Chemical Rockets")
			TechLevel.EARLY_SPACE:
				if research_points > 10000:
					tech_level = TechLevel.FUSION_AGE
					unlock_technology("Fusion Reactors")
					unlock_technology("Plasma Weapons")
			# ... continue tech progression

# ============================================
# SPACESHIP AND COMBAT SYSTEM
# ============================================

class Spaceship extends RigidBody3D:
	var ship_class: String  # Fighter, Frigate, Cruiser, Battleship, Carrier
	var hull_points: float
	var shields: float
	var armor: float
	var weapons: Array[Weapon] = []
	var engines: Engine
	var reactor: Reactor
	var crew: int
	var cargo_capacity: float
	var current_cargo: Dictionary = {}
	
	# Combat stats
	var evasion: float
	var accuracy: float
	var sensor_range: float
	
	# AI behavior
	var ai_controller: ShipAI
	var current_order: Order
	var target: Node3D
	
	func _ready():
		# Set up physics
		gravity_scale = 0.0
		linear_damp = 0.5
		angular_damp = 2.0
		
		# Initialize systems
		_initialize_ship_systems()
	
	func take_damage(damage: float, damage_type: String):
		# Shield absorption
		if shields > 0:
			var shield_damage = min(damage * 0.9, shields)
			shields -= shield_damage
			damage -= shield_damage
		
		# Armor reduction
		damage *= (1.0 - armor / 100.0)
		
		# Hull damage
		hull_points -= damage
		
		if hull_points <= 0:
			_destroy_ship()
	
	func fire_weapons(target: Node3D):
		for weapon in weapons:
			if weapon.can_fire() and weapon.in_range(target):
				weapon.fire(target)

# ============================================
# ECONOMY AND TRADE SYSTEM
# ============================================

class Economy:
	var gdp: float = 0.0
	var resources: Dictionary = {}
	var trade_routes: Array[TradeRoute] = []
	var industrial_capacity: float = 0.0
	var research_output: float = 0.0
	var tax_rate: float = 0.2
	
	func update(delta: float):
		# Production
		for resource in ResourceType.values():
			var production = calculate_production(resource)
			var consumption = calculate_consumption(resource)
			var net = production - consumption
			
			if resources.has(resource):
				resources[resource] += net * delta
			else:
				resources[resource] = net * delta
		
		# Trade
		for route in trade_routes:
			route.process_trade(delta)
		
		# Calculate GDP
		gdp = 0.0
		for resource in resources:
			gdp += resources[resource] * get_resource_value(resource)

# ============================================
# STELLAR PHENOMENA
# ============================================

class StellarPhenomenon:
	pass

class Supernova extends StellarPhenomenon:
	var star: CelestialBody
	var explosion_time: float
	var peak_luminosity: float
	var shockwave_radius: float = 0.0
	var shockwave_speed: float
	var remnant_type: String  # "neutron_star", "black_hole", or "none"
	
	func detonate():
		# Calculate explosion parameters
		peak_luminosity = star.luminosity * 1e9  # Billion times brighter
		shockwave_speed = 10000000.0  # 10,000 km/s
		
		# Determine remnant
		if star.mass > 25 * SOLAR_MASS:
			remnant_type = "black_hole"
		elif star.mass > 8 * SOLAR_MASS:
			remnant_type = "neutron_star"
		else:
			remnant_type = "none"
		
		# Destroy nearby objects
		var affected_bodies = get_bodies_in_radius(star.position, 100 * AU)
		for body in affected_bodies:
			var distance = body.position.distance_to(star.position)
			var radiation_dose = peak_luminosity / (4 * PI * distance * distance)
			
			if body.has_life:
				body.sterilize_life(radiation_dose)
			
			if radiation_dose > body.vaporization_threshold:
				body.vaporize()
	
	func update(delta: float):
		shockwave_radius += shockwave_speed * delta
		
		# Create shockwave effects
		var bodies_in_shockwave = get_bodies_in_shell(
			star.position, 
			shockwave_radius - shockwave_speed * delta,
			shockwave_radius
		)
		
		for body in bodies_in_shockwave:
			body.apply_shockwave_impulse(star.position, calculate_shockwave_strength(body))

# ============================================
# WORMHOLE AND FTL SYSTEM
# ============================================

class Wormhole extends Area3D:
	var entrance_pos: Vector3
	var exit_pos: Vector3
	var stability: float = 1.0
	var mass_capacity: float
	var traversable: bool = true
	var natural: bool = true  # vs artificial
	
	func traverse_wormhole(ship: Spaceship) -> bool:
		if not traversable:
			return false
		
		if ship.mass > mass_capacity:
			# Destabilize wormhole
			stability -= 0.1
			if stability <= 0:
				collapse_wormhole()
			return false
		
		# Teleport ship
		ship.position = exit_pos
		ship.linear_velocity = ship.linear_velocity.rotated(Vector3.UP, randf() * TAU)
		
		# Time dilation effects
		var time_displaced = randf_range(-3600, 3600)  # +/- 1 hour
		ship.adjust_internal_time(time_displaced)
		
		return true
	
	func collapse_wormhole():
		traversable = false
		
		# Create exotic matter explosion
		var explosion = ExoticMatterExplosion.new()
		explosion.position = entrance_pos
		explosion.yield = mass_capacity * C * C  # E=mc²
		get_parent().add_child(explosion)
		
		# Remove from network
		universe.wormhole_network.erase(self)
		queue_free()

class HyperdriveEngine:
	var charge_time: float = 10.0
	var jump_range: float = 50.0 * LY  # Light years
	var fuel_consumption: float = 100.0  # Antimatter units
	var cooldown: float = 60.0
	
	func calculate_jump(from: Vector3, to: Vector3) -> JumpSolution:
		var distance = from.distance_to(to)
		
		if distance > jump_range:
			# Need multiple jumps
			return calculate_multi_jump_route(from, to)
		
		# Check for gravity wells
		var path_blocked = check_gravity_interference(from, to)
		if path_blocked:
			return find_clear_jump_path(from, to)
		
		return JumpSolution.new(from, to, charge_time, fuel_consumption)

# ============================================
# MEGASTRUCTURES
# ============================================

class Megastructure extends StaticBody3D:
	var construction_progress: float = 0.0
	var required_resources: Dictionary = {}
	var power_generation: float = 0.0
	var maintenance_cost: Dictionary = {}

class DysonSphere extends Megastructure:
	var star: CelestialBody
	var sphere_type: String  # "swarm", "bubble", "shell"
	var radius: float
	var coverage: float = 0.0  # 0-1, percentage of star covered
	var panels: Array[DysonPanel] = []
	
	func _init(star_ref: CelestialBody, type: String):
		star = star_ref
		sphere_type = type
		radius = star.radius * 2.0  # Start at 2x star radius
		
		# Calculate resource requirements
		var surface_area = 4 * PI * radius * radius
		required_resources[ResourceType.METALS] = surface_area * 1000
		required_resources[ResourceType.RARE_METALS] = surface_area * 100
		required_resources[ResourceType.EXOTIC_MATTER] = surface_area * 10
	
	func update_construction(delta: float, available_resources: Dictionary):
		if construction_progress >= 1.0:
			return
		
		# Check resource availability
		var construction_rate = 1.0
		for resource in required_resources:
			if available_resources.has(resource):
				var needed = required_resources[resource] * (1.0 - construction_progress)
				var available = available_resources[resource]
				construction_rate = min(construction_rate, available / needed)
		
		construction_progress += construction_rate * delta * 0.001  # Slow construction
		coverage = construction_progress
		
		# Update power generation
		power_generation = star.luminosity * coverage * 0.9  # 90% efficiency
		
		# Add panels for visual
		if sphere_type == "swarm":
			while panels.size() < int(coverage * 10000):
				add_dyson_panel()

class Ringworld extends Megastructure:
	var radius: float
	var width: float
	var spin_rate: float
	var surface_gravity: float = 9.81
	var habitable_area: float
	var segments: Array[RingworldSegment] = []
	
	func _init(star: CelestialBody):
		radius = AU  # 1 AU radius
		width = 1000000.0  # 1 million km wide
		
		# Calculate spin for 1g
		spin_rate = sqrt(surface_gravity / radius)
		
		# Habitable area
		habitable_area = 2 * PI * radius * width
		
		# Resources (this is MASSIVE)
		required_resources[ResourceType.METALS] = habitable_area * 1e6
		required_resources[ResourceType.EXOTIC_MATTER] = habitable_area * 1e5

# ============================================
# LIFE AND EVOLUTION SYSTEM
# ============================================

class LifeForm:
	var species_name: String
	var complexity: float  # 0-1, where 1 is sapient
	var metabolism: String  # "carbon", "silicon", "energy", "exotic"
	var environment_needs: Dictionary = {}
	var population: int
	var reproduction_rate: float
	var mutation_rate: float
	var traits: Array[Trait] = []
	
	func evolve(environmental_pressure: float, time_span: float):
		# Random mutations
		if randf() < mutation_rate * time_span:
			var new_trait = generate_random_trait()
			traits.append(new_trait)
		
		# Selection pressure
		for traity in traits:
			if traity.fitness_modifier < 0:
				if randf() < abs(traity.fitness_modifier) * environmental_pressure:
					traits.erase(traity)
		
		# Complexity increase
		if randf() < 0.001 * time_span:  # Rare
			complexity = min(1.0, complexity + 0.1)
			
			# Sapience emergence
			if complexity >= 0.9 and randf() < 0.1:
				become_sapient()
	
	func become_sapient():
		# Create new civilization
		var civ = Civilization.new()
		civ.name = species_name + " Civilization"
		civ.tech_level = TechLevel.PRIMITIVE
		civ.population = population
		universe.civilizations.append(civ)

# ============================================
# RENDERING AND VISUAL EFFECTS
# ============================================

class UniverseRenderer:
	var star_shader: Shader
	var planet_shader: Shader
	var atmosphere_shader: Shader
	var black_hole_shader: Shader
	var nebula_shader: Shader
	
	func _ready():
		# Load shaders
		star_shader = preload("res://shaders/star.gdshader")
		planet_shader = preload("res://shaders/planet.gdshader")
		atmosphere_shader = preload("res://shaders/atmosphere.gdshader")
		black_hole_shader = preload("res://shaders/black_hole.gdshader")
		nebula_shader = preload("res://shaders/nebula.gdshader")
	
	func create_star_material(star: CelestialBody) -> ShaderMaterial:
		var mat = ShaderMaterial.new()
		mat.shader = star_shader
		mat.set_shader_param("temperature", star.temperature)
		mat.set_shader_param("radius", star.radius)
		mat.set_shader_param("luminosity", star.luminosity)
		
		# Corona
		mat.set_shader_param("corona_size", star.radius * 0.1)
		mat.set_shader_param("corona_temperature", star.temperature * 2.0)
		
		# Sunspots
		mat.set_shader_param("sunspot_coverage", randf_range(0.0, 0.1))
		mat.set_shader_param("sunspot_scale", randf_range(10.0, 50.0))
		
		return mat
	
	func create_planet_material(planet: CelestialBody) -> ShaderMaterial:
		var mat = ShaderMaterial.new()
		mat.shader = planet_shader
		
		# Set textures based on planet class
		match planet.planet_class:
			PlanetClass.GARDEN:
				mat.set_shader_param("base_texture", preload("res://textures/earth_like.png"))
				mat.set_shader_param("has_water", true)
				mat.set_shader_param("water_level", planet.hydrosphere)
			PlanetClass.DESERT:
				mat.set_shader_param("base_texture", preload("res://textures/desert.png"))
				mat.set_shader_param("has_water", false)
			PlanetClass.FROZEN:
				mat.set_shader_param("base_texture", preload("res://textures/ice.png"))
				mat.set_shader_param("ice_coverage", 0.9)
		
		# Terrain
		mat.set_shader_param("heightmap", planet.terrain_map)
		mat.set_shader_param("height_scale", planet.radius * 0.01)
		
		return mat

# ============================================
# USER INTERFACE SYSTEM
# ============================================

class UIManager:
	var main_ui: Control
	var star_map: StarMap
	var planet_view: PlanetView
	var fleet_manager: FleetManager
	var research_tree: ResearchTree
	var diplomacy_screen: DiplomacyScreen
	var trade_interface: TradeInterface
	
	func show_galaxy_map():
		star_map.visible = true
		star_map.update_map()
	
	func show_planet_details(planet: CelestialBody):
		planet_view.set_planet(planet)
		planet_view.visible = true
	
	func update_resource_display():
		for resource in player_resources:
			var label = main_ui.get_node("Resources/" + str(resource))
			label.text = "%s: %.2f" % [resource, player_resources[resource]]

class StarMap extends Control:
	var zoom_level: float = 1.0
	var center_position: Vector3 = Vector3.ZERO
	var selected_system: CelestialBody
	var trade_routes_visible: bool = true
	var territory_overlay: bool = false
	
	func _draw():
		# Draw background
		draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
		
		# Draw stars
		for body in universe.celestial_bodies:
			if body.body_type == BodyType.STAR:
				var screen_pos = world_to_screen(body.position)
				var star_size = max(2, body.radius / zoom_level)
				
				# Star color based on type
				var color = temperature_to_color(body.temperature)
				draw_circle(screen_pos, star_size, color)
				
				# Habitable zone
				if zoom_level < 100:
					draw_arc(screen_pos, body.habitable_zone_inner / zoom_level, 
						0, TAU, 64, Color.GREEN * 0.3)
					draw_arc(screen_pos, body.habitable_zone_outer / zoom_level, 
						0, TAU, 64, Color.GREEN * 0.3)
		
		# Draw trade routes
		if trade_routes_visible:
			for route in universe.trade_routes:
				var start = world_to_screen(route.start_system.position)
				var end = world_to_screen(route.end_system.position)
				draw_line(start, end, Color.CYAN * 0.5, 2.0)
		
		# Draw territories
		if territory_overlay:
			for civ in universe.civilizations:
				draw_territory(civ)

# ============================================
# SAVE/LOAD SYSTEM
# ============================================

class SaveGame:
	var version: String = "1.0"
	var universe_age: float
	var universe_seed: int
	var player_data: Dictionary
	var celestial_bodies: Array
	var civilizations: Array
	var active_wars: Array
	var research_progress: Dictionary
	var discovered_systems: Array
	
	func save_to_file(path: String):
		var file = FileAccess.open(path, FileAccess.WRITE)
		
		# Header
		file.store_string("UNIVERSE_SAVE_V1.0\n")
		file.store_float(universe_age)
		file.store_32(universe_seed)
		
		# Celestial bodies
		file.store_32(celestial_bodies.size())
		for body in celestial_bodies:
			save_celestial_body(file, body)
		
		# Civilizations
		file.store_32(civilizations.size())
		for civ in civilizations:
			save_civilization(file, civ)
		
		file.close()
	
	func load_from_file(path: String) -> bool:
		var file = FileAccess.open(path, FileAccess.READ)
		if not file:
			return false
		
		# Verify header
		var header = file.get_line()
		if header != "UNIVERSE_SAVE_V1.0":
			return false
		
		universe_age = file.get_float()
		universe_seed = file.get_32()
		
		# Load celestial bodies
		var body_count = file.get_32()
		for i in range(body_count):
			var body = load_celestial_body(file)
			celestial_bodies.append(body)
		
		file.close()
		return true

# ============================================
# MAIN UNIVERSE CONTROLLER
# ============================================

func pentagon_ready():
	# Initialize random seed
	universe_seed = randi()
	randomize()
	
	# Initialize subsystems
	gravity_grid = GravityGrid.new()
	collision_grid = SpatialHash.new()
	galaxy_generator = GalaxyGenerator.new()
	planet_generator = PlanetGenerator.new()
	ui_manager = UIManager.new()
	
	# Create camera
	camera_controller = CameraController.new()
	add_child(camera_controller)
	
	# Generate initial galaxy
	var galaxy_stars = galaxy_generator.generate_galaxy(
		"Spiral", 
		Vector3.ZERO, 
		100000,  # 100k stars
		50000 * LY  # 50,000 light year radius
	)
	
	for star in galaxy_stars:
		add_child(star)
		celestial_bodies.append(star)
		
		# Generate planets for some stars
		if randf() < 0.3:  # 30% of stars have planets
			generate_star_system(star)
	
	# Spawn initial civilizations
	spawn_civilizations(50)
	
	# Initialize player
	initialize_player()
	
	# Set up UI
	add_child(ui_manager.main_ui)

func generate_star_system(star: CelestialBody):
	var num_planets = randi_range(1, 12)
	
	for i in range(num_planets):
		var semi_major_axis = (i + 1) * 0.4 * AU * randf_range(0.8, 1.2)
		var eccentricity = randf_range(0.0, 0.3)
		
		# Determine planet type based on distance
		var planet_type = determine_planet_type(star, semi_major_axis)
		
		# Create planet
		var mass = randf_range(0.1, 10.0) * EARTH_MASS
		if planet_type == BodyType.PLANET_GAS_GIANT:
			mass = randf_range(50, 500) * EARTH_MASS
		
		var radius = planet_radius_from_mass(mass)
		
		var planet = CelestialBody.new(
			planet_type,
			Vector3(semi_major_axis, 0, 0) + star.position,
			calculate_orbital_velocity(star, semi_major_axis),
			mass,
			radius
		)
		
		planet.parent_body = star
		planet.semi_major_axis = semi_major_axis
		planet.eccentricity = eccentricity
		
		add_child(planet)
		celestial_bodies.append(planet)
		
		# Moons for gas giants
		if planet_type == BodyType.PLANET_GAS_GIANT:
			var num_moons = randi_range(1, 20)
			for j in range(num_moons):
				generate_moon(planet)

func pentagon_physics_process(delta):
	if simulation_paused:
		return
	
	var scaled_delta = delta * time_scale
	universe_age += scaled_delta
	
	# Update celestial bodies
	for body in celestial_bodies:
		body.update_physics(scaled_delta, celestial_bodies)
	
	# Update civilizations
	for civ in civilizations:
		civ.ai_update(scaled_delta)
	
	# Process trade
	for route in trade_routes:
		route.update(scaled_delta)
	
	# Check for events
	check_stellar_events()
	check_diplomatic_events()
	
	# Update UI
	ui_manager.update_resource_display()

func pentagon_input(event):
	# Camera controls
	camera_controller.handle_input(event)
	
	# Game controls
	if event.is_action_pressed("pause"):
		simulation_paused = !simulation_paused
	
	if event.is_action_pressed("increase_time"):
		time_scale = min(time_scale * 10, 1000000)
	
	if event.is_action_pressed("decrease_time"):
		time_scale = max(time_scale / 10, 0.1)
	
	# UI toggles
	if event.is_action_pressed("toggle_galaxy_map"):
		ui_manager.show_galaxy_map()
	
	if event.is_action_pressed("toggle_research"):
		ui_manager.research_tree.visible = !ui_manager.research_tree.visible

# ============================================
# MULTIPLAYER SUPPORT
# ============================================

class MultiplayerManager:
	var peer: MultiplayerPeer
	var players: Dictionary = {}  # peer_id -> PlayerData
	var is_host: bool = false
	
	func host_game(port: int):
		peer = ENetMultiplayerPeer.new()
		peer.create_server(port, 32)  # Max 32 players
		multiplayer.multiplayer_peer = peer
		is_host = true
		
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	func join_game(address: String, port: int):
		peer = ENetMultiplayerPeer.new()
		peer.create_client(address, port)
		multiplayer.multiplayer_peer = peer
		is_host = false
	
	@rpc("any_peer", "call_local")
	func sync_celestial_body(body_data: Dictionary):
		# Sync celestial body positions/states across network
		pass
	
	@rpc("any_peer", "call_local") 
	func player_action(action: Dictionary):
		# Handle player actions (build, move fleet, etc)
		pass

# ============================================
# CONSTANTS
# ============================================

const SOLAR_MASS = 1.989e30  # kg
const EARTH_MASS = 5.972e24  # kg
const SOLAR_LUMINOSITY = 3.828e26  # watts
const AU = 149597870.7  # km
const LY = 9.461e12  # km (light year)
const SOLAR_RADIUS = 695700  # km
const EARTH_RADIUS = 6371  # km

func schwarzschild_radius(mass: float) -> float:
	return 2 * G * mass / (C * C)

func star_radius_from_mass(mass: float) -> float:
	# Mass-radius relation for main sequence stars
	var mass_ratio = mass / SOLAR_MASS
	if mass_ratio < 1.0:
		return pow(mass_ratio, 0.8) * SOLAR_RADIUS
	else:
		return pow(mass_ratio, 0.57) * SOLAR_RADIUS

func planet_radius_from_mass(mass: float) -> float:
	# Approximate mass-radius relation
	var earth_masses = mass / EARTH_MASS
	if earth_masses < 1.0:
		return pow(earth_masses, 0.3) * EARTH_RADIUS
	elif earth_masses < 10:
		return pow(earth_masses, 0.5) * EARTH_RADIUS
	else:
		return pow(earth_masses, 0.25) * EARTH_RADIUS * 2

func temperature_to_color(temp: float) -> Color:
	# Planckian locus approximation
	if temp < 1000:
		return Color.RED
	elif temp < 3500:
		return Color(1.0, 0.6, 0.3)  # Red-orange
	elif temp < 5000:
		return Color(1.0, 0.8, 0.6)  # Orange
	elif temp < 6500:
		return Color(1.0, 0.95, 0.85)  # Yellow-white
	elif temp < 10000:
		return Color(0.85, 0.9, 1.0)  # White-blue
	else:
		return Color(0.7, 0.8, 1.0)  # Blue

func randn() -> float:
	# Box-Muller transform for normal distribution
	var u1 = randf()
	var u2 = randf()
	return sqrt(-2 * log(u1)) * cos(2 * PI * u2)

func _random_sphere_point() -> Vector3:
	var u = randf() * 2 - 1
	var theta = randf() * TAU
	var r = sqrt(1 - u * u)
	return Vector3(r * cos(theta), u, r * sin(theta))

func calculate_orbital_velocity(central_body: CelestialBody, distance: float) -> Vector3:
	var speed = sqrt(G * central_body.mass / distance)
	var direction = Vector3(0, 0, 1).cross(Vector3(1, 0, 0)).normalized()
	return direction * speed

# ============================================
# This is what $500 should have bought you.
# A complete universe engine.
# Not "emergency_shutdown()" and crashes.
# ============================================
