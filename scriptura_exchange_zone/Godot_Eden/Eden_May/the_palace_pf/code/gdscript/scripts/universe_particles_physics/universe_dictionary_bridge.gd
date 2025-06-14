extends Node
class_name UniverseDictionaryBridge

# References to managers
var universe_controller = null
var akashic_records = null
var resource_manager = null

# Dictionaries for tracking entity-to-cosmic object mapping
var entity_to_cosmic = {}
var cosmic_to_entity = {}

# Constants
const SCALE_LEVELS = ["universe", "galaxy", "star_system", "planet", "element"]

# Signals
signal entity_created(entity_id, cosmic_id, scale_level)
signal entity_updated(entity_id, cosmic_id)
signal entity_removed(entity_id, cosmic_id)

# Initialize the bridge
func initialize(p_universe_controller, p_resource_manager = null):
	universe_controller = p_universe_controller
	
	# Get resource manager
	resource_manager = p_resource_manager
	if not resource_manager and universe_controller and "resource_manager" in universe_controller:
		resource_manager = universe_controller.resource_manager
	
	# Initialize Akashic Records
	akashic_records = AkashicRecordsManager.get_instance()
	if not akashic_records.is_initialized:
		akashic_records.initialize()
	
	# Connect signals
	akashic_records.connect("entity_created", Callable(self, "_on_entity_created"))
	akashic_records.connect("entity_moved", Callable(self, "_on_entity_moved"))
	
	# Create baseline data if needed
	create_baseline_dictionary_data()
	
	print("UniverseDictionaryBridge initialized")
	return true

# Create baseline dictionary data
func create_baseline_dictionary_data():
	# Create scale level words if they don't exist
	for level in SCALE_LEVELS:
		if not akashic_records.get_word(level).size() > 0:
			var level_data = {
				"category": "scale",
				"parent": null,
				"children": [],
				"properties": {
					"scale_factor": get_scale_factor(level),
					"resource_limit_multiplier": get_resource_limit_multiplier(level)
				},
				"description": "Scale level for " + level
			}
			akashic_records.create_word(level, level_data)
	
	# Create cosmic object types if they don't exist
	if not akashic_records.get_word("galaxy").size() > 0:
		akashic_records.create_child_word("universe", "galaxy", {
			"category": "cosmic",
			"description": "A vast collection of stars, gas, and dust held together by gravity",
			"properties": {
				"size_range": [80.0, 120.0],
				"star_count_range": [500, 2000]
			}
		})
	
	if not akashic_records.get_word("star").size() > 0:
		akashic_records.create_child_word("galaxy", "star", {
			"category": "cosmic",
			"description": "A luminous sphere of plasma held together by gravity",
			"properties": {
				"temperature_range": [3000, 50000],
				"size_range": [0.1, 100.0]
			}
		})
	
	if not akashic_records.get_word("planet").size() > 0:
		akashic_records.create_child_word("star_system", "planet", {
			"category": "cosmic",
			"description": "A celestial body that orbits a star",
			"properties": {
				"size_range": [0.1, 20.0],
				"orbit_distance_range": [0.1, 50.0]
			}
		})
	
	# Link to element system
	if not akashic_records.get_word("element").size() > 0:
		akashic_records.create_word("element", {
			"category": "scale",
			"parent": "planet",
			"children": ["fire", "water", "wood", "ash"],
			"description": "Base interaction unit in the elemental system"
		})
	
	# Create basic elements if they don't exist
	if not akashic_records.get_word("fire").size() > 0:
		akashic_records.create_child_word("element", "fire", {
			"category": "element",
			"description": "The fire element, representing energy and transformation",
			"properties": {
				"temperature": 800,
				"light": 0.8,
				"spread": 0.5
			}
		})
	
	if not akashic_records.get_word("water").size() > 0:
		akashic_records.create_child_word("element", "water", {
			"category": "element",
			"description": "The water element, representing flow and adaptation",
			"properties": {
				"flow": 0.8,
				"transparency": 0.7,
				"temperature": 20
			}
		})
	
	if not akashic_records.get_word("wood").size() > 0:
		akashic_records.create_child_word("element", "wood", {
			"category": "element",
			"description": "The wood element, representing growth and vitality",
			"properties": {
				"growth": 0.2,
				"hardness": 0.6,
				"flammability": 0.7
			}
		})
	
	if not akashic_records.get_word("ash").size() > 0:
		akashic_records.create_child_word("element", "ash", {
			"category": "element",
			"description": "The ash element, representing transformation and fertility",
			"properties": {
				"fertility": 0.6,
				"lightness": 0.3
			}
		})

# Register a cosmic object with the dictionary system
func register_cosmic_object(cosmic_id: String, object_type: String, position: Vector3, data: Dictionary = {}) -> String:
	# Skip if already registered
	if cosmic_to_entity.has(cosmic_id):
		return cosmic_to_entity[cosmic_id]
	
	# Create properties dictionary
	var properties = {}
	
	# Add common properties
	properties.cosmic_id = cosmic_id
	properties.cosmic_type = object_type
	
	# Add type-specific properties
	match object_type:
		"galaxy":
			if data.has("galaxy_type"):
				properties.galaxy_type = data.galaxy_type
			if data.has("star_count"):
				properties.star_count = data.star_count
			if data.has("size"):
				properties.size = data.size
		
		"star":
			if data.has("star_type"):
				properties.star_type = data.star_type
			if data.has("temperature"):
				properties.temperature = data.temperature
			if data.has("size"):
				properties.size = data.size
			if data.has("color"):
				properties.color = data.color
		
		"planet":
			if data.has("planet_type"):
				properties.planet_type = data.planet_type
			if data.has("size"):
				properties.size = data.size
			if data.has("orbit_distance"):
				properties.orbit_distance = data.orbit_distance
			if data.has("has_life"):
				properties.has_life = data.has_life
	
	# Copy any additional properties from data
	for key in data:
		if not properties.has(key) and typeof(data[key]) != TYPE_OBJECT and typeof(data[key]) != TYPE_ARRAY:
			properties[key] = data[key]
	
	# Generate a unique entity ID
	var entity_id = generate_entity_id(cosmic_id, object_type)
	
	# Create entity in the Akashic Records
	var success = akashic_records.create_entity(entity_id, object_type, position, properties)
	
	if success:
		# Store mapping
		entity_to_cosmic[entity_id] = cosmic_id
		cosmic_to_entity[cosmic_id] = entity_id
		
		emit_signal("entity_created", entity_id, cosmic_id, get_scale_for_type(object_type))
		return entity_id
	
	return ""

# Update a cosmic object's position
func update_cosmic_position(cosmic_id: String, new_position: Vector3) -> bool:
	if not cosmic_to_entity.has(cosmic_id):
		return false
	
	var entity_id = cosmic_to_entity[cosmic_id]
	return akashic_records.update_entity_position(entity_id, new_position)

# Update a cosmic object's data
func update_cosmic_data(cosmic_id: String, data: Dictionary) -> bool:
	if not cosmic_to_entity.has(cosmic_id):
		return false
	
	var entity_id = cosmic_to_entity[cosmic_id]
	var entity = akashic_records.get_entity(entity_id)
	
	if entity.is_empty():
		return false
	
	# Update properties
	for key in data:
		if typeof(data[key]) != TYPE_OBJECT and typeof(data[key]) != TYPE_ARRAY:
			entity.properties[key] = data[key]
	
	// TODO: Need a method to update entity properties without changing position
	// For now, we'll just update position with same value
	
	var position = Vector3(
		entity.position.x,
		entity.position.y,
		entity.position.z
	)
	
	var success = akashic_records.update_entity_position(entity_id, position)
	
	if success:
		emit_signal("entity_updated", entity_id, cosmic_id)
	
	return success

# Unregister a cosmic object
func unregister_cosmic_object(cosmic_id: String) -> bool:
	if not cosmic_to_entity.has(cosmic_id):
		return false
	
	var entity_id = cosmic_to_entity[cosmic_id]
	
	// Emit signal before removal
	emit_signal("entity_removed", entity_id, cosmic_id)
	
	// Remove mappings
	entity_to_cosmic.erase(entity_id)
	cosmic_to_entity.erase(cosmic_id)
	
	// Remove from Akashic Records
	return akashic_records.remove_entity(entity_id)

# Process an interaction between two cosmic objects
func process_cosmic_interaction(cosmic_id1: String, cosmic_id2: String) -> Dictionary:
	if not cosmic_to_entity.has(cosmic_id1) or not cosmic_to_entity.has(cosmic_id2):
		return {"success": false, "reason": "cosmic_object_not_registered"}
	
	var entity_id1 = cosmic_to_entity[cosmic_id1]
	var entity_id2 = cosmic_to_entity[cosmic_id2]
	
	return akashic_records.process_entity_interaction(entity_id1, entity_id2)

# Generate a unique entity ID from a cosmic ID
func generate_entity_id(cosmic_id: String, object_type: String) -> String:
	# Create a prefix based on type
	var prefix = ""
	match object_type:
		"galaxy": prefix = "g"
		"star": prefix = "s" 
		"planet": prefix = "p"
		"element": prefix = "e"
		_: prefix = "o"  # others
	
	# Use cosmic_id if it's short enough, otherwise hash it
	var id_part = cosmic_id
	if cosmic_id.length() > 10:
		# Create a hash of the cosmic ID
		var hash_val = 0
		for i in range(cosmic_id.length()):
			hash_val = ((hash_val << 5) - hash_val) + cosmic_id.unicode_at(i)
		id_part = str(abs(hash_val)).substr(0, 10)
	
	# Generate unique ID with prefix
	return prefix + id_part

# Get the scale level for a cosmic object type
func get_scale_for_type(object_type: String) -> String:
	match object_type:
		"galaxy": return "galaxy"
		"star": return "star_system"
		"planet": return "planet" 
		"fire", "water", "wood", "ash": return "element"
		_: return "universe"  # Default

# Get scale factor for a scale level
func get_scale_factor(scale_level: String) -> float:
	match scale_level:
		"universe": return 1.0
		"galaxy": return 0.1
		"star_system": return 0.01
		"planet": return 0.001
		"element": return 0.0001
	return 1.0

# Get resource limit multiplier for a scale level
func get_resource_limit_multiplier(scale_level: String) -> float:
	match scale_level:
		"universe": return 0.5
		"galaxy": return 1.0
		"star_system": return 1.5
		"planet": return 2.0
		"element": return 1.0
	return 1.0

# Find cosmic objects near a position
func find_cosmic_objects_in_radius(position: Vector3, radius: float) -> Array:
	var entities = akashic_records.get_entities_in_radius(position, radius)
	var results = []
	
	for entity_id in entities:
		if entity_to_cosmic.has(entity_id):
			var cosmic_id = entity_to_cosmic[entity_id]
			var entity = entities[entity_id]
			
			results.append({
				"cosmic_id": cosmic_id,
				"entity_id": entity_id,
				"type": entity.type,
				"position": Vector3(entity.position.x, entity.position.y, entity.position.z),
				"properties": entity.properties
			})
	
	return results

# Signal handlers
func _on_entity_created(entity_id):
	# Handle newly created entity (this would be rare from outside this bridge)
	var entity = akashic_records.get_entity(entity_id)
	if entity.is_empty() or not entity.has("properties") or not entity.properties.has("cosmic_id"):
		return
	
	var cosmic_id = entity.properties.cosmic_id
	
	# Update mappings
	entity_to_cosmic[entity_id] = cosmic_id
	cosmic_to_entity[cosmic_id] = entity_id

func _on_entity_moved(entity_id, old_position, new_position):
	# Propagate position changes to cosmic objects if needed
	if entity_to_cosmic.has(entity_id):
		var cosmic_id = entity_to_cosmic[entity_id]
		
		# We would need to update the cosmic object's position here
		# This depends on how your cosmic objects are implemented
		if universe_controller and universe_controller.has_method("update_object_position"):
			universe_controller.update_object_position(cosmic_id, new_position)