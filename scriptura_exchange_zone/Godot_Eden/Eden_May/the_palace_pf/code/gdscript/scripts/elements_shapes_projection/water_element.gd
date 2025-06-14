# water_element.gd - Water element behavior and properties
# Claude Decipher: Water elements with fluid properties, surface tension, waves,
# and interactions with other elements

extends "res://code/gdscript/scripts/elements_shapes_projection/base_element.gd"

class_name WaterElement

# Water-specific properties
var surface_tension: float = 0.8     # How strongly water points stick together
var flow_speed: float = 1.2          # How quickly water moves along surfaces
var wave_frequency: float = 0.5      # For wave-like motions
var wave_amplitude: float = 0.2      # Height of waves
var evaporation_chance: float = 0.001 # Chance to transform to vapor
var freeze_threshold: float = 0.0    # Temperature below which water freezes
var depth: float = 1.0               # Simulated depth of water
var clarity: float = 0.8             # How clear/transparent the water is

# Environment awareness
var terrain_normal: Vector3 = Vector3.UP  # Surface normal the water is on
var container_shape = null                # Reference to shape containing this water
var has_gravity: bool = true              # Whether this water responds to gravity

# Moon force (for tides)
var moon_influence: float = 0.0
var moon_position: Vector3 = Vector3.ZERO
var tide_height: float = 0.0
var tide_cycle: float = 0.0

# Water state tracking
var state = "liquid"  # Can be "liquid", "vapor", "ice"
var temperature: float = 20.0  # Celsius
var purity: float = 1.0        # How pure the water is (affects behavior)
var contained_elements = []    # Elements contained within this water

func _init():
	element_type = "water"
	# Adjust base element properties for water
	attraction_radius = 2.0
	repulsion_radius = 0.3
	connection_strength = 0.7
	evolution_factor = 0.0
	mass = 1.0
	
	# Set water-specific visual properties
	point_color = Color(0.3, 0.5, 0.9, 0.7)  # Blue with transparency
	connection_color = Color(0.4, 0.6, 1.0, 0.3)  # Light blue with high transparency

func _ready():
	# Call parent ready function
	super()
	
	# Add to water group for specialized processing
	add_to_group("water_elements")
	
	# Initialize wave movement
	initialize_wave_movement()

func initialize_wave_movement():
	# Create a randomized starting phase for this water point
	tide_cycle = randf() * TAU  # Random initial phase

func _process(delta):
	# Update water behavior
	process_wave_movement(delta)
	apply_surface_tension(delta)
	check_temperature_effects(delta)
	
	# Update tide cycle
	tide_cycle += delta * wave_frequency
	tide_height = sin(tide_cycle) * wave_amplitude

func process_behavior(delta):
	# Call parent behavior processing
	super.process_behavior(delta)
	
	# Water-specific behavior
	flow_with_gravity(delta)
	maintain_surface_tension(delta)
	interact_with_surroundings(delta)
	create_waves(delta)
	check_state_transitions(delta)

# Process wave-like movement
func process_wave_movement(delta):
	# Create gentle oscillation for water surface
	if state == "liquid":
		var wave_offset = Vector3(0, sin(tide_cycle) * wave_amplitude, 0)
		acceleration += wave_offset * delta

# Apply surface tension forces
func apply_surface_tension(delta):
	if state != "liquid":
		return
		
	for connection in connections:
		if not is_instance_valid(connection):
			continue
			
		if connection.element_type == "water":
			var distance = global_position.distance_to(connection.global_position)
			
			# Apply stronger cohesion for water-to-water connections
			if distance > repulsion_radius * 1.5 and distance < attraction_radius:
				var direction = (connection.global_position - global_position).normalized()
				acceleration += direction * surface_tension * delta

# Check temperature effects
func check_temperature_effects(delta):
	# Update temperature based on environment and nearby elements
	update_temperature(delta)
	
	# Check for state changes
	if temperature <= freeze_threshold and state == "liquid":
		change_state_to("ice")
	elif temperature >= 100.0 and state == "liquid":
		if randf() < evaporation_chance * delta * (temperature - 95) / 5.0:
			change_state_to("vapor")
	elif temperature > freeze_threshold + 5.0 and state == "ice":
		change_state_to("liquid")
	elif temperature < 95.0 and state == "vapor":
		if randf() < 0.01 * delta:
			change_state_to("liquid")  # Condensation

# Update temperature based on surroundings
func update_temperature(delta):
	var temp_change = 0.0
	
	# Adjust temperature based on nearby elements
	for connection in connections:
		if not is_instance_valid(connection):
			continue
			
		var distance = global_position.distance_to(connection.global_position)
		var influence = 1.0 - min(distance / attraction_radius, 1.0)
		
		match connection.element_type:
			"fire":
				temp_change += influence * 10.0 * delta
			"ice":
				temp_change -= influence * 5.0 * delta
			"water":
				# Water normalizes toward the average temperature of connected water
				if connection.has_method("get_temperature"):
					var temp_diff = connection.get_temperature() - temperature
					temp_change += temp_diff * 0.1 * delta
	
	# Apply temperature change
	temperature += temp_change

# Change water state
func change_state_to(new_state):
	if state == new_state:
		return
		
	state = new_state
	
	# Update visual properties based on new state
	match state:
		"liquid":
			point_color = Color(0.3, 0.5, 0.9, 0.7)
			mass = 1.0
			connection_strength = 0.7
		"ice":
			point_color = Color(0.8, 0.9, 1.0, 0.9)
			mass = 1.5
			connection_strength = 1.2
		"vapor":
			point_color = Color(0.7, 0.7, 1.0, 0.3)
			mass = 0.3
			connection_strength = 0.2
	
	# Apply updated visual properties
	update_visual_properties()

# Update visual properties based on current state
func update_visual_properties():
	if not is_instance_valid(point_mesh):
		return
		
	var mesh_instance = get_node_or_null("MeshInstance3D")
	if mesh_instance and mesh_instance.material_override:
		mesh_instance.material_override.albedo_color = point_color
		
		if state == "liquid" or state == "vapor":
			mesh_instance.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		else:
			mesh_instance.material_override.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED

# Flow with gravity
func flow_with_gravity(delta):
	if state == "liquid" and has_gravity:
		var gravity_force = Vector3(0, -9.8 * mass, 0)
		acceleration += gravity_force * delta * flow_speed
		
		# If on a surface, flow along the surface
		if terrain_normal != Vector3.UP:
			var slide_direction = Vector3.DOWN.slide(terrain_normal).normalized()
			acceleration += slide_direction * flow_speed * delta

# Maintain surface tension between water elements
func maintain_surface_tension(delta):
	if state != "liquid":
		return
		
	var tension_force = Vector3.ZERO
	var water_neighbors = 0
	
	for connection in connections:
		if not is_instance_valid(connection):
			continue
			
		if connection.element_type == "water":
			water_neighbors += 1
			var distance = global_position.distance_to(connection.global_position)
			var ideal_distance = (repulsion_radius + attraction_radius) / 3.0
			
			var difference = ideal_distance - distance
			var direction = (connection.global_position - global_position).normalized()
			
			# Create stabilizing force to maintain ideal water spacing
			tension_force += direction * difference * surface_tension
	
	# Apply more surface tension when connecting to fewer water elements (surface)
	if water_neighbors > 0:
		var surface_multiplier = 1.0 + (6.0 - min(water_neighbors, 6.0)) / 6.0
		acceleration += tension_force * delta * surface_multiplier

# Create wave motions
func create_waves(delta):
	if state == "liquid":
		# Create gentle oscillation
		var time_offset = Time.get_ticks_msec() / 1000.0 + global_position.length()
		var wave_y = sin(time_offset * wave_frequency) * wave_amplitude
		
		# Apply moon influence (tides)
		var moon_distance = global_position.distance_to(moon_position) 
		if moon_distance > 0:
			var moon_direction = (moon_position - global_position).normalized()
			var moon_force = moon_direction * (moon_influence / max(1.0, moon_distance))
			acceleration += moon_force * delta
		
		# Apply wave motion
		acceleration.y += wave_y * delta

# Interact with surroundings
func interact_with_surroundings(delta):
	for connection in connections:
		if not is_instance_valid(connection):
			continue
			
		# Specific interactions based on element type
		match connection.element_type:
			"fire":
				# Water can extinguish fire if enough water is present
				var distance = global_position.distance_to(connection.global_position)
				if distance < repulsion_radius * 2 and state == "liquid":
					if connection.has_method("apply_water_effect"):
						connection.apply_water_effect(delta * 0.5)
					temperature += delta * 2.0  # Water heats up when extinguishing fire
			
			"wood":
				# Water can be absorbed by wood
				if state == "liquid" and randf() < 0.01 * delta:
					if connection.has_method("absorb_water"):
						connection.absorb_water(delta)
			
			"earth":
				# Water can erode earth over time
				if state == "liquid" and flow_speed > 0.5:
					if connection.has_method("erode"):
						connection.erode(delta * flow_speed * 0.1)

# Check for state transitions
func check_state_transitions(delta):
	# Already handled in check_temperature_effects, but could add more complex transitions here
	pass

# Override the apply_environmental_forces from base element
func apply_environmental_forces(delta):
	if state == "liquid":
		# Liquid water has full gravity
		acceleration += Vector3(0, -9.8, 0) * delta
	elif state == "vapor":
		# Vapor rises
		acceleration += Vector3(0, 0.5, 0) * delta
	elif state == "ice":
		# Ice has strong gravity
		acceleration += Vector3(0, -9.8, 0) * delta * 1.2

# Get current temperature
func get_temperature():
	return temperature

# Get current water state
func get_state():
	return state

# Absorb another water element to increase size
func absorb(other_water):
	if not is_instance_valid(other_water) or other_water.element_type != "water":
		return false
		
	# Increase size based on other water's mass
	mass += other_water.mass * 0.8
	point_size = 0.5 * pow(mass, 1/3.0)  # Scale size based on mass
	
	# Update visual representation
	update_visual_size()
	
	# Transfer connections
	for connection in other_water.connections:
		if connection != self and not connections.has(connection):
			connect_to(connection)
	
	# Remove the other water
	other_water.queue_free()
	return true

# Update the visual size of the water element
func update_visual_size():
	if not is_instance_valid(point_mesh):
		return
		
	point_mesh.radius = point_size
	point_mesh.height = point_size * 2

# Override the split function to create smaller water droplets
func split():
	if mass < 1.2:
		return []  # Too small to split
		
	var droplets = []
	var num_droplets = 2 + (randi() % 3)  # 2-4 droplets
	var new_mass = mass / num_droplets
	
	for i in range(num_droplets):
		var droplet = get_script().new()
		droplet.element_type = "water"
		droplet.state = state
		droplet.temperature = temperature
		droplet.mass = new_mass
		droplet.point_size = 0.5 * pow(new_mass, 1/3.0)
		
		# Randomize position slightly
		var offset = Vector3(
			randf_range(-0.5, 0.5),
			randf_range(0, 0.5),
			randf_range(-0.5, 0.5)
		) * point_size * 2
		
		droplet.global_position = global_position + offset
		
		# Connect to nearby elements
		for connection in connections:
			if randf() < 0.3:  # Only some connections transfer to each droplet
				droplet.connect_to(connection)
		
		# Add to scene
		get_parent().add_child(droplet)
		droplets.append(droplet)
	
	# Remove original
	queue_free()
	return droplets

# Water can transform to ice or vapor
func can_transform_to(target_type):
	match target_type:
		"ice":
			return temperature <= freeze_threshold
		"vapor":
			return temperature >= 95.0
		_:
			return false

# Override get_next_evolution to allow water to evolve into more complex forms
func get_next_evolution():
	# Water with high purity and stable connections might evolve
	if purity > 0.9 and properties["stability"] > 0.8 and connections.size() > 5:
		# Could return a more advanced water form here
		pass
	return null
	
# Set detail level for LOD system
func set_detail_level(high_detail):
	if high_detail:
		# High detail mode - enable all visual effects
		
		# Enable wave movement
		wave_amplitude = 0.2
		
		# Update visual properties with full transparency and effects
		var mesh_instance = get_node_or_null("MeshInstance3D")
		if mesh_instance and mesh_instance.material_override:
			mesh_instance.material_override.albedo_color = point_color
			mesh_instance.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mesh_instance.material_override.roughness = 0.1  # More reflective
	else:
		# Low detail mode - disable complex visual effects
		
		# Reduce or disable wave movement
		wave_amplitude = 0.0
		
		# Simplify visual properties
		var mesh_instance = get_node_or_null("MeshInstance3D")
		if mesh_instance and mesh_instance.material_override:
			mesh_instance.material_override.albedo_color = point_color
			mesh_instance.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mesh_instance.material_override.roughness = 0.5  # Less reflective/detailed