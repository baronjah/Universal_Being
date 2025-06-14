# fire_element.gd - Fire element behavior and properties
# Claude Decipher: Fire elements like stars that have size, create light, change outer shape
# and interact with other elements like wood, consuming it and changing its properties

extends "res://code/gdscript/scripts/elements_shapes_projection/base_element.gd"

class_name FireElement

# Fire-specific constants
const FLICKER_SPEED = 10.0
const FLICKER_INTENSITY = 0.3
const HEAT_RADIUS = 12.0
const CONSUME_THRESHOLD = 5.0
const LIGHT_INTENSITY = 2.0
const SMOKE_CHANCE = 0.2
const HEAT_TRANSFER_RATE = 0.5
const BASE_LIFETIME = 30.0

# Fire-specific properties
var heat_intensity: float = 1.0     # How hot the fire is (affects light, damage, spread)
var fuel_consumption_rate: float = 0.1  # How quickly fire consumes fuel
var flicker_intensity: float = 0.5   # How much the fire visually flickers
var light_radius: float = 5.0       # How far the light from this fire reaches
var light_color: Color = Color(1.0, 0.7, 0.1, 1.0)  # Default orange fire color
var smoke_production: float = 0.2   # How much smoke this fire produces
var lifetime: float = 30.0          # How long this fire will burn without fuel
var temperature = 800.0             # Celsius
var color_shift = 0.0               # 0 = red/orange, 1 = blue/white hot
var smoke_time = 0.0
var ember_time = 0.0
var initial_position = Vector3.ZERO

# Fire state tracking
var current_fuel: float = 10.0      # Current available fuel
var is_spreading: bool = false      # Whether fire is actively spreading
var connected_fuel_sources = []     # References to fuel sources (like wood)
var flicker_offset = 0.0

# Light node to create dynamic lighting
var light_node

# Particle systems for fire effects
var flame_particles
var spark_particles
var smoke_particles

func _init():
	element_type = "fire"
	attraction_radius = 2.0
	repulsion_radius = 0.5
	connection_strength = 0.8
	evolution_factor = 0.0
	mass = 0.3
	
	# Set fire-specific visual properties
	point_color = Color(1.0, 0.6, 0.1, 0.9)
	connection_color = Color(1.0, 0.4, 0.1, 0.5)

func _ready():
	# Call parent ready function
	super()
	
	# Set up initial fire behavior
	add_to_group("fire_elements")
	add_to_group("light_sources")
	
	# Store initial position for reference
	initial_position = global_position
	
	# Initialize with random flicker
	flicker_offset = randf() * 100.0
	
	# Update the mesh appearance
	var mesh_instance = get_node_or_null("MeshInstance3D")
	if mesh_instance and mesh_instance.material_override:
		var material = mesh_instance.material_override
		material.albedo_color = point_color
		material.emission_enabled = true
		material.emission = point_color
		material.emission_energy = 2.0
		
		# Add transparency
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Create dynamic light
	setup_light_emission()
	
	# Create particle systems
	create_particles()
	
	# Initialize fire-specific properties
	initialize_fire_properties()
	
	# Start with random lifetime
	lifetime = BASE_LIFETIME * randf_range(0.8, 1.2)

# Initialize fire properties
func initialize_fire_properties():
	properties = {
		"age": 0.0,
		"stability": 0.4,
		"energy": 1.0,
		"evolution_progress": 0.0,
		"temperature": temperature,
		"intensity": heat_intensity,
		"fuel": current_fuel,
		"lifetime": lifetime,
		"smoke_production": smoke_production,
		"heat_radius": HEAT_RADIUS,
		"color_temperature": temperature
	}

# Override base element's process_behavior
func process_behavior(delta):
	# Call parent behavior processing
	super.process_behavior(delta)
	
	# Fire-specific behavior
	flicker(delta)
	consume_fuel(delta)
	emit_light(delta)
	check_spread_conditions(delta)
	update_heat_based_on_size()
	handle_smoke_production(delta)
	handle_ember_production(delta)
	
	# Reduce lifetime if no fuel sources
	if connected_fuel_sources.size() == 0:
		lifetime -= delta
		if lifetime <= 0:
			extinguish()

func flicker(delta):
	# Create realistic fire flickering effect
	flicker_offset += delta * FLICKER_SPEED
	var flicker_amount = sin(flicker_offset) * flicker_intensity
	
	# Apply flickering to scale and position
	var base_scale = Vector3(1.0, 1.0, 1.0) * heat_intensity
	scale = base_scale + Vector3(flicker_amount * 0.1, flicker_amount * 0.3, flicker_amount * 0.1)
	
	# Slight position adjustment for more natural movement
	if initial_position != Vector3.ZERO:  # Make sure we have a reference position
		position.y = initial_position.y + flicker_amount * 0.05
		if position.y > initial_position.y + 0.5:
			position.y = initial_position.y + 0.5

func consume_fuel(delta):
	# Process fuel consumption
	var consumed_this_frame = 0.0
	
	for source in connected_fuel_sources:
		if is_instance_valid(source) and source.has_method("provide_fuel"):
			var fuel_amount = source.provide_fuel(fuel_consumption_rate * delta * heat_intensity)
			current_fuel += fuel_amount
			consumed_this_frame += fuel_amount
			
			# If we consumed fuel, increase our lifetime
			if fuel_amount > 0:
				lifetime = max(lifetime, 10.0)
	
	# Adjust fire properties based on available fuel
	if consumed_this_frame <= 0 and current_fuel > 0:
		# Using stored fuel
		current_fuel -= fuel_consumption_rate * delta * heat_intensity
	
	# Adjust intensity based on fuel
	if current_fuel <= 0 and consumed_this_frame <= 0:
		heat_intensity = max(0.1, heat_intensity - delta * 0.5)
	else:
		# Fire can grow with more fuel
		heat_intensity = min(3.0, heat_intensity + delta * 0.1 * consumed_this_frame)
	
	# Update properties
	properties["fuel"] = current_fuel
	properties["intensity"] = heat_intensity

func emit_light(delta):
	# Update light properties based on current fire state
	light_radius = 5.0 * heat_intensity
	
	# Adjust light color based on heat (hotter = more white/blue, cooler = more red)
	if heat_intensity > 2.0:
		light_color = Color(1.0, 0.9, 0.7, 1.0)  # Hot white-yellow
	elif heat_intensity > 1.5:
		light_color = Color(1.0, 0.8, 0.2, 1.0)  # Bright orange-yellow
	elif heat_intensity > 0.8:
		light_color = Color(1.0, 0.6, 0.1, 1.0)  # Standard orange
	else:
		light_color = Color(0.8, 0.3, 0.1, 1.0)  # Dim red-orange
	
	# Update light node
	if light_node:
		light_node.light_energy = heat_intensity
		light_node.light_color = light_color
		light_node.omni_range = light_radius

func check_spread_conditions(delta):
	# Check if fire can spread to nearby objects
	if heat_intensity > 1.2:
		is_spreading = true
		
		# Look for nearby flammable objects
		var nearby_flammables = get_nearby_flammable_elements()
		for flammable in nearby_flammables:
			if flammable.has_method("apply_heat"):
				flammable.apply_heat(heat_intensity * delta)
	else:
		is_spreading = false

func get_nearby_flammable_elements():
	# Find nearby elements that could catch fire
	var flammables = []
	
	# Check connections for flammable elements
	for connection in connections:
		if is_instance_valid(connection):
			if connection.element_type in ["wood", "paper", "grass", "oil"] and connection.has_method("is_flammable"):
				if connection.is_flammable():
					flammables.append(connection)
	
	return flammables

func update_heat_based_on_size():
	# Larger fires generate more heat
	var point_count = connections.size() + 1
	if point_count > 5:
		# Boost heat output for larger fires
		heat_intensity = min(5.0, heat_intensity * (1.0 + (point_count - 5) * 0.05))
	
	# Update properties
	properties["intensity"] = heat_intensity
	properties["temperature"] = 500.0 + heat_intensity * 500.0

func apply_wind(wind_direction: Vector3, wind_strength: float):
	# Fire responds to wind - bends in direction and can spread faster
	var bend_factor = min(1.0, wind_strength * 0.5)
	
	# Visual transformation to bend in wind direction
	var wind_adjustment = wind_direction.normalized() * bend_factor
	
	# Adjust how fire points are positioned
	for connection in connections:
		if connection.has_method("apply_force"):
			connection.apply_force(wind_direction * wind_strength * 0.2)
	
	# Increase spread chance in wind direction
	if is_spreading and wind_strength > 0.5:
		spread_in_direction(wind_direction, wind_strength)

func spread_in_direction(direction: Vector3, strength: float):
	# Create a new fire element in the wind direction if conditions allow
	if heat_intensity > 1.5 and randf() < strength * 0.1:
		var new_position = global_position + direction.normalized() * attraction_radius * 2.0
		
		# Create new fire at target position
		var new_fire = FireElement.new()
		new_fire.global_position = new_position
		new_fire.heat_intensity = heat_intensity * 0.7  # Start smaller
		get_parent().add_child(new_fire)
		return new_fire
	
	return null

func extinguish():
	# Handle fire being put out
	emit_smoke_particles()
	
	# Disconnect from fuel sources
	for source in connected_fuel_sources:
		if is_instance_valid(source) and source.has_method("disconnect_fire"):
			source.disconnect_fire(self)
	
	# Remove this fire element
	queue_free()

func emit_smoke_particles():
	# If we have smoke particles, make them emit a final burst
	if smoke_particles:
		smoke_particles.amount = int(30 * smoke_production)
		smoke_particles.one_shot = true
		smoke_particles.emitting = true

func connect_to_fuel_source(source):
	# Connect to a new fuel source
	if not connected_fuel_sources.has(source):
		connected_fuel_sources.append(source)
		if source.has_method("connect_fire"):
			source.connect_fire(self)
		return true
	return false

func setup_light_emission():
	# Create light node if it doesn't exist
	if not has_node("FireLight"):
		light_node = OmniLight3D.new()
		light_node.name = "FireLight"
		light_node.light_color = light_color
		light_node.light_energy = heat_intensity
		light_node.omni_range = light_radius
		light_node.shadow_enabled = true
		light_node.visible = false  # Start invisible until resource manager accepts it
		add_child(light_node)
		
		# Try to register with resource manager
		var resource_manager = null
		var parent = get_parent()
		while parent and not resource_manager:
			if parent is ElementManager and parent.resource_manager:
				resource_manager = parent.resource_manager
			elif parent.has_node("ElementResourceManager"):
				resource_manager = parent.get_node("ElementResourceManager")
			parent = parent.get_parent()
		
		if resource_manager:
			resource_manager.register_light(light_node)

# Create particle systems for the fire
func create_particles():
	# Flame particles
	flame_particles = GPUParticles3D.new()
	flame_particles.name = "FlameParticles"
	
	var flame_material = ParticleProcessMaterial.new()
	flame_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	flame_material.emission_sphere_radius = 0.5 * scale.x
	flame_material.direction = Vector3(0, 1, 0)
	flame_material.spread = 20.0
	flame_material.gravity = Vector3(0, -1, 0)
	flame_material.initial_velocity_min = 2.0
	flame_material.initial_velocity_max = 5.0
	flame_material.damping_min = 1.0
	flame_material.damping_max = 3.0
	flame_material.scale_min = 0.5 * scale.x
	flame_material.scale_max = 1.5 * scale.x
	flame_material.color = Color(1.0, 0.6, 0.1, 0.8)
	
	flame_particles.process_material = flame_material
	flame_particles.amount = int(20 * heat_intensity)
	flame_particles.lifetime = 1.0
	flame_particles.one_shot = false
	flame_particles.explosiveness = 0.0
	flame_particles.randomness = 0.5
	add_child(flame_particles)
	
	# Spark particles
	spark_particles = GPUParticles3D.new()
	spark_particles.name = "SparkParticles"
	
	var spark_material = ParticleProcessMaterial.new()
	spark_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spark_material.emission_sphere_radius = 0.3 * scale.x
	spark_material.direction = Vector3(0, 1, 0)
	spark_material.spread = 30.0
	spark_material.gravity = Vector3(0, -2, 0)
	spark_material.initial_velocity_min = 3.0
	spark_material.initial_velocity_max = 8.0
	spark_material.damping_min = 0.1
	spark_material.damping_max = 0.5
	spark_material.scale_min = 0.1 * scale.x
	spark_material.scale_max = 0.3 * scale.x
	spark_material.color = Color(1.0, 0.8, 0.2, 1.0)
	
	spark_particles.process_material = spark_material
	spark_particles.amount = int(10 * heat_intensity)
	spark_particles.lifetime = 0.8
	spark_particles.one_shot = false
	spark_particles.explosiveness = 0.05
	spark_particles.randomness = 0.8
	add_child(spark_particles)
	
	# Smoke particles
	smoke_particles = GPUParticles3D.new()
	smoke_particles.name = "SmokeParticles"
	
	var smoke_material = ParticleProcessMaterial.new()
	smoke_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	smoke_material.emission_sphere_radius = 0.2 * scale.x
	smoke_material.direction = Vector3(0, 1, 0)
	smoke_material.spread = 10.0
	smoke_material.gravity = Vector3(0, 0.5, 0)
	smoke_material.initial_velocity_min = 1.0
	smoke_material.initial_velocity_max = 2.0
	smoke_material.damping_min = 0.1
	smoke_material.damping_max = 0.2
	smoke_material.scale_min = 1.0 * scale.x
	smoke_material.scale_max = 2.0 * scale.x
	smoke_material.color = Color(0.3, 0.3, 0.3, 0.6)
	
	smoke_particles.process_material = smoke_material
	smoke_particles.amount = int(15 * smoke_production)
	smoke_particles.lifetime = 3.0
	smoke_particles.one_shot = false
	smoke_particles.explosiveness = 0.0
	smoke_particles.randomness = 0.3
	add_child(smoke_particles)

# Override transform_to from base element
func transform_to(target_type):
	if not can_transform_to(target_type):
		return null
	
	# If transforming to embers, handle specially
	if target_type == "ember":
		return transform_to_embers()
	
	# Otherwise use default behavior
	return super.transform_to(target_type)

# Transform into embers
func transform_to_embers():
	# Could handle a special ember transformation here
	heat_intensity *= 0.5
	update_visual_properties()
	return self

# Handle smoke production
func handle_smoke_production(delta):
	smoke_time += delta
	
	# Produce smoke periodically
	if smoke_time >= 0.5:
		smoke_time = 0.0
		
		# Update smoke particle amount based on heat and fuel
		if smoke_particles:
			var smoke_amount = int(15 * smoke_production)
			if current_fuel < 1.0:
				smoke_amount = int(smoke_amount * 2.5)  # More smoke when burning out
			
			smoke_particles.amount = smoke_amount
	
	# Update smoke production based on heat
	smoke_production = 0.2 + (3.0 - heat_intensity) * 0.2  # More smoke at lower heat
	properties["smoke_production"] = smoke_production

# Handle ember production
func handle_ember_production(delta):
	ember_time += delta
	
	# Produce embers periodically
	if ember_time >= 1.0 and heat_intensity > 1.5:
		ember_time = 0.0
		
		# Chance to emit an ember
		if randf() < 0.2 * heat_intensity:
			# Update spark particles to show more embers
			if spark_particles:
				spark_particles.amount = int(20 * heat_intensity)
				spark_particles.lifetime = 1.2
				spark_particles.explosiveness = 0.2

# Update visuals based on current state
func update_visual_properties():
	# Update colors and sizes based on temperature and heat
	color_shift = (heat_intensity - 0.5) / 2.5  # 0.0 to 1.0
	color_shift = clamp(color_shift, 0.0, 1.0)
	
	# Update base color from red-orange to white-blue
	var base_color = Color(1.0, 0.6, 0.1).lerp(Color(0.7, 0.8, 1.0), color_shift)
	point_color = base_color
	
	# Update mesh material
	var mesh_instance = get_node_or_null("MeshInstance3D")
	if mesh_instance and mesh_instance.material_override:
		mesh_instance.material_override.albedo_color = point_color
		mesh_instance.material_override.emission = point_color
		mesh_instance.material_override.emission_energy = 1.0 + heat_intensity
	
	# Update light
	if light_node:
		light_node.light_color = point_color
		light_node.light_energy = heat_intensity * LIGHT_INTENSITY
		light_node.omni_range = light_radius * heat_intensity

# Apply water effect (called by water elements)
func apply_water_effect(intensity):
	# Reduce heat when water is applied
	heat_intensity -= intensity * 2.0
	emit_smoke_particles()
	
	# Update visuals
	update_visual_properties()
	
	# Check if fire is extinguished
	if heat_intensity <= 0.2:
		extinguish()
		return true
	
	return false

# Merge with another fire element
func merge_with(other_fire):
	if not is_instance_valid(other_fire) or other_fire.element_type != "fire":
		return false
		
	# Increase heat and size
	heat_intensity = (heat_intensity + other_fire.heat_intensity) * 0.6  # Boost when merging
	current_fuel += other_fire.current_fuel * 0.8  # Some fuel lost in merging
	scale *= 1.1
	
	# Update properties
	properties["intensity"] = heat_intensity
	properties["fuel"] = current_fuel
	
	# Update visuals
	update_visual_properties()
	
	# Transfer connections
	for connection in other_fire.connections:
		if not connections.has(connection):
			connect_to(connection)
	
	# Transfer fuel sources
	for source in other_fire.connected_fuel_sources:
		connect_to_fuel_source(source)
	
	# Remove the other fire
	other_fire.queue_free()
	return true

# Override can_transform_to from base element
func can_transform_to(target_type):
	match target_type:
		"ember":
			return heat_intensity < 0.5 and lifetime < 10.0
		"smoke":
			return heat_intensity < 0.3
		"ash":
			return lifetime < 5.0
		_:
			return false

# Override get_next_evolution from base element
func get_next_evolution():
	# Fire with high intensity and stability might evolve
	if heat_intensity > 2.5 and properties["stability"] > 0.7 and connections.size() > 4:
		# For now, we don't have a specific evolution path for fire
		# Could return a more advanced fire form here
		return null
	return null

# Override apply_environmental_forces from base element
func apply_environmental_forces(delta):
	# Fire rises
	acceleration += Vector3(0, 0.5 * heat_intensity, 0) * delta
	
	# Apply standard gravity with less effect (hot air rises)
	acceleration += Vector3(0, -0.2, 0) * delta

# Set detail level for LOD system
func set_detail_level(high_detail):
	# Try to get the resource manager from a parent element_manager
	var resource_manager = null
	var parent = get_parent()
	while parent and not resource_manager:
		if parent is ElementManager and parent.resource_manager:
			resource_manager = parent.resource_manager
		elif parent.has_node("ElementResourceManager"):
			resource_manager = parent.get_node("ElementResourceManager")
		parent = parent.get_parent()
	
	if high_detail:
		# High detail mode
		if light_node:
			if resource_manager:
				resource_manager.register_light(light_node)
			else:
				light_node.visible = true
		
		# Enable all particle systems with resource manager if available
		if has_node("FlameParticles"):
			var particles = get_node("FlameParticles")
			if resource_manager:
				if resource_manager.register_particles(particles):
					particles.amount = int(20 * heat_intensity)
			else:
				particles.emitting = true
				particles.amount = int(20 * heat_intensity)
		
		if has_node("SparkParticles"):
			var particles = get_node("SparkParticles")
			if resource_manager:
				if resource_manager.register_particles(particles):
					particles.amount = int(10 * heat_intensity)
			else:
				particles.emitting = true
				particles.amount = int(10 * heat_intensity)
			
		if has_node("SmokeParticles"):
			var particles = get_node("SmokeParticles")
			if resource_manager:
				resource_manager.register_particles(particles)
			else:
				particles.emitting = true
	else:
		# Low detail mode
		if light_node:
			if resource_manager:
				resource_manager.unregister_light(light_node)
			else:
				light_node.visible = false
			
		# Disable or reduce particle systems
		if has_node("FlameParticles"):
			var particles = get_node("FlameParticles")
			if resource_manager:
				resource_manager.unregister_particles(particles)
			else:
				particles.emitting = false
			
		if has_node("SparkParticles"):
			var particles = get_node("SparkParticles")
			if resource_manager:
				resource_manager.unregister_particles(particles)
			else:
				particles.emitting = false
			
		if has_node("SmokeParticles"):
			var particles = get_node("SmokeParticles")
			if resource_manager:
				resource_manager.unregister_particles(particles)
			else:
				particles.emitting = false
			
	# Update visual properties
	update_visual_properties()
