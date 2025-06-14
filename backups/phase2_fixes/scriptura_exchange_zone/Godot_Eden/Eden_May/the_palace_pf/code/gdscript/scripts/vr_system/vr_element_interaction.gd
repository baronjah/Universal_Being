extends Node3D
class_name VRElementInteraction

# References to other systems
var vr_manager = null
var akashic_records = null
var elements_container: Node3D

# Element visualization
var element_scenes = {
	"fire": preload("res://code/gdscript/scripts/elements_shapes_projection/element_fire.tscn") if File.new().file_exists("res://code/gdscript/scripts/elements_shapes_projection/element_fire.tscn") else null,
	"water": preload("res://code/gdscript/scripts/elements_shapes_projection/element_water.tscn") if File.new().file_exists("res://code/gdscript/scripts/elements_shapes_projection/element_water.tscn") else null,
	"wood": preload("res://code/gdscript/scripts/elements_shapes_projection/element_wood.tscn") if File.new().file_exists("res://code/gdscript/scripts/elements_shapes_projection/element_wood.tscn") else null,
	"ash": preload("res://code/gdscript/scripts/elements_shapes_projection/element_ash.tscn") if File.new().file_exists("res://code/gdscript/scripts/elements_shapes_projection/element_ash.tscn") else null
}

# Interaction state
var selected_element = null
var grabbed_element = null
var grabbing_controller = null
var element_entities = {}
var last_interaction_time = 0
var interaction_cooldown = 0.5

# Physics settings
var physics_enabled = true
var physics_strength = 1.0
var gravity_strength = 0.1
var interaction_radius = 0.5

# Element generation
var can_generate_elements = true
var generation_cooldown = 1.0
var last_generation_time = 0

# Particle effects
var interaction_effect_scene = null
var transformation_effect_scene = null

# Initialize the VR element interaction system
func _ready():
	print("Initializing VR Element Interaction system...")
	
	# Create elements container
	elements_container = Node3D.new()
	elements_container.name = "Elements"
	add_child(elements_container)
	
	# Get manager references
	vr_manager = VRManager.get_instance()
	akashic_records = AkashicRecordsManager.get_instance()
	
	# Ensure Akashic Records is initialized
	if not akashic_records.is_initialized:
		akashic_records.initialize()
	
	# Connect signals
	if vr_manager:
		vr_manager.connect("interaction_triggered", Callable(self, "_on_vr_interaction"))
		vr_manager.connect("controller_gesture_detected", Callable(self, "_on_controller_gesture"))
	
	if akashic_records:
		akashic_records.connect("interaction_processed", Callable(self, "_on_interaction_processed"))
	
	# Load particle effects
	_load_effect_resources()
	
	# Create default elements for testing
	call_deferred("_create_initial_elements")
	
	print("VR Element Interaction system initialized")

# Load effect resources
func _load_effect_resources():
	# Check if effect scenes exist and load them
	if File.new().file_exists("res://code/gdscript/scripts/elements_shapes_projection/interaction_effect.tscn"):
		interaction_effect_scene = load("res://code/gdscript/scripts/elements_shapes_projection/interaction_effect.tscn")
	
	if File.new().file_exists("res://code/gdscript/scripts/elements_shapes_projection/transformation_effect.tscn"):
		transformation_effect_scene = load("res://code/gdscript/scripts/elements_shapes_projection/transformation_effect.tscn")

# Create initial set of elements for testing
func _create_initial_elements():
	# Create a few elements of each type
	_create_element("fire", Vector3(-0.5, 1.0, -1.0))
	_create_element("water", Vector3(0.5, 1.0, -1.0))
	_create_element("wood", Vector3(-0.5, 1.5, -1.0))
	_create_element("ash", Vector3(0.5, 1.5, -1.0))

# Create an element in the world
func _create_element(element_type: String, position: Vector3):
	# Check if we have a scene for this element type
	if not element_scenes.has(element_type) or not element_scenes[element_type]:
		_create_fallback_element(element_type, position)
		return
	
	# Instantiate the element scene
	var element_instance = element_scenes[element_type].instantiate()
	element_instance.name = "Element_" + element_type + "_" + str(randi() % 1000)
	
	# Position the element
	element_instance.global_position = position
	
	# Add physics if needed
	_ensure_physics_body(element_instance, element_type)
	
	# Add element to the container
	elements_container.add_child(element_instance)
	
	# Register with Akashic Records
	var entity_id = _register_element_entity(element_instance, element_type, position)
	element_instance.set_meta("entity_id", entity_id)
	element_instance.set_meta("element_type", element_type)
	
	# Store in our local tracking
	element_entities[entity_id] = element_instance
	
	print("Created element: " + element_type + " at " + str(position))
	return element_instance

# Create a fallback element when a scene doesn't exist
func _create_fallback_element(element_type: String, position: Vector3):
	# Create a simple sphere to represent the element
	var element_node = Node3D.new()
	element_node.name = "Element_" + element_type + "_" + str(randi() % 1000)
	
	# Create a mesh instance
	var mesh_instance = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.2
	sphere.height = 0.4
	mesh_instance.mesh = sphere
	
	# Apply a material based on element type
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	match element_type:
		"fire":
			material.albedo_color = Color(1.0, 0.4, 0.1, 0.8)
			material.emission_enabled = true
			material.emission = Color(1.0, 0.3, 0.1)
		"water":
			material.albedo_color = Color(0.1, 0.4, 1.0, 0.8)
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		"wood":
			material.albedo_color = Color(0.4, 0.3, 0.1, 1.0)
		"ash":
			material.albedo_color = Color(0.7, 0.7, 0.7, 1.0)
	
	mesh_instance.material_override = material
	element_node.add_child(mesh_instance)
	
	# Add physics
	_ensure_physics_body(element_node, element_type)
	
	# Position the element
	element_node.global_position = position
	
	# Add element to the container
	elements_container.add_child(element_node)
	
	# Register with Akashic Records
	var entity_id = _register_element_entity(element_node, element_type, position)
	element_node.set_meta("entity_id", entity_id)
	element_node.set_meta("element_type", element_type)
	
	# Store in our local tracking
	element_entities[entity_id] = element_node
	
	print("Created fallback element: " + element_type + " at " + str(position))
	return element_node

# Ensure the element has a physics body
func _ensure_physics_body(element_node: Node3D, element_type: String):
	# Check if there's already a physics body
	var has_physics = false
	for child in element_node.get_children():
		if child is RigidBody3D:
			has_physics = true
			break
	
	if not has_physics:
		# Create a rigid body for physics
		var rigid_body = RigidBody3D.new()
		rigid_body.name = "ElementBody"
		rigid_body.mass = _get_element_mass(element_type)
		rigid_body.gravity_scale = _get_element_gravity(element_type)
		rigid_body.continuous_cd = true
		rigid_body.max_contacts_reported = 4
		rigid_body.contact_monitor = true
		rigid_body.connect("body_entered", Callable(self, "_on_element_collision").bind(element_node))
		
		# Create collision shape
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = 0.2
		collision_shape.shape = sphere_shape
		rigid_body.add_child(collision_shape)
		
		# Move existing children to the rigid body
		var children = element_node.get_children().duplicate()
		for child in children:
			if not child is RigidBody3D:
				element_node.remove_child(child)
				rigid_body.add_child(child)
		
		element_node.add_child(rigid_body)

# Get mass for an element type
func _get_element_mass(element_type: String) -> float:
	match element_type:
		"fire": return 0.3
		"water": return 1.0
		"wood": return 0.8
		"ash": return 0.2
	return 0.5

# Get gravity scale for an element type
func _get_element_gravity(element_type: String) -> float:
	match element_type:
		"fire": return -0.1  # Slight upward movement
		"water": return 1.2
		"wood": return 1.0
		"ash": return 0.3
	return 1.0

# Register an element with the Akashic Records system
func _register_element_entity(element_node: Node3D, element_type: String, position: Vector3) -> String:
	if not akashic_records.is_initialized:
		return ""
	
	# Generate a unique ID
	var entity_id = "element_" + element_type + "_" + str(randi() % 10000)
	
	# Create properties based on element type
	var properties = {}
	
	match element_type:
		"fire":
			properties = {
				"temperature": 800.0,
				"light": 0.8,
				"spread": 0.5
			}
		"water":
			properties = {
				"flow": 0.8,
				"transparency": 0.7,
				"temperature": 20.0
			}
		"wood":
			properties = {
				"growth": 0.2,
				"hardness": 0.6,
				"flammability": 0.7
			}
		"ash":
			properties = {
				"fertility": 0.6,
				"lightness": 0.3
			}
	
	# Register the entity
	akashic_records.create_entity(entity_id, element_type, position, properties)
	
	return entity_id

# Process function for ongoing element updates
func _process(delta):
	# Update element positions in the Akashic Records
	_update_element_positions()
	
	# Update element interactions
	if physics_enabled:
		_update_element_physics(delta)
	
	# Check if we can generate new elements
	if can_generate_elements:
		_check_element_generation(delta)

# Update element positions in the Akashic Records
func _update_element_positions():
	for entity_id in element_entities:
		var element_node = element_entities[entity_id]
		if element_node and is_instance_valid(element_node):
			akashic_records.update_entity_position(entity_id, element_node.global_position)

# Update physics interactions between elements
func _update_element_physics(delta):
	# Apply physics interactions between similar elements
	for entity_id1 in element_entities:
		var element1 = element_entities[entity_id1]
		if not element1 or not is_instance_valid(element1):
			continue
			
		var type1 = element1.get_meta("element_type") if element1.has_meta("element_type") else ""
		
		for entity_id2 in element_entities:
			if entity_id1 == entity_id2:
				continue
				
			var element2 = element_entities[entity_id2]
			if not element2 or not is_instance_valid(element2):
				continue
				
			var type2 = element2.get_meta("element_type") if element2.has_meta("element_type") else ""
			var distance = element1.global_position.distance_to(element2.global_position)
			
			if distance < interaction_radius:
				_apply_element_force(element1, element2, type1, type2, distance, delta)

# Apply forces between elements based on type
func _apply_element_force(element1, element2, type1, type2, distance, delta):
	var body1 = _get_rigid_body(element1)
	var body2 = _get_rigid_body(element2)
	
	if not body1 or not body2:
		return
		
	var direction = (element1.global_position - element2.global_position).normalized()
	var force_strength = 0.0
	
	# Apply different forces based on element combinations
	if type1 == type2:
		# Same types generally attract weakly
		force_strength = -0.1
	else:
		match [type1, type2]:
			["fire", "wood"]:
				# Fire consumes wood
				force_strength = -0.5
			["wood", "fire"]:
				# Wood gets consumed by fire
				force_strength = -0.5
			["water", "fire"]:
				# Water extinguishes fire
				force_strength = -0.4
			["fire", "water"]:
				# Fire gets extinguished by water
				force_strength = 0.8
			["water", "ash"]:
				# Water and ash create mud
				force_strength = -0.3
			["ash", "water"]:
				# Ash and water create mud
				force_strength = -0.3
			_:
				# Default slight repulsion
				force_strength = 0.1
	
	# Scale by physics strength and distance
	var scaled_force = direction * force_strength * physics_strength * (1.0 - distance / interaction_radius)
	
	# Apply the force
	body1.apply_central_force(scaled_force * delta * 50.0)
	body2.apply_central_force(-scaled_force * delta * 50.0)

# Get the rigid body from an element node
func _get_rigid_body(element_node):
	if element_node is RigidBody3D:
		return element_node
		
	for child in element_node.get_children():
		if child is RigidBody3D:
			return child
			
	return null

# Check for element generation
func _check_element_generation(delta):
	if Time.get_ticks_msec() - last_generation_time < generation_cooldown * 1000:
		return
		
	# Look for opportunities to generate new elements
	for entity_id1 in element_entities:
		var element1 = element_entities[entity_id1]
		if not element1 or not is_instance_valid(element1):
			continue
			
		var type1 = element1.get_meta("element_type") if element1.has_meta("element_type") else ""
		
		for entity_id2 in element_entities:
			if entity_id1 == entity_id2:
				continue
				
			var element2 = element_entities[entity_id2]
			if not element2 or not is_instance_valid(element2):
				continue
				
			var type2 = element2.get_meta("element_type") if element2.has_meta("element_type") else ""
			var distance = element1.global_position.distance_to(element2.global_position)
			
			if distance < interaction_radius * 0.5:
				var new_element = _check_transformation(element1, element2, type1, type2)
				if new_element:
					last_generation_time = Time.get_ticks_msec()
					return

# Check for transformations between elements
func _check_transformation(element1, element2, type1, type2):
	if type1 == type2:
		return null
		
	var result_type = ""
	var should_remove_source = false
	
	match [type1, type2]:
		["fire", "wood"], ["wood", "fire"]:
			result_type = "ash"
			should_remove_source = true
		["water", "fire"], ["fire", "water"]:
			result_type = "water"  # Water wins
			should_remove_source = true
		_:
			return null
			
	# Process the transformation in the Akashic Records first
	var entity_id1 = element1.get_meta("entity_id") if element1.has_meta("entity_id") else ""
	var entity_id2 = element2.get_meta("entity_id") if element2.has_meta("entity_id") else ""
	
	if entity_id1 and entity_id2:
		var result = akashic_records.process_entity_interaction(entity_id1, entity_id2)
		
		# If the Akashic Records has a different result, use that
		if result.success and result.has("result") and result.result == "create":
			if result.has("data") and result.data.has("new_word_id") and result.data.has("new_word_data"):
				result_type = result.data.new_word_data.get("type", result_type)
	
	# Create the new element
	var midpoint = (element1.global_position + element2.global_position) / 2
	var new_element = _create_element(result_type, midpoint)
	
	# Create a transformation effect
	if transformation_effect_scene:
		var effect = transformation_effect_scene.instantiate()
		effect.global_position = midpoint
		add_child(effect)
		effect.emitting = true
	
	# Remove source elements if needed
	if should_remove_source:
		if entity_id1:
			akashic_records.remove_entity(entity_id1)
			element_entities.erase(entity_id1)
			element1.queue_free()
		
		if entity_id2:
			akashic_records.remove_entity(entity_id2)
			element_entities.erase(entity_id2)
			element2.queue_free()
	
	return new_element

# Handle element collision events
func _on_element_collision(body, element_node):
	if not physics_enabled or not element_node.has_meta("entity_id") or not element_node.has_meta("element_type"):
		return
	
	# Get the colliding element
	var collider = body
	while collider and not collider.has_meta("entity_id") and collider.get_parent():
		collider = collider.get_parent()
	
	if not collider or not collider.has_meta("entity_id") or not collider.has_meta("element_type"):
		return
	
	# Process the collision
	var time_now = Time.get_ticks_msec()
	if time_now - last_interaction_time < interaction_cooldown * 1000:
		return
	
	last_interaction_time = time_now
	
	var entity_id1 = element_node.get_meta("entity_id")
	var entity_id2 = collider.get_meta("entity_id")
	
	# Process interaction in Akashic Records
	var result = akashic_records.process_entity_interaction(entity_id1, entity_id2)
	
	# Create interaction effect
	if interaction_effect_scene:
		var effect = interaction_effect_scene.instantiate()
		var midpoint = (element_node.global_position + collider.global_position) / 2
		effect.global_position = midpoint
		add_child(effect)
		effect.emitting = true

# Handle VR interactions
func _on_vr_interaction(object, interaction_type):
	if not object:
		return
	
	# Find if this is an element
	var element_node = object
	while element_node and not element_node.has_meta("entity_id") and element_node.get_parent():
		element_node = element_node.get_parent()
	
	if not element_node or not element_node.has_meta("entity_id"):
		return
	
	match interaction_type:
		"interact":
			# Left controller interaction with element
			_handle_element_interaction(element_node)
		"select":
			# Right controller selection
			_handle_element_selection(element_node)

# Handle controller gestures
func _on_controller_gesture(controller, gesture_type, gesture_data):
	match gesture_type:
		"throw":
			# Throw an element in a direction
			if grabbed_element and is_instance_valid(grabbed_element):
				_throw_element(grabbed_element, gesture_data.direction, gesture_data.velocity)

# Handle element interaction (left controller)
func _handle_element_interaction(element_node):
	print("Interacting with element: ", element_node.name)
	
	# Apply impulse to push the element
	var body = _get_rigid_body(element_node)
	if body:
		var impulse = -vr_manager.left_controller.global_transform.basis.z * 5.0
		body.apply_central_impulse(impulse)
	
	# Check for transformation with selected element
	if selected_element and selected_element != element_node:
		var type1 = element_node.get_meta("element_type")
		var type2 = selected_element.get_meta("element_type")
		_check_transformation(element_node, selected_element, type1, type2)

# Handle element selection (right controller)
func _handle_element_selection(element_node):
	print("Selecting element: ", element_node.name)
	
	# Deselect previous element
	if selected_element and is_instance_valid(selected_element):
		var mesh = _find_mesh_instance(selected_element)
		if mesh and mesh.material_override:
			mesh.material_override.emission_energy = 1.0
	
	# Set new selection
	selected_element = element_node
	
	# Highlight selected element
	var mesh = _find_mesh_instance(element_node)
	if mesh and mesh.material_override:
		mesh.material_override.emission_energy = 2.0
	
	# Start grabbing if grip is held
	if vr_manager.grab_mode:
		_start_grab(element_node, vr_manager.right_controller)

# Find the MeshInstance3D in an element node
func _find_mesh_instance(element_node):
	if element_node is MeshInstance3D:
		return element_node
		
	for child in element_node.get_children():
		if child is MeshInstance3D:
			return child
		elif child.get_child_count() > 0:
			var mesh = _find_mesh_instance(child)
			if mesh:
				return mesh
				
	return null

# Start grabbing an element
func _start_grab(element_node, controller):
	if not element_node or not controller:
		return
		
	print("Grabbing element: ", element_node.name)
	
	# Store grab state
	grabbed_element = element_node
	grabbing_controller = controller
	
	# Disable physics temporarily
	var body = _get_rigid_body(element_node)
	if body:
		body.freeze = true
	
	# Parent to controller
	var original_parent = element_node.get_parent()
	element_node.set_meta("original_parent", original_parent)
	original_parent.remove_child(element_node)
	controller.add_child(element_node)
	
	# Position relative to controller
	element_node.position = Vector3(0, 0, -0.2)

# End grabbing an element
func _end_grab():
	if not grabbed_element or not is_instance_valid(grabbed_element):
		return
		
	print("Releasing element: ", grabbed_element.name)
	
	# Get original parent
	var original_parent = grabbed_element.get_meta("original_parent") if grabbed_element.has_meta("original_parent") else elements_container
	
	# Get global transform before reparenting
	var global_transform = grabbed_element.global_transform
	
	# Reparent
	grabbing_controller.remove_child(grabbed_element)
	original_parent.add_child(grabbed_element)
	
	# Restore global transform
	grabbed_element.global_transform = global_transform
	
	# Re-enable physics
	var body = _get_rigid_body(grabbed_element)
	if body:
		body.freeze = false
	
	# Clear grab state
	grabbed_element = null
	grabbing_controller = null

# Throw an element with velocity
func _throw_element(element_node, direction, velocity):
	# End the grab first
	_end_grab()
	
	# Apply impulse for throwing
	var body = _get_rigid_body(element_node)
	if body:
		var impulse = direction * velocity * 5.0
		body.apply_central_impulse(impulse)

# Create a specific element
func create_specific_element(element_type: String):
	# Generate a random position near the center
	var position = Vector3(
		rand_range(-1.0, 1.0),
		1.5,
		rand_range(-1.0, -2.0)
	)
	
	return _create_element(element_type, position)

# Handle results from Akashic Records interactions
func _on_interaction_processed(result):
	if not result.success:
		return
		
	print("Element interaction processed: ", result.result)
	
	# Handle different result types
	if result.result == "create" and result.has("data"):
		var data = result.data
		if data.has("new_word_id") and data.has("new_word_data") and data.has("position"):
			var new_type = data.new_word_data.get("type", "")
			var pos = Vector3(data.position.x, data.position.y, data.position.z)
			_create_element(new_type, pos)

# Utility function to generate a random range
func rand_range(min_val, max_val):
	return min_val + (max_val - min_val) * randf()

# Clean up function
func _exit_tree():
	# Ensure elements are properly unregistered
	for entity_id in element_entities:
		akashic_records.remove_entity(entity_id)