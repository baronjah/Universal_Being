extends Node
# Using a different class name to avoid conflicts
class_name CoreEntityManager

# Singleton instance
static var _instance = null

# Static function to get the singleton instance
static func get_instance() -> CoreEntityManager:
	if not _instance:
		_instance = CoreEntityManager.new()
	return _instance

# Signals
signal entity_created(entity_id, entity_type)
signal entity_transformed(entity_id, old_type, new_type)
signal entity_connected(entity_id, other_entity_id)
signal entity_property_changed(entity_id, property_name, old_value, new_value)
signal entity_state_changed(entity_id, old_state, new_state)
signal entity_removed(entity_id)

# Store all entities in the system
var entities = {}

# Entity counter for generating unique IDs
var entity_counter = 0

# References to other systems
var universal_bridge = null
var akashic_records_manager = null

# Debug mode
var debug_mode = true

# Initialize the entity manager
func initialize() -> void:
	print("Initializing Core Entity Manager...")

	# Get references to required systems
	_find_system_references()

	# Connect signals
	_connect_signals()

	# Initialize UniversalEntity system
	_initialize_entity_system()

	print("Core Entity Manager initialized")

# Find references to required systems
func _find_system_references() -> void:
	# Load UniversalEntity class if needed
	var UniversalEntityClass = load("res://code/gdscript/scripts/akashic_records/universal_entity.gd")
	if not UniversalEntityClass:
		push_error("Failed to load UniversalEntity class")

	# Get UniversalBridge
	universal_bridge = CoreUniversalBridge.get_instance()

	# Get AkashicRecordsManager
	akashic_records_manager = CoreAkashicRecordsManager.get_instance()

	# Print diagnostic info
	if debug_mode:
		print("Found UniversalEntity class: ", UniversalEntityClass != null)
		print("Found Universal Bridge: ", universal_bridge != null)
		print("Found Akashic Records Manager: ", akashic_records_manager != null)

# Connect signals between systems
func _connect_signals() -> void:
	# Nothing to connect for now, this will be expanded later
	pass

# Initialize the UniversalEntity system
func _initialize_entity_system() -> void:
	# Create some basic entities for testing
	if debug_mode:
		var UniversalEntityClass = load("res://code/gdscript/scripts/akashic_records/universal_entity.gd")
		if not UniversalEntityClass:
			push_error("Failed to load UniversalEntity class in _initialize_entity_system")

			# Create dummy entities for testing (as a fallback)
			entities["test_primordial"] = _create_dummy_entity("test_primordial", "primordial")
			entities["test_element"] = _create_dummy_entity("test_element", "element")
			print("Created dummy test entities: ", entities.size())
			return

		# This allows us to run the tests even if no entities are created externally
		var primordial = UniversalEntityClass.new()
		primordial.initialize("test_primordial", "primordial", Vector3.ZERO)
		entities["test_primordial"] = primordial

		var element = UniversalEntityClass.new()
		element.initialize("test_element", "element", Vector3(1, 0, 0), {"essence": 0.8})
		entities["test_element"] = element

		print("Created test entities: ", entities.size())

# Create a dummy entity for testing when UniversalEntity can't be loaded
func _create_dummy_entity(id: String, type: String) -> Object:
	var dummy = Node.new()
	dummy.name = id

	# Add required properties
	dummy.entity_id = id
	dummy.entity_type = type
	dummy.position = Vector3.ZERO
	dummy.properties = {"essence": 1.0, "stability": 1.0}
	dummy.state = {"current": "stable", "previous": "", "locked": false}

	# Add required methods
	dummy.transform = func(new_type, transformation_properties={}): return true
	dummy.get_property = func(property_name, default_value=null): return 1.0
	dummy.set_property = func(property_name, value): return
	dummy.change_state = func(new_state): return true
	dummy.connect_to = func(other_entity_id): return true
	dummy.disconnect_from = func(other_entity_id): return true
	dummy.add_transformation_energy = func(amount): return
	dummy.interact_with = func(other_entity, context={}):
		return {
			"success": true,
			"type": "dummy",
			"effects": [],
			"transformation": null
		}

	return dummy

# Generate a unique entity ID
func _generate_entity_id(type: String = "entity") -> String:
	entity_counter += 1
	return type + "_" + str(entity_counter) + "_" + str(randi() % 100000)

# Create a new entity
func create_entity(entity_type: String = "primordial", position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> String:
	# Generate a unique ID
	var entity_id = _generate_entity_id(entity_type)

	# Load UniversalEntity class if needed
	var UniversalEntityClass = load("res://code/gdscript/scripts/akashic_records/universal_entity.gd")
	if not UniversalEntityClass:
		push_error("Failed to load UniversalEntity class in create_entity")

		# Create a dummy entity instead
		entities[entity_id] = _create_dummy_entity(entity_id, entity_type)

		# Emit signal
		emit_signal("entity_created", entity_id, entity_type)

		if debug_mode:
			print("Created dummy entity: " + entity_id + " of type " + entity_type)

		return entity_id

	# Create a new entity
	var entity = UniversalEntityClass.new()
	entity.initialize(entity_id, entity_type, position, properties)

	# Store entity
	entities[entity_id] = entity

	# Register entity with AkashicRecordsManager if available
	if akashic_records_manager:
		akashic_records_manager.create_entity(entity_id, entity_type, position, properties)

	# Emit signal
	emit_signal("entity_created", entity_id, entity_type)

	if debug_mode:
		print("Created entity: " + entity_id + " of type " + entity_type)

	return entity_id

# Get an entity by ID
func get_entity(entity_id: String) -> Object:
	if entities.has(entity_id):
		return entities[entity_id]
	return null

# Remove an entity
func remove_entity(entity_id: String) -> bool:
	if entities.has(entity_id):
		var entity = entities[entity_id]
		
		# Remove from storage
		entities.erase(entity_id)
		
		# Free the node
		entity.queue_free()
		
		# Emit signal
		emit_signal("entity_removed", entity_id)
		
		if debug_mode:
			print("Removed entity: " + entity_id)
		
		return true
	
	return false

# Transform an entity to a new type
func transform_entity(entity_id: String, new_type: String, transformation_properties: Dictionary = {}) -> bool:
	var entity = get_entity(entity_id)
	if not entity:
		push_error("Entity not found: " + entity_id)
		return false
	
	var old_type = entity.entity_type
	var success = entity.transform(new_type, transformation_properties)
	
	if success:
		# Emit signal
		emit_signal("entity_transformed", entity_id, old_type, new_type)
		
		# Update in AkashicRecordsManager if available
		if akashic_records_manager and akashic_records_manager.has_method("update_entity_type"):
			akashic_records_manager.update_entity_type(entity_id, new_type)
	
	return success

# Connect two entities
func connect_entities(entity1_id: String, entity2_id: String) -> bool:
	var entity1 = get_entity(entity1_id)
	var entity2 = get_entity(entity2_id)
	
	if not entity1 or not entity2:
		push_error("Cannot connect entities: one or both not found")
		return false
	
	var success = entity1.connect_to(entity2_id)
	if success:
		# Connect the other way as well for bidirectional connection
		entity2.connect_to(entity1_id)
		
		# Emit signal
		emit_signal("entity_connected", entity1_id, entity2_id)
		
		if debug_mode:
			print("Connected entities: " + entity1_id + " and " + entity2_id)
	
	return success

# Process interaction between two entities
func process_interaction(entity1_id: String, entity2_id: String, context: Dictionary = {}) -> Dictionary:
	var entity1 = get_entity(entity1_id)
	var entity2 = get_entity(entity2_id)

	if not entity1 or not entity2:
		return {"success": false, "error": "One or both entities not found"}

	# Make sure entity1 has the interact_with method
	if not entity1.has_method("interact_with"):
		return {
			"success": false,
			"error": "Entity missing interact_with method",
			"type": "error"
		}

	# Get the interaction result
	var result = entity1.interact_with(entity2, context)

	# Validate result
	if not result is Dictionary:
		result = {
			"success": true,
			"type": "basic_interaction",
			"effects": []
		}

	# Check for transformation possibilities
	if result.has("transformation"):
		var transformation = result.get("transformation")
		if transformation is Dictionary and transformation.has("possible") and transformation.possible == true:
			if transformation.has("entity_id") and transformation.has("potential_types"):
				var entity_to_transform = transformation.entity_id
				var potential_types = transformation.potential_types

				if potential_types is Array and potential_types.size() > 0:
					# Choose a random type for now (this could be more sophisticated)
					var new_type = potential_types[randi() % int(potential_types.size())]

					# Transform the entity
					transform_entity(entity_to_transform, new_type)

					result["transformation_occurred"] = true
					result["new_type"] = new_type

	return result

# Create entity from dictionary
func create_entity_from_dict(data: Dictionary) -> String:
	var entity_id = ""
	
	# Check if entity ID is provided
	if data.has("id"):
		entity_id = data.id
	else:
		entity_id = _generate_entity_id(data.get("type", "entity"))
	
	# Create position vector
	var position = Vector3.ZERO
	if data.has("position"):
		position = Vector3(
			data.position.get("x", 0.0),
			data.position.get("y", 0.0),
			data.position.get("z", 0.0)
		)
	
	# Create the entity
	var entity = UniversalEntity.from_dictionary(data)
	
	# Store entity
	entities[entity_id] = entity
	
	# Register entity with AkashicRecordsManager if available
	if akashic_records_manager:
		var properties = data.get("properties", {})
		akashic_records_manager.create_entity(entity_id, entity.entity_type, position, properties)
	
	# Emit signal
	emit_signal("entity_created", entity_id, entity.entity_type)
	
	if debug_mode:
		print("Created entity from dictionary: " + entity_id)
	
	return entity_id

# Get all entities
func get_all_entities() -> Array:
	return entities.keys()

# Get entities by type
func get_entities_by_type(entity_type: String) -> Array:
	var matching_entities = []
	
	for entity_id in entities:
		var entity = entities[entity_id]
		if entity.entity_type == entity_type:
			matching_entities.append(entity_id)
	
	return matching_entities

# Get entities in radius
func get_entities_in_radius(center: Vector3, radius: float) -> Array:
	var entities_in_radius = []
	
	for entity_id in entities:
		var entity = entities[entity_id]
		var distance = center.distance_to(entity.position)
		
		if distance <= radius:
			entities_in_radius.append({
				"entity_id": entity_id,
				"distance": distance
			})
	
	# Sort by distance (closest first)
	entities_in_radius.sort_custom(func(a, b): return a.distance < b.distance)
	
	# Return just the entity IDs
	var result = []
	for item in entities_in_radius:
		result.append(item.entity_id)
	
	return result

# Add energy to an entity
func add_energy_to_entity(entity_id: String, amount: float) -> bool:
	var entity = get_entity(entity_id)
	if not entity:
		return false
	
	entity.add_transformation_energy(amount)
	return true

# Change entity state
func change_entity_state(entity_id: String, new_state: String) -> bool:
	var entity = get_entity(entity_id)
	if not entity:
		return false
	
	var success = entity.change_state(new_state)
	
	if success:
		emit_signal("entity_state_changed", entity_id, entity.state.previous, new_state)
	
	return success

# Set entity property
func set_entity_property(entity_id: String, property_name: String, value) -> bool:
	var entity = get_entity(entity_id)
	if not entity:
		return false
	
	var old_value = entity.get_property(property_name)
	entity.set_property(property_name, value)
	
	emit_signal("entity_property_changed", entity_id, property_name, old_value, value)
	
	return true

# Create multiple related entities (like a pattern or formation)
func create_entity_pattern(center: Vector3, pattern_type: String, entity_type: String, count: int = 5, radius: float = 10.0) -> Array:
	var created_entities = []
	
	# Different pattern types
	match pattern_type:
		"circle":
			for i in range(count):
				var angle = 2 * PI * i / count
				var offset = Vector3(
					cos(angle) * radius,
					0,
					sin(angle) * radius
				)
				var entity_id = create_entity(entity_type, center + offset)
				created_entities.append(entity_id)
		
		"grid":
			var grid_size = int(ceil(sqrt(count)))
			var grid_spacing = radius / float(grid_size)

			for i in range(count):
				var x = (i % int(grid_size)) - float(grid_size) / 2.0
				var z = floor(i / float(grid_size)) - float(grid_size) / 2.0

				var offset = Vector3(
					x * grid_spacing,
					0,
					z * grid_spacing
				)
				
				var entity_id = create_entity(entity_type, center + offset)
				created_entities.append(entity_id)
		
		"random":
			for i in range(count):
				var offset = Vector3(
					(randf() - 0.5) * 2 * radius,
					(randf() - 0.5) * 2 * radius,
					(randf() - 0.5) * 2 * radius
				)
				
				var entity_id = create_entity(entity_type, center + offset)
				created_entities.append(entity_id)
		
		"sphere":
			for i in range(count):
				# Generate random points on a sphere
				var theta = randf() * 2 * PI
				var phi = acos(2 * randf() - 1)
				
				var offset = Vector3(
					radius * sin(phi) * cos(theta),
					radius * sin(phi) * sin(theta),
					radius * cos(phi)
				)
				
				var entity_id = create_entity(entity_type, center + offset)
				created_entities.append(entity_id)
	
	# Connect adjacent entities
	for i in range(created_entities.size()):
		var next_index = (i + 1) % int(created_entities.size())
		connect_entities(created_entities[i], created_entities[next_index])
	
	return created_entities

# Save all entities to a file
func save_entities_to_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for writing: " + file_path)
		return false
	
	var data = {
		"entities": []
	}
	
	for entity_id in entities:
		var entity = entities[entity_id]
		data.entities.append(entity.to_dictionary())
	
	file.store_string(JSON.stringify(data))
	file.close()
	
	if debug_mode:
		print("Saved " + str(entities.size()) + " entities to " + file_path)
	
	return true

# Load entities from a file
func load_entities_from_file(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		push_error("File not found: " + file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open file for reading: " + file_path)
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		push_error("JSON parsing error: " + json.get_error_message())
		return false
	
	var data = json.get_data()
	
	# Clear existing entities
	for entity_id in entities.keys():
		remove_entity(entity_id)
	
	# Create entities from data
	for entity_data in data.entities:
		create_entity_from_dict(entity_data)
	
	if debug_mode:
		print("Loaded " + str(entities.size()) + " entities from " + file_path)
	
	return true
