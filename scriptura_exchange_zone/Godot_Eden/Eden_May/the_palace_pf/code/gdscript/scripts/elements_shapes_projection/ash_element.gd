# Now let's create an ash element script that represents the final state of burned wood:

# ash_element.gd - Ash element behavior after wood burning
# Represents the remains after fire has consumed wood

# elements.gd?

extends "res://code/gdscript/scripts/elements_shapes_projection/base_element.gd"

class_name AshElement

# Ash-specific properties
var amount: float = 1.0              # How much ash is present
var density: float = 0.2             # Ash is less dense than wood
var dispersion_factor: float = 0.7   # How easily ash disperses (0-1)
var moisture_content: float = 0.0    # Moisture content affects behavior
var color: Color = Color(0.2, 0.2, 0.2, 1.0)  # Default ash color

# State tracking
var dispersing: bool = false         # Whether ash is currently dispersing
var dispersion_time: float = 0.0     # Timer for dispersion

func _init():
	element_type = "ash"
	attraction_radius = 0.5          # Ash doesn't strongly attract
	repulsion_radius = 0.2
	connection_strength = 0.3        # Weak connections
	evolution_factor = 0.0
	
func _ready():
	# Call parent ready function
	super()
	
	# Set up initial ash properties
	add_to_group("ash_elements")
	scale = Vector3(1, 0.1, 1) * amount  # Ash is flat
	
	# Update the visual appearance
	point_color = color
	
	# Update the mesh appearance
	var mesh_instance = get_node_or_null("MeshInstance3D")
	if mesh_instance and mesh_instance.material_override:
		mesh_instance.material_override.albedo_color = color

func _process(delta):
	# Handle ash behavior
	if moisture_content > 0.5:
		# Wet ash clumps together
		attraction_radius = 0.8
		connection_strength = 0.5
	else:
		# Dry ash more easily disperses
		check_dispersion(delta)
	
	# Apply environmental effects
	respond_to_environment(delta)

func check_dispersion(delta):
	# Ash can disperse over time
	if dispersing:
		dispersion_time += delta
		process_dispersion(delta)
	elif amount < 0.5 and randf() < dispersion_factor * 0.01:
		# Small amounts of ash are more likely to start dispersing
		dispersing = true

func process_dispersion(delta):
	# Handle ash dispersing
	var dispersion_rate = 0.02 * dispersion_factor * (1.0 - moisture_content * 0.8)
	
	# Reduce amount as ash disperses
	amount = max(0, amount - dispersion_rate * delta)
	
	# Scale visuals
	scale = Vector3(1, 0.1, 1) * amount
	
	# Create small particle effect for dispersing ash
	if randf() < 0.1:
		emit_ash_particles(dispersion_rate * 10)
	
	# Remove when fully dispersed
	if amount <= 0.05:
		queue_free()

# Create particle effects for ash dispersal
func emit_ash_particles(intensity):
	# Create temporary particles for ash dispersal
	var particles = GPUParticles3D.new()
	particles.name = "AshParticles"
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.randomness = 0.5
	particles.lifetime = 2.0
	particles.amount = int(10 * intensity)
	particles.process_material = create_ash_particle_material()
	
	# Add particles as child
	add_child(particles)
	
	# Remove particles after they're done
	await get_tree().create_timer(2.5).timeout
	if is_instance_valid(particles):
		particles.queue_free()

# Create material for ash particles
func create_ash_particle_material():
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.1
	material.direction = Vector3(0, 0.1, 0)
	material.spread = 45.0
	material.gravity = Vector3(0, -0.05, 0)
	material.initial_velocity_min = 0.1
	material.initial_velocity_max = 0.3
	material.damping_min = 0.1
	material.damping_max = 0.3
	material.scale_min = 0.05
	material.scale_max = 0.1
	material.color = Color(0.3, 0.3, 0.3, 0.7)
	
	return material

func apply_wind(wind_direction: Vector3, wind_strength: float):
	# Ash is strongly affected by wind
	if wind_strength > 0.2:
		# Start dispersing if wind is strong enough
		dispersing = true
		
		# Apply movement in wind direction
		var movement_factor = min(1.0, wind_strength * 2.0) * (1.0 - moisture_content * 0.7)
		global_position += wind_direction.normalized() * movement_factor * 0.1
		
		# Potentially create new smaller ash piles in wind direction
		if amount > 0.3 and randf() < wind_strength * 0.2:
			spawn_ash_trail(wind_direction, wind_strength)

func spawn_ash_trail(direction: Vector3, strength: float):
	# Create smaller ash piles as this one is blown by wind
	var trail_amount = amount * 0.1 * strength
	amount -= trail_amount
	
	# Create new ash element
	var new_ash = AshElement.new()
	new_ash.global_position = global_position + direction.normalized() * randf() * 0.5
	new_ash.amount = trail_amount
	new_ash.moisture_content = moisture_content
	new_ash.dispersing = true
	get_parent().add_child(new_ash)

func absorb_water(amount):
	# Ash can absorb water
	var old_moisture = moisture_content
	moisture_content = min(1.0, moisture_content + amount * 0.8)
	
	# Stop dispersing if wet enough
	if moisture_content > 0.7:
		dispersing = false
	
	# Return how much water was absorbed
	return (moisture_content - old_moisture) / 0.8

func respond_to_environment(delta):
	# Check if ash is on ground or floating
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = global_position + Vector3(0, 0.1, 0)
	params.to = global_position + Vector3(0, -0.2, 0)
	
	var result = space_state.intersect_ray(params)
	if not result:
		# Ash is floating, apply gravity
		global_position.y -= 0.5 * delta
	elif result.normal.y > 0.7:
		# Ash is on roughly horizontal surface, can spread out
		if connections.size() < 5 and amount > 0.5:
			spread_on_surface()

func spread_on_surface():
	# Ash spreads out on surfaces
	if randf() < 0.05:
		var spread_direction = Vector3(randf() * 2.0 - 1.0, 0, randf() * 2.0 - 1.0).normalized()
		var spread_distance = 0.3 + randf() * 0.3
		
		# Check if we can spread in that direction
		var space_state = get_world_3d().direct_space_state
		var params = PhysicsRayQueryParameters3D.new()
		params.from = global_position + Vector3(0, 0.1, 0)
		params.to = global_position + spread_direction * spread_distance
		
		var result = space_state.intersect_ray(params)
		if not result:
			# Create new ash pile in that direction
			var new_ash = AshElement.new()
			new_ash.global_position = global_position + spread_direction * spread_distance
			new_ash.amount = amount * 0.3
			new_ash.moisture_content = moisture_content
			get_parent().add_child(new_ash)
			
			# Connect to the new ash
			connections.append(new_ash)
			new_ash.connections.append(self)
			
			# Reduce this pile's amount
			amount *= 0.7
			scale = Vector3(1, 0.1, 1) * amount

func combine_with(other_ash):
	# Ash piles can combine
	if other_ash.element_type == "ash":
		# Add properties
		amount += other_ash.amount
		moisture_content = (moisture_content + other_ash.moisture_content) / 2.0
		
		# Update scale
		scale = Vector3(1, 0.1, 1) * amount
		
		# Add connections
		for connection in other_ash.connections:
			if connection != self and not connections.has(connection):
				connections.append(connection)
				if connection.has_method("replace_connection"):
					connection.replace_connection(other_ash, self)
		
		# Remove the
