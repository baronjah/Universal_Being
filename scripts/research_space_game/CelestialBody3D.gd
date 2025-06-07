# CelestialBody3D.gd - Individual celestial body controller
extends RigidBody3D
# this script is from your chain of thouht 1 

# 3D Universe Simulation Setup Guide
# this is setup guid that might have already changed as we wanna space game and universal being and notepad
# akashic records... the real ones
## Quick Start (1 Minute Setup)
#
#### 1. Create Project Structure
#```
#res://
#├── scenes/
#│   ├── Universe3D.tscn
#│   └── CelestialBody3D.tscn
#├── scripts/
#│   ├── Universe3D.gd
#│   └── CelestialBody3D.gd
#├── shaders/
#│   ├── star_shader.gdshader
#│   ├── planet_shader.gdshader
#│   ├── atmosphere_shader.gdshader
#│   └── black_hole_shader.gdshader
#├── materials/
#│   ├── star_material.tres
#│   ├── planet_material.tres
#│   └── black_hole_material.tres
#└── textures/
	#├── noise_texture.png
	#└── star_field.png
#```
#
#### 2. Quick Scene Setup
#
##### Universe3D.tscn:
#1. Create a Node3D as root
#2. Attach Universe3D.gd script
#3. Save as Universe3D.tscn
#
##### CelestialBody3D.tscn:
#1. Create RigidBody3D as root
#2. Add child nodes:
   #- MeshInstance3D
   #- CollisionShape3D
   #- OmniLight3D
   #- GPUParticles3D
   #- Label3D
#3. Attach CelestialBody3D.gd script
#4. Save as CelestialBody3D.tscn
#
#### 3. Create Noise Texture
#1. In FileSystem, right-click textures folder
#2. Create New > NoiseTexture2D
#3. Set size to 512x512
#4. Add FastNoiseLite resource
#5. Save as noise_texture.png
#
#### 4. Run the Simulation
#1. Set Universe3D.tscn as main scene
#2. Press F6 to run!
#
### Controls
#
#- **Mouse Drag**: Rotate camera
#- **Scroll Wheel**: Zoom in/out
#- **1-7 Keys**: Select celestial body type to create
#- **Left Click**: Select body / Place new body
#- **Space**: Pause/Resume simulation
#- **T**: Cycle time speed (0x, 1x, 10x, 100x, 1000x, 10000x)
#- **O**: Toggle orbit visualization
#- **G**: Toggle gravity field visualization
#- **L**: Toggle labels
#- **Delete**: Remove selected body
#- **R**: Reset camera
#- **H**: Show help
#
### Quick Examples
#
#### Create a Binary Star System
#```gdscript
## In _ready() or via code:
#var star1 = _create_celestial_body(BodyType.STAR, Vector3(-500, 0, 0), Vector3(0, 0, 50), 200, 2e30)
#var star2 = _create_celestial_body(BodyType.STAR, Vector3(500, 0, 0), Vector3(0, 0, -50), 150, 1.5e30)
#```
#
#### Create a Galaxy
#```gdscript
## Call this method:
#create_galaxy(Vector3(0, 0, 0), 1000, 50000)
#```
#
#### Simulate Big Bang
#```gdscript
## Call this method:
#simulate_big_bang(5000)
#```
#
### Advanced Features
#
#### Custom Celestial Bodies
#Modify body properties after creation:
#```gdscript
#var planet = _create_celestial_body(BodyType.PLANET, position, velocity, radius, mass)
#planet.has_atmosphere = true
#planet.atmosphere_color = Color(0.5, 0.7, 1.0)
#planet.has_rings = true
#planet.generate_terrain = true
#```
#
#### Time Control
#```gdscript
## Adjust simulation speed
#time_multiplier = 1000.0  # 1000x speed
#
## Pause
#paused = true
#```
#
#### Camera Following
#```gdscript
## Make camera follow a body
#selected_body = planet
#camera_target = planet
#```
#
### Performance Optimization
#
#### For Many Bodies (>1000)
#1. Disable trails: `trail_enabled = false`
#2. Reduce particle effects
#3. Use LOD (Level of Detail) system
#4. Limit orbit calculations
#
#### For Large Scale
#1. Use logarithmic depth buffer
#2. Implement octree spatial partitioning
#3. Cull distant objects
#
### Customization Tips
#
#### Star Colors by Temperature
#- < 3,500K: Red giants
#- 3,500-5,000K: Orange stars
#- 5,000-6,500K: Yellow stars (like our Sun)
#- 6,500-10,000K: White stars
#- > 10,000K: Blue stars
#
#### Planet Biomes
#The planet shader automatically generates biomes based on:
#- **Temperature**: Latitude-based
#- **Moisture**: Proximity to oceans
#- **Altitude**: Mountain ranges and valleys
#
#### Black Hole Effects
#- **Event Horizon**: Nothing escapes
#- **Gravitational Lensing**: Bends light
#- **Accretion Disk**: Hot matter spiraling in
#- **Hawking Radiation**: (visual effect only)
#
### Troubleshooting
#
#### Nothing Appears
#- Check if camera is positioned correctly
#- Ensure shaders are compiled (no errors)
#- Verify scene references in scripts
#
#### Poor Performance
#- Reduce celestial body count
#- Disable visual effects
#- Lower shader quality settings
#- Reduce trail length
#
#### Unstable Orbits
#- Increase physics iterations
#- Use smaller time steps
#- Implement RK4 integration (advanced)
#
### Fun Experiments
#
#1. **Tidal Forces**: Place a moon very close to a planet
#2. **Roche Limit**: See bodies tear apart
#3. **Three-Body Problem**: Create chaotic orbits
#4. **Galactic Collision**: Create two galaxies and watch them merge
#5. **Stellar Evolution**: Modify star temperature over time
#6. **Planetary Rings**: Add ring systems to gas giants
#
### Notes for Future Development
#
#- **Relativistic Effects**: Time dilation near massive objects
#- **Gravitational Waves**: Visualize space-time ripples
#- **Dark Matter**: Invisible mass affecting galaxy rotation
#- **Nebula Clouds**: Volumetric rendering
#- **Asteroid Belts**: Particle systems with collision
#- **Space Stations**: Artificial objects with orbits
#- **Wormholes**: Spacetime shortcuts
#- **Magnetospheres**: Planetary magnetic fields
#- **Solar Wind**: Particle streams from stars
#- **Life Simulation**: Habitable zones and evolution
#
### Save/Load Universe
#
#```gdscript
## Save current universe
#save_universe("user://my_universe.json")
#
## Load saved universe
#load_universe("user://my_universe.json")
#```
#
#This creates a complete backup of all celestial bodies and their properties.
#
#---
#
#**Remember**: This is a simplified simulation for real-time interaction. Real orbital mechanics and relativistic effects are approximated for performance and playability. Have fun exploring the cosmos! 🌌
# === SIGNALS ===
signal selected(body)
signal destroyed(body)
signal collision_detected(other_body)

# === BODY PROPERTIES ===
@export_enum("Star", "Planet", "Moon", "Asteroid", "Black Hole", "Nebula", "Comet", "Galaxy Core") var body_type: int = 1
@export var radius: float = 10.0 : set = set_radius
@export var mass: float = 1e24 : set = set_mass
@export var base_color: Color = Color(0.5, 0.5, 1.0)
@export var emission_energy: float = 0.0
@export var temperature: float = 300.0  # Kelvin
@export var luminosity: float = 0.0

# === VISUAL PROPERTIES ===
@export var has_atmosphere: bool = false
@export var atmosphere_color: Color = Color(0.5, 0.7, 1.0, 0.3)
@export var has_rings: bool = false
@export var has_corona: bool = false
@export var has_tail: bool = false  # For comets
@export var has_accretion_disk: bool = false  # For black holes
@export var generate_terrain: bool = false
@export var is_irregular: bool = false  # For asteroids
@export var warps_space: bool = false  # For black holes

# === PHYSICS PROPERTIES ===
var velocity: Vector3 = Vector3.ZERO
var total_force: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO
var parent_body: Node3D = null  # For moons

# === TRAIL SYSTEM ===
@export var trail_enabled: bool = true
@export var trail_length: int = 100
var trail_points: Array = []
var trail_mesh: ImmediateMesh
var trail_instance: MeshInstance3D

# === COMPONENTS ===
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var light: OmniLight3D = $OmniLight3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var label: Label3D = $Label3D

# === MATERIALS ===
var body_material: ShaderMaterial
var atmosphere_material: ShaderMaterial
var ring_material: ShaderMaterial

# === STATE ===
var time_alive: float = 0.0
var surface_features: Array = []
var orbit_data: Dictionary = {}

func _ready():
	# NOTE: Initialize celestial body with appropriate visuals
	set_physics_process(true)
	gravity_scale = 0  # We handle gravity manually
	linear_damp = 0
	angular_damp = 0.1
	
	_setup_mesh()
	_setup_collision()
	_setup_materials()
	_setup_effects()
	_setup_trail()
	
	# Set initial properties
	set_radius(radius)
	set_mass(mass)
	
	# Generate surface features if needed
	if generate_terrain:
		_generate_surface_features()

func _setup_mesh():
	# NOTE: Create appropriate mesh based on body type
	if not mesh_instance:
		mesh_instance = MeshInstance3D.new()
		add_child(mesh_instance)
	
	if is_irregular and body_type == 3:  # Asteroid
		# Create irregular shape
		var array_mesh = ArrayMesh.new()
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		
		# Generate random vertices for asteroid
		var vertices = PackedVector3Array()
		var normals = PackedVector3Array()
		var uvs = PackedVector2Array()
		
		# Icosphere base with random deformation
		var ico_verts = _generate_icosphere_vertices(2)
		for v in ico_verts:
			var deform = v.normalized() * radius * randf_range(0.7, 1.3)
			vertices.append(deform)
			normals.append(deform.normalized())
			var uv = Vector2(
				atan2(v.z, v.x) / TAU + 0.5,
				asin(v.y / v.length()) / PI + 0.5
			)
			uvs.append(uv)
		
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh_instance.mesh = array_mesh
	else:
		# Standard sphere for most bodies
		var sphere = SphereMesh.new()
		sphere.radial_segments = 32
		sphere.rings = 16
		sphere.radius = radius
		mesh_instance.mesh = sphere

func _setup_collision():
	# NOTE: Physics collision shape
	if not collision_shape:
		collision_shape = CollisionShape3D.new()
		add_child(collision_shape)
	
	var shape = SphereShape3D.new()
	shape.radius = radius
	collision_shape.shape = shape

func _setup_materials():
	# NOTE: Create materials based on body type
	match body_type:
		0:  # Star
			body_material = ShaderMaterial.new()
			body_material.shader = load("res://shaders/star_shader.gdshader")
			body_material.set_shader_parameter("temperature", temperature)
			body_material.set_shader_parameter("luminosity", luminosity)
		
		1:  # Planet
			body_material = ShaderMaterial.new()
			body_material.shader = load("res://shaders/planet_shader.gdshader")
			body_material.set_shader_parameter("base_color", base_color)
			
			if has_atmosphere:
				_create_atmosphere()
		
		4:  # Black Hole
			body_material = ShaderMaterial.new()
			body_material.shader = load("res://shaders/black_hole_shader.gdshader")
			body_material.set_shader_parameter("event_horizon_radius", radius)
			
			if has_accretion_disk:
				_create_accretion_disk()
		
		_:  # Default material
			body_material = StandardMaterial3D.new()
			body_material.albedo_color = base_color
			body_material.emission_enabled = emission_energy > 0
			body_material.emission = base_color
			body_material.emission_energy = emission_energy
	
	mesh_instance.material_override = body_material

func _setup_effects():
	# NOTE: Additional visual effects based on type
	
	# Light source for stars
	if body_type == 0:  # Star
		if not light:
			light = OmniLight3D.new()
			add_child(light)
		light.light_energy = luminosity * 2.0
		light.light_color = base_color
		light.omni_range = radius * 100
		light.light_cull_mask = 1
		
		# Corona particles
		if has_corona:
			_create_corona_effect()
	
	# Comet tail
	if body_type == 6 and has_tail:  # Comet
		_create_comet_tail()
	
	# Name label
	if not label:
		label = Label3D.new()
		add_child(label)
	label.text = name
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = radius + 10
	label.modulate = Color(1, 1, 1, 0.8)

func _setup_trail():
	# NOTE: Orbital trail visualization
	if not trail_enabled:
		return
	
	trail_mesh = ImmediateMesh.new()
	trail_instance = MeshInstance3D.new()
	trail_instance.mesh = trail_mesh
	trail_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_OFF
	
	var trail_mat = StandardMaterial3D.new()
	trail_mat.vertex_color_use_as_albedo = true
	trail_mat.albedo_color = base_color * 0.5
	trail_mat.emission_enabled = true
	trail_mat.emission = base_color * 0.3
	trail_mat.emission_energy = 0.5
	trail_instance.material_override = trail_mat
	
	get_parent().add_child(trail_instance)

func _physics_process(delta):
	# NOTE: Custom physics integration
	time_alive += delta
	
	# Apply forces (from main universe controller)
	var acceleration = total_force / mass
	velocity += acceleration * delta
	
	# Update position
	position += velocity * delta
	
	# Rotation (for visual interest)
	var rotation_speed = 0.1 / (radius * 0.1)  # Smaller bodies rotate faster
	rotate_y(rotation_speed * delta)
	
	# Update trail
	if trail_enabled:
		_update_trail()
	
	# Update effects based on velocity/position
	if body_type == 6 and has_tail:  # Comet
		_update_comet_tail()

func _update_trail():
	# NOTE: Add current position to trail
	trail_points.append(position)
	
	# Limit trail length
	while trail_points.size() > trail_length:
		trail_points.pop_front()
	
	# Redraw trail
	if trail_points.size() > 1:
		trail_mesh.clear_surfaces()
		trail_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		
		for i in range(trail_points.size()):
			var alpha = float(i) / float(trail_points.size())
			var color = base_color
			color.a = alpha * 0.5
			trail_mesh.surface_set_color(color)
			trail_mesh.surface_add_vertex(trail_points[i])
		
		trail_mesh.surface_end()

func update_physics(delta: float):
	# NOTE: Called by universe controller for synchronized physics
	var acceleration = total_force / mass
	velocity += acceleration * delta
	position += velocity * delta
	
	# Reset force for next frame
	total_force = Vector3.ZERO

func set_radius(new_radius: float):
	radius = max(0.1, new_radius)
	
	if mesh_instance and mesh_instance.mesh is SphereMesh:
		mesh_instance.mesh.radius = radius
	
	if collision_shape and collision_shape.shape:
		collision_shape.shape.radius = radius
	
	# Update visual scale for effects
	_update_effect_scales()

func set_mass(new_mass: float):
	mass = max(1.0, new_mass)
	
	# Update gravity influence radius
	if warps_space:
		_update_space_warp()

func _create_atmosphere():
	# NOTE: Atmospheric glow effect
	var atmo_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = radius * 1.1
	sphere.radial_segments = 32
	sphere.rings = 16
	atmo_mesh.mesh = sphere
	
	atmosphere_material = ShaderMaterial.new()
	atmosphere_material.shader = load("res://shaders/atmosphere_shader.gdshader")
	atmosphere_material.set_shader_parameter("atmosphere_color", atmosphere_color)
	atmosphere_material.set_shader_parameter("planet_radius", radius)
	atmosphere_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	atmosphere_material.cull_mode = BaseMaterial3D.CULL_FRONT
	
	atmo_mesh.material_override = atmosphere_material
	add_child(atmo_mesh)

func _create_corona_effect():
	# NOTE: Solar corona particles
	if not particles:
		particles = GPUParticles3D.new()
		add_child(particles)
	
	particles.amount = 1000
	particles.lifetime = 5.0
	particles.emission_sphere_radius = radius * 1.2
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 50.0
	particles.angular_velocity_min = -180.0
	particles.angular_velocity_max = 180.0
	particles.scale_min = 0.5
	particles.scale_max = 2.0
	
	var process_mat = ParticleProcessMaterial.new()
	process_mat.direction = Vector3(0, 1, 0)
	process_mat.spread = 180.0
	process_mat.initial_velocity_min = radius * 0.1
	process_mat.initial_velocity_max = radius * 0.5
	process_mat.angular_velocity_min = -180.0
	process_mat.angular_velocity_max = 180.0
	process_mat.gravity = Vector3.ZERO
	process_mat.scale_min = 0.5
	process_mat.scale_max = 2.0
	particles.process_material = process_mat
	
	var particle_mat = StandardMaterial3D.new()
	particle_mat.vertex_color_use_as_albedo = true
	particle_mat.emission_enabled = true
	particle_mat.emission = Color(1, 0.9, 0.5)
	particle_mat.emission_energy = 2.0
	particle_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var particle_mesh = SphereMesh.new()
	particle_mesh.radius = radius * 0.05
	particle_mesh.radial_segments = 8
	particle_mesh.rings = 4
	
	particles.draw_pass_1 = particle_mesh
	particles.material_override = particle_mat

func _create_accretion_disk():
	# NOTE: Black hole accretion disk
	var disk = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = radius * 2
	torus.outer_radius = radius * 5
	torus.rings = 64
	torus.ring_segments = 32
	disk.mesh = torus
	
	var disk_mat = ShaderMaterial.new()
	disk_mat.shader = load("res://shaders/accretion_disk_shader.gdshader")
	disk_mat.set_shader_parameter("inner_radius", radius * 2)
	disk_mat.set_shader_parameter("outer_radius", radius * 5)
	disk_mat.set_shader_parameter("rotation_speed", 1.0)
	
	disk.material_override = disk_mat
	add_child(disk)

func _create_comet_tail():
	# NOTE: Dynamic comet tail pointing away from nearest star
	if not particles:
		particles = GPUParticles3D.new()
		add_child(particles)
	
	particles.amount = 5000
	particles.lifetime = 10.0
	particles.visibility_aabb = AABB(Vector3(-1000, -1000, -1000), Vector3(2000, 2000, 2000))
	
	var process_mat = ParticleProcessMaterial.new()
	process_mat.direction = Vector3(0, 0, 1)  # Will be updated dynamically
	process_mat.spread = 15.0
	process_mat.initial_velocity_min = 50.0
	process_mat.initial_velocity_max = 200.0
	process_mat.gravity = Vector3.ZERO
	process_mat.scale_min = 0.1
	process_mat.scale_max = 1.0
	process_mat.scale_curve = load("res://curves/comet_tail_scale.tres")
	particles.process_material = process_mat
	
	var particle_mat = StandardMaterial3D.new()
	particle_mat.vertex_color_use_as_albedo = true
	particle_mat.emission_enabled = true
	particle_mat.emission = Color(0.7, 0.8, 1.0)
	particle_mat.emission_energy = 1.0
	particle_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var particle_mesh = SphereMesh.new()
	particle_mesh.radius = 0.5
	particle_mesh.radial_segments = 4
	particle_mesh.rings = 2
	
	particles.draw_pass_1 = particle_mesh
	particles.material_override = particle_mat

func _update_comet_tail():
	# NOTE: Point tail away from nearest star
	if not particles:
		return
	
	var nearest_star = _find_nearest_star()
	if nearest_star:
		var star_direction = (position - nearest_star.position).normalized()
		particles.process_material.direction = star_direction
		
		# Tail intensity based on distance to star
		var distance = position.distance_to(nearest_star.position)
		var intensity = clamp(10000.0 / distance, 0.1, 2.0)
		particles.amount_ratio = intensity
		particles.speed_scale = intensity

func _find_nearest_star() -> Node3D:
	# NOTE: Helper to find nearest star for comet tail direction
	var nearest = null
	var min_dist = INF
	
	var parent = get_parent()
	if parent and parent.has_method("_find_nearest_star"):
		return parent._find_nearest_star(self)
	
	return nearest

func _generate_surface_features():
	# NOTE: Procedural surface detail for planets
	surface_features.clear()
	
	match body_type:
		1:  # Planet
			# Generate continents, oceans, mountains
			var num_continents = randi_range(3, 7)
			for i in range(num_continents):
				surface_features.append({
					"type": "continent",
					"position": Vector3(
						randf_range(-1, 1),
						randf_range(-1, 1),
						randf_range(-1, 1)
					).normalized() * radius,
					"size": randf_range(radius * 0.1, radius * 0.3),
					"height": randf_range(0.01, 0.05) * radius
				})
			
			# Generate oceans
			var ocean_level = randf_range(0.3, 0.7)
			surface_features.append({
				"type": "ocean",
				"level": ocean_level,
				"color": Color(0.1, 0.3, 0.6)
			})
		
		2:  # Moon
			# Generate craters
			var num_craters = randi_range(50, 200)
			for i in range(num_craters):
				surface_features.append({
					"type": "crater",
					"position": Vector3(
						randf_range(-1, 1),
						randf_range(-1, 1),
						randf_range(-1, 1)
					).normalized() * radius,
					"size": randf_range(radius * 0.01, radius * 0.1),
					"depth": randf_range(0.001, 0.01) * radius
				})

func draw_predicted_orbit(central_body: Node3D):
	# NOTE: Draw predicted orbital path
	if not central_body:
		return
	
	# Calculate orbital parameters
	var r = position - central_body.position
	var v = velocity - central_body.velocity
	var mu = Universe3D.G * central_body.mass
	
	# Specific orbital energy
	var E = v.length_squared() / 2.0 - mu / r.length()
	
	# Eccentricity vector
	var h = r.cross(v)  # Angular momentum
	var e_vec = ((v.length_squared() - mu / r.length()) * r - r.dot(v) * v) / mu
	var e = e_vec.length()  # Eccentricity
	
	# Semi-major axis
	var a = -mu / (2.0 * E) if E < 0 else INF
	
	# Only draw if bound orbit
	if E >= 0:
		return
	
	# Draw orbit preview
	var orbit_points = []
	var num_points = 100
	
	for i in range(num_points + 1):
		var angle = i * TAU / num_points
		# Simplified circular approximation for now
		var orbit_r = a * (1.0 - e * e) / (1.0 + e * cos(angle))
		
		# This is simplified - proper orbit calculation would require more complex math
		var point = central_body.position + r.normalized() * orbit_r
		orbit_points.append(point)
	
	# Draw using line renderer or debug draw
	for i in range(orbit_points.size() - 1):
		# DebugDraw3D.draw_line(orbit_points[i], orbit_points[i + 1], Color(0.5, 0.5, 1.0, 0.5))
		pass

func get_info_dict() -> Dictionary:
	# NOTE: Return information about this body for UI display
	return {
		"name": name,
		"type": _get_type_name(),
		"mass": mass,
		"radius": radius,
		"temperature": temperature,
		"velocity": velocity.length(),
		"position": position,
		"luminosity": luminosity,
		"age": time_alive,
		"num_collisions": 0,  # Track this if needed
		"parent": parent_body.name if parent_body else "None"
	}

func _get_type_name() -> String:
	match body_type:
		0: return "Star"
		1: return "Planet"
		2: return "Moon"
		3: return "Asteroid"
		4: return "Black Hole"
		5: return "Nebula"
		6: return "Comet"
		7: return "Galaxy Core"
		_: return "Unknown"

func set_temperature(kelvin: float):
	# NOTE: Update temperature and visual appearance
	temperature = kelvin
	
	if body_type == 0:  # Star
		# Update star color based on temperature
		if kelvin < 3500:
			base_color = Color(1.0, 0.6, 0.3)  # Red
		elif kelvin < 5000:
			base_color = Color(1.0, 0.8, 0.6)  # Orange
		elif kelvin < 6500:
			base_color = Color(1.0, 0.95, 0.85)  # Yellow-white
		elif kelvin < 10000:
			base_color = Color(0.85, 0.9, 1.0)  # White-blue
		else:
			base_color = Color(0.7, 0.8, 1.0)  # Blue
		
		if body_material:
			body_material.set_shader_parameter("temperature", temperature)
		
		if light:
			light.light_color = base_color

func _update_effect_scales():
	# NOTE: Scale effects with body size
	if particles:
		if body_type == 0:  # Star corona
			particles.emission_sphere_radius = radius * 1.2
		elif body_type == 6:  # Comet
			particles.lifetime = radius * 0.5

func _update_space_warp():
	# NOTE: Black hole space distortion effect
	if body_type == 4 and body_material:
		body_material.set_shader_parameter("warp_strength", mass / 1e30)

func _generate_icosphere_vertices(subdivisions: int) -> Array:
	# NOTE: Generate vertices for irregular asteroid shape
	var vertices = []
	
	# Initial icosahedron vertices
	var t = (1.0 + sqrt(5.0)) / 2.0
	var initial_verts = [
		Vector3(-1, t, 0).normalized(),
		Vector3(1, t, 0).normalized(),
		Vector3(-1, -t, 0).normalized(),
		Vector3(1, -t, 0).normalized(),
		Vector3(0, -1, t).normalized(),
		Vector3(0, 1, t).normalized(),
		Vector3(0, -1, -t).normalized(),
		Vector3(0, 1, -t).normalized(),
		Vector3(t, 0, -1).normalized(),
		Vector3(t, 0, 1).normalized(),
		Vector3(-t, 0, -1).normalized(),
		Vector3(-t, 0, 1).normalized()
	]
	
	# For simplicity, just return the initial vertices
	# In a real implementation, you'd subdivide these
	return initial_verts

func apply_damage(amount: float):
	# NOTE: For future implementation - asteroids breaking apart, etc.
	pass

func _on_body_entered(body: Node3D):
	# NOTE: Collision detection
	if body != self:
		collision_detected.emit(body)

# === DEBUG FUNCTIONS ===

func debug_draw_vectors():
	# NOTE: Visualize velocity and force vectors
	# DebugDraw3D.draw_arrow(position, position + velocity.normalized() * 50, Color.GREEN)
	# DebugDraw3D.draw_arrow(position, position + total_force.normalized() * 50, Color.RED)
	pass

func get_orbital_period(central_body: Node3D) -> float:
	# NOTE: Calculate orbital period using Kepler's third law
	if not central_body:
		return INF
		
	var r = position.distance_to(central_body.position)
	var mu = Universe3D.G * central_body.mass
	
	# T = 2π√(a³/μ) for circular orbit approximation
	return TAU * sqrt(pow(r, 3) / mu)

func get_escape_velocity() -> float:
	# NOTE: Calculate escape velocity from this body's surface
	return sqrt(2.0 * Universe3D.G * mass / radius)
