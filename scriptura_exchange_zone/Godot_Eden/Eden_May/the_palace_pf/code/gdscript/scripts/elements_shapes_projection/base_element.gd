# base_element.gd
# Base class for all elements in the system
extends Node3D

# Core properties
var element_type = "generic"
var properties = {}
var connections = []
var parent = null

# Physical properties
var attraction_radius = 10.0
var repulsion_radius = 2.0
var connection_strength = 1.0
var evolution_factor = 0.0
var mass = 1.0

# Visual properties
var point_size = 0.5
var point_color = Color.WHITE
var connection_color = Color.GRAY

# Point mesh for visualization
var point_mesh
var connection_material

# Dictionary for tracking interactions
var interaction_history = {}

# Animation properties
var target_position = Vector3.ZERO
var velocity = Vector3.ZERO
var acceleration = Vector3.ZERO

# Initialize the element
func _ready():
	# Create visual representation
	point_mesh = SphereMesh.new()
	point_mesh.radius = point_size
	point_mesh.height = point_size * 2
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = point_mesh
	
	# Create material for the point
	var material = StandardMaterial3D.new()
	material.albedo_color = point_color
	material.emission_enabled = true
	material.emission = point_color
	material.emission_energy = 0.5
	
	mesh_instance.material_override = material
	add_child(mesh_instance)
	
	# Initialize default properties based on element type
	initialize_properties()
	
	# Set up physics interaction area
	create_interaction_area()

# Initialize default properties based on element type
func initialize_properties():
	# Default properties - override in child classes
	properties = {
		"age": 0.0,
		"stability": 1.0,
		"energy": 1.0,
		"evolution_progress": 0.0,
	}

# Create an Area3D for interaction detection
func create_interaction_area():
	var area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = attraction_radius
	
	collision_shape.shape = sphere_shape
	area.add_child(collision_shape)
	add_child(area)
	
	# Connect signals
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))
	area.connect("area_entered", Callable(self, "_on_area_entered"))
	area.connect("area_exited", Callable(self, "_on_area_exited"))

# Process element behavior - override in child classes
func process_behavior(delta):
	# Make sure properties dictionary is initialized before use
	if not properties.has("age"):
		initialize_properties()
		
	# Age the element
	properties["age"] += delta
	
	# Update physical properties
	process_physics(delta)
	
	# Check connections
	maintain_connections()
	
	# Check for evolution
	check_evolution()
	
	# Element-specific behavior (override in child classes)
	custom_behavior(delta)

# Process physics for the element
func process_physics(delta):
	# Apply forces from connections
	acceleration = Vector3.ZERO
	
	for connection in connections:
		if is_instance_valid(connection):
			var direction = connection.global_position - global_position
			var distance = direction.length()
			
			# Skip if too far
			if distance > attraction_radius * 2:
				continue
				
			direction = direction.normalized()
			
			# Calculate force based on distance
			var force = Vector3.ZERO
			
			if distance < repulsion_radius:
				# Repulsion at close range
				force = -direction * (1.0 - distance / repulsion_radius) * 10.0
			elif distance < attraction_radius:
				# Attraction at medium range
				force = direction * (1.0 - distance / attraction_radius) * connection_strength
			
			acceleration += force / mass
	
	# Apply environmental forces (gravity, etc.)
	apply_environmental_forces(delta)
	
	# Update velocity and position
	velocity += acceleration * delta
	
	# Apply damping
	velocity *= 0.95
	
	# Update position
	global_position += velocity * delta

# Apply environmental forces - override in child classes
func apply_environmental_forces(delta):
	# Default has a small gravity
	acceleration += Vector3(0, -0.1, 0)

# Custom behavior - override in child classes
func custom_behavior(delta):
	pass

# Maintain connections between elements
func maintain_connections():
	var connections_to_remove = []
	
	for connection in connections:
		if not is_instance_valid(connection):
			connections_to_remove.append(connection)
			continue
			
		# Check if connection is still valid (within range)
		var distance = global_position.distance_to(connection.global_position)
		if distance > attraction_radius * 2:
			connections_to_remove.append(connection)
			continue
			
		# Visualize connection
		draw_connection(connection)
	
	# Remove invalid connections
	for connection in connections_to_remove:
		connections.erase(connection)

# Connect to another element
func connect_to(other_element):
	if not connections.has(other_element) and other_element != self:
		connections.append(other_element)
		
		# Reciprocal connection
		if not other_element.connections.has(self):
			other_element.connect_to(self)
		
		# Track interaction
		if not interaction_history.has(other_element.element_type):
			interaction_history[other_element.element_type] = 0
		
		interaction_history[other_element.element_type] += 1

# Draw a visual connection to another element
func draw_connection(other_element):
	if not is_instance_valid(other_element):
		return
		
	# In a real implementation, this would create a line mesh
	var start = global_position
	var end = other_element.global_position
	
	# Create a CSG line between the two points
	var line = CSGCylinder3D.new()
	line.radius = 0.05
	line.material = StandardMaterial3D.new()
	line.material.albedo_color = connection_color
	
	# Calculate cylinder position, height and rotation
	var midpoint = (start + end) / 2
	var height = start.distance_to(end)
	
	line.height = height
	line.global_position = midpoint
	
	# Calculate the rotation to point the cylinder from start to end
	var direction = (end - start).normalized()
	line.look_at_from_position(midpoint, end, Vector3.UP)
	
	# Add to scene with a unique name
	line.name = "Connection_" + str(get_instance_id()) + "_" + str(other_element.get_instance_id())
	add_child(line)
	
	# Store reference to clean up later if needed
	if not has_meta("connections_visuals"):
		set_meta("connections_visuals", {})

# Check if the element should evolve
func check_evolution():
	# Calculate evolution progress based on age, connections, etc.
	var evolution_base = properties["age"] / 100.0  # Base evolution from age
	var connection_bonus = connections.size() * 0.01  # Bonus from connections
	
	# Increase evolution factor
	evolution_factor = evolution_base + connection_bonus
	properties["evolution_progress"] = evolution_factor
	
	# Check if element should evolve
	if evolution_factor >= 1.0:
		evolve()

# Evolve to the next form
func evolve():
	# Get the next evolution form
	var next_form = get_next_evolution()
	
	if next_form:
		# Create the evolved form at the same position
		var evolved = next_form.new()
		evolved.global_position = global_position
		evolved.element_type = next_form.element_type
		
		# Transfer connections to the evolved form
		for connection in connections:
			if is_instance_valid(connection):
				evolved.connect_to(connection)
				
				# Update the other element's connection
				var idx = connection.connections.find(self)
				if idx >= 0:
					connection.connections[idx] = evolved
		
		# Add to the scene
		get_parent().add_child(evolved)
		
		# Remove the old form
		queue_free()

# Get the next evolution form - override in child classes
func get_next_evolution():
	return null  # Default has no evolution

# Called when another body enters the interaction area
func _on_body_entered(body):
	if body != self and body.has_method("connect_to"):
		connect_to(body)

# Called when another area enters the interaction area
func _on_area_entered(area):
	var parent = area.get_parent()
	if parent != self and parent.has_method("connect_to"):
		connect_to(parent)

# Called when another body exits the interaction area
func _on_body_exited(body):
	pass

# Called when another area exits the interaction area
func _on_area_exited(area):
	pass

# Combine with another element of the same type
func combine_with(other_element):
	if other_element.element_type != element_type:
		return false
		
	# Base implementation - can be overridden in child classes
	# Merge properties
	for key in other_element.properties:
		if properties.has(key):
			properties[key] = (properties[key] + other_element.properties[key]) / 2.0
		else:
			properties[key] = other_element.properties[key]
	
	# Increase size
	scale *= 1.1
	
	# Increase mass
	mass += other_element.mass
	
	# Absorb connections
	for connection in other_element.connections:
		if connection != self and not connections.has(connection):
			connections.append(connection)
			
			# Update the other element's connection
			var idx = connection.connections.find(other_element)
			if idx >= 0:
				connection.connections[idx] = self
	
	# Remove the other element
	other_element.queue_free()
	return true

# Split into multiple smaller elements
func split():
	# Base implementation - can be overridden in child classes
	if scale.x < 1.2:
		return []  # Too small to split
	
	var new_elements = []
	var new_scale = scale / 2.0
	
	# Create new elements
	for i in range(2):
		var new_element = get_script().new()
		new_element.element_type = element_type
		new_element.scale = new_scale
		new_element.mass = mass / 2.0
		
		# Transfer properties
		for key in properties:
			new_element.properties[key] = properties[key]
		
		# Set position with slight offset
		var offset = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized() * scale.x
		
		new_element.global_position = global_position + offset
		
		# Distribute connections
		for j in range(connections.size()):
			if j % 2 == i and is_instance_valid(connections[j]):
				new_element.connect_to(connections[j])
		
		# Add to the scene
		get_parent().add_child(new_element)
		new_elements.append(new_element)
	
	# Remove the original element
	queue_free()
	return new_elements

# Archive the element to storage
func archive():
	# Get element data
	var element_data = {
		"type": element_type,
		"position": {
			"x": global_position.x,
			"y": global_position.y,
			"z": global_position.z
		},
		"scale": {
			"x": scale.x,
			"y": scale.y,
			"z": scale.z
		},
		"properties": properties,
		"connections": []
	}
	
	# Save connections
	for connection in connections:
		if is_instance_valid(connection):
			element_data["connections"].append({
				"id": connection.get_instance_id(),
				"type": connection.element_type
			})
	
	# Add to archive - using user:// for user data
	var archive_path = "user://akashic_records/elements/%s_%d.json" % [element_type, get_instance_id()]
	save_json_file(archive_path, element_data)
	
	# Remove from scene
	queue_free()
	
	return archive_path

# Helper to save JSON
func save_json_file(path, data):
	var dir_path = path.get_base_dir()
	
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "  "))
		file.close()

# Replace a connection with another element
func replace_connection(old_element, new_element):
	var idx = connections.find(old_element)
	if idx >= 0:
		connections[idx] = new_element

# Apply an external force to this element
func apply_force(force):
	acceleration += force / mass

# Check if this element can transform into another type
func can_transform_to(target_type):
	# Default implementation - override in child classes
	return false

# Get transformation cost to target type
func transformation_cost(target_type):
	# Default implementation - override in child classes  
	return 1.0

# Transform this element into another type
func transform_to(target_type):
	if not can_transform_to(target_type):
		return null
	
	# Create the new element
	var new_script = load("res://code/gdscript/scripts/elements_shapes_projection/%s_element.gd" % target_type)
	if new_script:
		var new_element = new_script.new()
		new_element.global_position = global_position
		new_element.scale = scale
		new_element.mass = mass
		
		# Transfer connections
		for connection in connections:
			if is_instance_valid(connection):
				new_element.connect_to(connection)
				
				# Update the other element's connection
				var idx = connection.connections.find(self)
				if idx >= 0:
					connection.connections[idx] = new_element
		
		# Add to the scene
		get_parent().add_child(new_element)
		
		# Remove the old form
		queue_free()
		
		return new_element
	
	return null
