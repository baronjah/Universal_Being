extends Node
class_name CoreThingCreator

# Singleton instance
static var _instance = null

# Static function to get the singleton instance
static func get_instance() -> CoreThingCreator:
	if not _instance:
		_instance = CoreThingCreator.new()
	return _instance

# References
var akashic_records_manager = null
var current_scene = null

# Signals
signal thing_created(thing_id, word_id, position)
signal thing_removed(thing_id)

# Thing storage
var active_things = {}
var thing_words = {}  # Maps thing_id -> word_id
var thing_positions = {}  # Maps thing_id -> position
var thing_properties = {}  # Maps thing_id -> custom properties

func _ready():
	# Find AkashicRecordsManager
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
	else:
		print("AkashicRecordsManager not found in CoreThingCreator!")
		return
	
	# Get current scene
	current_scene = get_tree().current_scene
	
	print("CoreThingCreator initialized")

# Create a thing in the 3D world based on a dictionary word
func create_thing(word_id: String, position: Vector3, custom_properties: Dictionary = {}) -> String:
	if not akashic_records_manager:
		push_error("AkashicRecordsManager not available")
		return ""
	
	# Check if the word exists in the dictionary
	var dictionary = akashic_records_manager.dynamic_dictionary
	if not dictionary.words.has(word_id):
		push_error("Word not found in dictionary: " + word_id)
		return ""
	
	# Get the word from the dictionary
	var word = dictionary.get_word(word_id)
	
	# Generate a unique ID for the thing
	var thing_id = word_id + "_" + str(randi())
	
	# Create a visual representation based on the word's category
	var thing_node = _create_visual_representation(word, position)
	
	if thing_node:
		# Store thing data
		active_things[thing_id] = thing_node
		thing_words[thing_id] = word_id
		thing_positions[thing_id] = position
		thing_properties[thing_id] = custom_properties
		
		# Add to current scene
		current_scene.add_child(thing_node)
		
		# Increase word usage count
		word.usage_count += 1
		dictionary.update_word(word)
		
		# Register with zone manager if available
		var entity_id = akashic_records_manager.instantiate_entity(word_id, position)
		if not entity_id.is_empty():
			thing_node.set_meta("entity_id", entity_id)
		
		# Connect signals for physics interactions if applicable
		if thing_node is Area3D:
			thing_node.body_entered.connect(_on_thing_body_entered.bind(thing_id))
			thing_node.body_exited.connect(_on_thing_body_exited.bind(thing_id))
			thing_node.area_entered.connect(_on_thing_area_entered.bind(thing_id))
			thing_node.area_exited.connect(_on_thing_area_exited.bind(thing_id))
		
		emit_signal("thing_created", thing_id, word_id, position)
		
		return thing_id
	
	return ""

# Remove a thing from the world
func remove_thing(thing_id: String) -> bool:
	if not active_things.has(thing_id):
		return false
	
	var thing_node = active_things[thing_id]
	
	# Remove from scene
	thing_node.queue_free()
	
	# Remove from storage
	active_things.erase(thing_id)
	thing_words.erase(thing_id)
	thing_positions.erase(thing_id)
	thing_properties.erase(thing_id)
	
	# Remove from zone manager if applicable
	if thing_node.has_meta("entity_id"):
		var entity_id = thing_node.get_meta("entity_id")
		akashic_records_manager.zone_manager.remove_entity(entity_id)
	
	emit_signal("thing_removed", thing_id)
	
	return true

# Get a list of all active things
func get_all_things() -> Array:
	var things_array = []
	for key in active_things.keys():
		things_array.append(key)
	return things_array

# Check if a thing exists
func has_thing(thing_id: String) -> bool:
	return active_things.has(thing_id)

# Get a thing's associated word ID
func get_thing_word(thing_id: String) -> String:
	return thing_words.get(thing_id, "")

# Get a thing's position
func get_thing_position(thing_id: String) -> Vector3:
	return thing_positions.get(thing_id, Vector3.ZERO)

# Get a thing's full data
func get_thing(thing_id: String) -> Dictionary:
	if not active_things.has(thing_id):
		return {}

	return {
		"id": thing_id,
		"word_id": get_thing_word(thing_id),
		"position": get_thing_position(thing_id),
		"properties": get_thing_properties(thing_id)
	}

# Get a thing's custom properties
func get_thing_properties(thing_id: String) -> Dictionary:
	return thing_properties.get(thing_id, {})

# Update a thing's position
func update_thing_position(thing_id: String, new_position: Vector3) -> bool:
	if not active_things.has(thing_id):
		return false
	
	var thing_node = active_things[thing_id]
	thing_node.global_position = new_position
	thing_positions[thing_id] = new_position
	
	# Update in zone manager if applicable
	if thing_node.has_meta("entity_id"):
		var entity_id = thing_node.get_meta("entity_id")
		akashic_records_manager.zone_manager.update_entity_position(entity_id, new_position)
	
	return true

# Update a thing's custom properties
func update_thing_properties(thing_id: String, properties: Dictionary) -> bool:
	if not active_things.has(thing_id):
		return false
	
	thing_properties[thing_id] = properties
	
	# Update visual representation if needed
	_update_visual_properties(thing_id)
	
	return true

# Process interaction between two things
func process_thing_interaction(thing1_id: String, thing2_id: String) -> Dictionary:
	if not active_things.has(thing1_id) or not active_things.has(thing2_id):
		return {"success": false, "error": "Things not found"}
	
	var word1_id = thing_words[thing1_id]
	var word2_id = thing_words[thing2_id]
	
	# Get custom properties for context
	var context = {}
	for prop in thing_properties[thing1_id]:
		context["thing1_" + prop] = thing_properties[thing1_id][prop]
	for prop in thing_properties[thing2_id]:
		context["thing2_" + prop] = thing_properties[thing2_id][prop]
	
	# Process word interaction
	var result = akashic_records_manager.process_word_interaction(word1_id, word2_id, context)
	
	if result.get("success", false) and result.has("result"):
		var result_word_id = result.get("result")
		
		# Create a new thing for the result if needed
		if not result_word_id.is_empty():
			# Calculate midpoint between the two things
			var pos1 = thing_positions[thing1_id]
			var pos2 = thing_positions[thing2_id]
			var midpoint = (pos1 + pos2) / 2
			
			# Create the result thing
			var result_thing_id = create_thing(result_word_id, midpoint)
			if not result_thing_id.is_empty():
				result["result_thing_id"] = result_thing_id
		
		# Handle state changes if specified in result
		if result.has("state_changes"):
			for thing_id in result.get("state_changes", {}):
				if active_things.has(thing_id):
					var word_id = thing_words[thing_id]
					var new_state = result.get("state_changes", {})[thing_id]
					akashic_records_manager.change_word_state(word_id, new_state)
					_update_visual_properties(thing_id)
	
	return result

# Internal method to create a visual representation based on word type
func _create_visual_representation(word, position: Vector3) -> Node3D:
	var visual = null
	
	# Create different visuals based on category
	match word.category:
		"element":
			# Create a MeshInstance3D with material based on element properties
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.name = word.id
			
			# Create a simple sphere mesh
			var sphere = SphereMesh.new()
			sphere.radius = 0.5
			sphere.height = 1.0
			
			# Apply mesh
			mesh_instance.mesh = sphere
			
			# Create material based on properties
			var material = StandardMaterial3D.new()
			
			# Set color based on properties or state
			var color = Color.WHITE
			if word.properties.has("color"):
				color = Color(word.properties["color"])
			elif word.properties.has("heat") and word.properties.has("energy"):
				# Map heat to red and energy to brightness
				var r = clampf(0.2 + word.properties["heat"] * 0.8, 0, 1.0)
				var g = clampf(0.2 + (1.0 - word.properties["heat"]) * 0.5, 0, 1.0)
				var b = clampf(0.2 + word.properties["energy"] * 0.3, 0, 1.0)
				color = Color(r, g, b)
			
			material.albedo_color = color
			
			# Set emission if element emits light
			if word.properties.has("light") and word.properties["light"] > 0.3:
				material.emission_enabled = true
				material.emission = color
				material.emission_energy = word.properties["light"] * 2.0
			
			# Set transparency if element is not fully opaque
			if word.properties.has("transparency") and word.properties["transparency"] > 0.1:
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				material.albedo_color.a = 1.0 - word.properties["transparency"]
			
			# Apply material
			mesh_instance.material_override = material
			
			visual = mesh_instance
		
		"entity":
			# Create a more complex representation for entities
			var entity_root = Node3D.new()
			entity_root.name = word.id
			
			# Add a mesh instance for the visual
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.name = "Mesh"
			
			# Create a box mesh (can be replaced with more complex models)
			var box = BoxMesh.new()
			box.size = Vector3(1.0, 1.0, 1.0)
			
			# Apply mesh
			mesh_instance.mesh = box
			
			# Create material
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.2, 0.8, 0.4)  # Default green for entities
			
			# Apply material
			mesh_instance.material_override = material
			
			# Add collision shape for interaction
			var collision = CollisionShape3D.new()
			var shape = BoxShape3D.new()
			shape.size = Vector3(1.0, 1.0, 1.0)
			collision.shape = shape
			
			# Create area for interaction
			var area = Area3D.new()
			area.name = "InteractionArea"
			area.add_child(collision)
			
			# Add components to root
			entity_root.add_child(mesh_instance)
			entity_root.add_child(area)
			
			visual = entity_root
		
		"concept":
			# Create an abstract visual for concepts
			var concept_root = Node3D.new()
			concept_root.name = word.id
			
			# Create a particle system
			var particles = GPUParticles3D.new()
			particles.name = "Particles"
			
			# Configure particles
			var particle_material = ParticleProcessMaterial.new()
			particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
			particle_material.emission_sphere_radius = 0.5
			particle_material.direction = Vector3(0, 1, 0)
			particle_material.spread = 45.0
			particle_material.gravity = Vector3(0, -0.5, 0)
			particle_material.initial_velocity_min = 1.0
			particle_material.initial_velocity_max = 2.0
			particle_material.color = Color(0.8, 0.5, 1.0, 0.7)  # Purple for concepts
			
			particles.process_material = particle_material
			
			# Create point mesh for particles
			var point_mesh = QuadMesh.new()
			point_mesh.size = Vector2(0.1, 0.1)
			particles.draw_pass_1 = point_mesh
			
			# Add to root
			concept_root.add_child(particles)
			
			visual = concept_root
		
		_:
			# Default fallback - simple node with label
			var default_root = Node3D.new()
			default_root.name = word.id
			
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.name = "Mesh"
			
			var cylinder = CylinderMesh.new()
			cylinder.top_radius = 0.3
			cylinder.bottom_radius = 0.3
			cylinder.height = 0.5
			
			mesh_instance.mesh = cylinder
			
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.7, 0.7, 0.7)  # Gray for unknown types
			mesh_instance.material_override = material
			
			default_root.add_child(mesh_instance)
			
			visual = default_root
	
	# Set position
	visual.global_position = position
	
	return visual

# Update visual properties based on thing's word and custom properties
func _update_visual_properties(thing_id: String) -> void:
	if not active_things.has(thing_id):
		return
	
	var thing_node = active_things[thing_id]
	var word_id = thing_words[thing_id]
	var properties = thing_properties[thing_id]
	
	# Get word from dictionary
	var word = akashic_records_manager.dynamic_dictionary.get_word(word_id)
	if not word:
		return
	
	# Update visuals based on word category
	match word.category:
		"element":
			# Update material properties
			var mesh_instance = thing_node as MeshInstance3D
			if mesh_instance and mesh_instance.material_override:
				var material = mesh_instance.material_override as StandardMaterial3D
				
				# Update color based on properties
				if word.properties.has("color"):
					material.albedo_color = Color(word.properties["color"])
				elif word.properties.has("heat") and word.properties.has("energy"):
					var r = clampf(0.2 + word.properties["heat"] * 0.8, 0, 1.0)
					var g = clampf(0.2 + (1.0 - word.properties["heat"]) * 0.5, 0, 1.0)
					var b = clampf(0.2 + word.properties["energy"] * 0.3, 0, 1.0)
					material.albedo_color = Color(r, g, b)
				
				# Update emission
				if word.properties.has("light"):
					material.emission_enabled = word.properties["light"] > 0.3
					if material.emission_enabled:
						material.emission = material.albedo_color
						material.emission_energy = word.properties["light"] * 2.0
				
				# Update transparency
				if word.properties.has("transparency"):
					material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					material.albedo_color.a = 1.0 - word.properties["transparency"]
				
				# Update scale based on density if available
				if word.properties.has("density"):
					var scale_factor = 0.5 + word.properties["density"]
					thing_node.scale = Vector3(scale_factor, scale_factor, scale_factor)
		
		"entity", "concept", _:
			# Update other categories as needed
			# This could be expanded with more specific visual updates
			pass

# Signal handlers for physical interactions

func _on_thing_body_entered(body: Node3D, thing_id: String) -> void:
	# Handle physical interaction with bodies
	_check_for_interaction(thing_id, body)

func _on_thing_body_exited(body: Node3D, thing_id: String) -> void:
	# Handle body exit if needed
	pass

func _on_thing_area_entered(area: Area3D, thing_id: String) -> void:
	# Find the parent of the area, which should be another thing
	var other_thing = area.get_parent()
	
	# Handle physical interaction with other thing areas
	_check_for_interaction(thing_id, other_thing)

func _on_thing_area_exited(area: Area3D, thing_id: String) -> void:
	# Handle area exit if needed
	pass

# Helper to check for interactions
func _check_for_interaction(thing_id: String, other_node: Node) -> void:
	# Find the other thing ID
	var other_thing_id = ""
	
	for other_id in active_things:
		if active_things[other_id] == other_node:
			other_thing_id = other_id
			break
	
	if not other_thing_id.is_empty():
		# Process interaction
		process_thing_interaction(thing_id, other_thing_id)