extends Node
class_name UniversalBridge

# This class serves as the central connection point between all major systems:
# - Element System
# - Akashic Records (Dictionary)
# - Thing Creator
# - Menu/Console System
# - Zone Management

# Singleton instance
static var _instance = null

# System references
var akashic_records_manager = null
var element_manager = null
var thing_creator = null
var menu_system = null
var console_system = null

# System status
var is_systems_connected = false
var debug_mode = true
var is_initialized = false

# Transformation rules
var transformation_rules = {
	"primordial": ["fire", "water", "wood", "ash"],
	"fire": ["ash", "energy", "heat"],
	"water": ["ice", "steam", "life"],
	"wood": ["ash", "life", "structure"],
	"ash": ["earth", "mineral", "dust"]
}

# Signals
signal systems_connected
signal entity_registered(entity_id, word_id, element_id)
signal entity_transformed(entity_id, old_type, new_type)
signal dictionary_updated(word_id)
signal interaction_processed(entity1_id, entity2_id, result)

# Get singleton instance
static func get_instance():
	if not _instance:
		_instance = UniversalBridge.new()
	return _instance

# Initialize the bridge
func initialize() -> bool:
	if is_initialized:
		return true
		
	print("Initializing Universal Bridge...")
	
	# Find system references
	_find_system_references()
	
	# Initialize missing systems if needed
	_initialize_missing_systems()
	
	# Connect signals
	_connect_signals()
	
	is_initialized = true
	print("Universal Bridge initialized")
	
	# Create primordial dictionary entry if it doesn't exist
	_ensure_primordial_exists()
	
	return true

# Find references to all required systems
func _find_system_references() -> void:
	# Find Akashic Records Manager
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
	else:
		akashic_records_manager = AkashicRecordsManagerA.get_instance()
	
	# Find Element Manager
	if has_node("/root/ElementManager"):
		element_manager = get_node("/root/ElementManager")
	else:
		# Safely check if tree is available
		if is_inside_tree():
			var tree = get_tree()
			if tree != null:
				var nodes = tree.get_nodes_in_group("element_manager")
				if nodes.size() > 0:
					element_manager = nodes[0]
		else:
			# Defer element manager finding to _ready
			call_deferred("_find_element_manager")
	
	# Find Thing Creator
	if has_node("/root/ThingCreator"):
		thing_creator = get_node("/root/ThingCreator")
	else:
		thing_creator = ThingCreatorA.get_instance()
	
	# Find Menu System
	if has_node("/root/main"):
		# This will need to be adjusted based on your actual menu system path
		menu_system = get_node("/root/main")
		
		# Try to find console system
		if menu_system.has_node("JSH_console"):
			console_system = menu_system.get_node("JSH_console")
	
	# Print found systems for debugging
	if debug_mode:
		print("Found Akashic Records Manager: ", akashic_records_manager != null)
		print("Found Element Manager: ", element_manager != null)
		print("Found Thing Creator: ", thing_creator != null)
		print("Found Menu System: ", menu_system != null)
		print("Found Console System: ", console_system != null)

# Initialize any missing systems
func _initialize_missing_systems() -> void:
	# Initialize Akashic Records Manager if needed
	if not akashic_records_manager:
		akashic_records_manager = AkashicRecordsManagerA.get_instance()
		if not akashic_records_manager.is_initialized:
			akashic_records_manager.initialize()
	
	# Thing Creator should be initialized by the Akashic Records Manager
	if not thing_creator:
		thing_creator = ThingCreatorA.get_instance()

# Connect signals between systems
func _connect_signals() -> void:
	# Connect Akashic Records signals
	if akashic_records_manager:
		if not akashic_records_manager.is_connected("word_created", Callable(self, "_on_word_created")):
			akashic_records_manager.connect("word_created", Callable(self, "_on_word_created"))
		
		if not akashic_records_manager.is_connected("word_updated", Callable(self, "_on_word_updated")):
			akashic_records_manager.connect("word_updated", Callable(self, "_on_word_updated"))
		
		if not akashic_records_manager.is_connected("entity_created", Callable(self, "_on_akashic_entity_created")):
			akashic_records_manager.connect("entity_created", Callable(self, "_on_akashic_entity_created"))
		
		if not akashic_records_manager.is_connected("interaction_processed", Callable(self, "_on_akashic_interaction_processed")):
			akashic_records_manager.connect("interaction_processed", Callable(self, "_on_akashic_interaction_processed"))
	
	# Connect Element Manager signals
	if element_manager:
		if not element_manager.is_connected("element_created", Callable(self, "_on_element_created")):
			element_manager.connect("element_created", Callable(self, "_on_element_created"))
		
		if not element_manager.is_connected("element_transformed", Callable(self, "_on_element_transformed")):
			element_manager.connect("element_transformed", Callable(self, "_on_element_transformed"))
	
	# Connect Thing Creator signals
	if thing_creator:
		if not thing_creator.is_connected("thing_created", Callable(self, "_on_thing_created")):
			thing_creator.connect("thing_created", Callable(self, "_on_thing_created"))
		
		if not thing_creator.is_connected("thing_destroyed", Callable(self, "_on_thing_destroyed")):
			thing_creator.connect("thing_destroyed", Callable(self, "_on_thing_destroyed"))
		
		if not thing_creator.is_connected("thing_moved", Callable(self, "_on_thing_moved")):
			thing_creator.connect("thing_moved", Callable(self, "_on_thing_moved"))

# Ensure the primordial dictionary entry exists
func _ensure_primordial_exists() -> void:
	if not akashic_records_manager:
		print("Cannot create primordial entry: Akashic Records Manager not found")
		return
	
	var primordial = akashic_records_manager.get_word("primordial")
	if primordial.size() == 0:
		print("Creating primordial word definition")
		var primordial_data = {
			"id": "primordial",
			"display_name": "Primordial Essence",
			"category": "base",
			"description": "The fundamental essence from which all things can evolve",
			"properties": {
				"essence": 1.0,
				"stability": 1.0,
				"resonance": 0.5,
				"complexity": 0.0
			},
			"states": {
				"current": "stable",
				"possible": ["stable", "unstable", "transforming"]
			},
			"transformations": transformation_rules["primordial"]
		}
		
		akashic_records_manager.create_word("primordial", "base", primordial_data.properties)
	else:
		print("Primordial word definition already exists")

# Create basic element definitions if they don't exist
func ensure_element_definitions() -> void:
	if not akashic_records_manager:
		print("Cannot create element definitions: Akashic Records Manager not found")
		return
	
	var elements = ["fire", "water", "wood", "ash"]
	var properties = {
		"fire": {
			"essence": 0.9,
			"stability": 0.3,
			"resonance": 0.8,
			"complexity": 0.2,
			"heat": 0.9,
			"energy": 0.8,
			"light": 0.7
		},
		"water": {
			"essence": 0.8,
			"stability": 0.7,
			"resonance": 0.6,
			"complexity": 0.3,
			"flow": 0.9,
			"clarity": 0.7,
			"life_support": 0.8
		},
		"wood": {
			"essence": 0.7,
			"stability": 0.8,
			"resonance": 0.5,
			"complexity": 0.4,
			"growth": 0.8,
			"structure": 0.7,
			"life": 0.6
		},
		"ash": {
			"essence": 0.6,
			"stability": 0.9,
			"resonance": 0.3,
			"complexity": 0.2,
			"fertilizer": 0.7,
			"dissolution": 0.6,
			"transformation": 0.5
		}
	}
	
	for element in elements:
		var element_def = akashic_records_manager.get_word(element)
		if element_def.size() == 0:
			print("Creating " + element + " word definition")
			var element_data = {
				"id": element,
				"display_name": element.capitalize(),
				"category": "element",
				"parent": "primordial",
				"description": "A basic elemental form",
				"properties": properties[element],
				"states": {
					"current": "stable",
					"possible": ["stable", "unstable", "transforming", "consuming", "diminishing"]
				},
				"transformations": transformation_rules.get(element, [])
			}
			
			akashic_records_manager.create_word(element, "element", element_data.properties)
		else:
			print(element.capitalize() + " word definition already exists")

# Register an element with the dictionary
func register_element(element, type_name: String) -> String:
	if not akashic_records_manager or not element:
		return ""
	
	# Generate a unique ID
	var element_id = element.get_instance_id()
	var word_id = type_name + "_" + str(element_id)
	
	# Get element position
	var position = element.global_position
	
	# Create entity in Akashic Records
	var entity_id = "entity_" + word_id
	var properties = {
		"element_id": element_id,
		"temperature": element.get("temperature", 0.0) if element.has("temperature") else 0.0,
		"energy": element.get("energy", 0.0) if element.has("energy") else 0.0,
		"mass": element.get("mass", 1.0) if element.has("mass") else 1.0
	}
	
	var success = akashic_records_manager.create_entity(entity_id, type_name, Vector3(position.x, position.y, position.z), properties)
	
	if success:
		# Store reference to dictionary entry in element
		if element.has_method("set_dictionary_entry"):
			element.set_dictionary_entry(word_id)
		
		# Emit signal
		emit_signal("entity_registered", entity_id, word_id, element_id)
		
		return entity_id
	
	return ""

# Create a thing from a word definition
func create_thing_from_word(word_id: String, position: Vector3) -> String:
	if not thing_creator or not akashic_records_manager:
		return ""
	
	# Check if word exists
	var word_data = akashic_records_manager.get_word(word_id)
	if word_data.size() == 0:
		print("Cannot create thing: word " + word_id + " does not exist")
		return ""
	
	# Create thing
	var thing_id = thing_creator.create_thing(word_id, position, word_data.get("properties", {}))
	
	if thing_id.is_empty():
		print("Failed to create thing from word: " + word_id)
		return ""
	
	print("Created thing " + thing_id + " from word " + word_id)
	
	# If element manager exists, try to create visual element
	if element_manager and word_data.get("category", "") == "element":
		var element_type = word_id
		if element_type in ["fire", "water", "wood", "ash"]:
			var element = element_manager.create_element(element_type, position)
			if element:
				print("Created visual element for thing " + thing_id)
	
	return thing_id

# Enhanced interaction matrix
var interaction_matrix = null

# Process interaction between two things
func process_thing_interaction(thing1_id: String, thing2_id: String) -> Dictionary:
	if not thing_creator:
		return {"success": false, "reason": "thing_creator_not_found"}

	# Initialize the interaction matrix if not already done
	if interaction_matrix == null:
		interaction_matrix = InteractionMatrix.new()

	# Get thing data
	var thing1 = thing_creator.get_thing(thing1_id)
	var thing2 = thing_creator.get_thing(thing2_id)

	if thing1.size() == 0 or thing2.size() == 0:
		return {"success": false, "reason": "thing_not_found"}

	# Get the entity types
	var type1 = thing1.word_id
	var type2 = thing2.word_id

	# Get positions for potential new entity creation
	var pos1 = thing1.position
	var pos2 = thing2.position
	var mid_position = Vector3(
		(pos1.x + pos2.x) / 2,
		(pos1.y + pos2.y) / 2,
		(pos1.z + pos2.z) / 2
	)

	# Create context from entity properties
	var context = {
		"distance": pos1.distance_to(pos2),
		"mid_position": mid_position
	}

	# Add properties to context
	if thing1.has("properties"):
		for prop in thing1.properties:
			context[thing1_id + "_" + prop] = thing1.properties[prop]

	if thing2.has("properties"):
		for prop in thing2.properties:
			context[thing2_id + "_" + prop] = thing2.properties[prop]

	# Use the interaction matrix to get the result
	var interaction_result = interaction_matrix.process_interaction(type1, type2, context)

	# Apply the interaction results
	if interaction_result.success:
		# Handle different interaction types
		match interaction_result.type:
			"property_change":
				_apply_property_changes(thing1_id, thing2_id, interaction_result)

			"state_change":
				_apply_state_changes(thing1_id, thing2_id, interaction_result)

			"create":
				_handle_entity_creation(thing1_id, thing2_id, interaction_result, mid_position)

			"consume":
				_handle_consumption(thing1_id, thing2_id, interaction_result)

			"merge":
				_handle_entity_merge(thing1_id, thing2_id, interaction_result, mid_position)

		# Handle transformations
		if interaction_result.has("transformation") and interaction_result.transformation.triggered:
			_handle_transformation(thing1_id, thing2_id, interaction_result)

		# Emit signal
		emit_signal("interaction_processed", thing1_id, thing2_id, interaction_result)

	return interaction_result

# Apply property changes from interaction
func _apply_property_changes(thing1_id: String, thing2_id: String, result: Dictionary) -> void:
	if not result.has("effects"):
		return

	var thing1 = thing_creator.get_thing(thing1_id)
	var thing2 = thing_creator.get_thing(thing2_id)

	if thing1.size() == 0 or thing2.size() == 0:
		return

	# Determine which entity to modify
	var target_id = thing1_id
	if result.has("target") and result.target == "other":
		target_id = thing2_id

	# Apply property changes
	var properties = {}
	for effect_name in result.effects:
		if effect_name is String and result.has(effect_name):
			properties[effect_name] = result[effect_name]

	# Update the properties
	if properties.size() > 0:
		thing_creator.update_thing_properties(target_id, properties)

# Apply state changes from interaction
func _apply_state_changes(thing1_id: String, thing2_id: String, result: Dictionary) -> void:
	if not result.has("state_change") or not result.state_change.has("new_state"):
		return

	var new_state = result.state_change.new_state

	# Determine which entity to modify
	var target_id = thing1_id
	if result.has("target") and result.target == "other":
		target_id = thing2_id

	# Update state (simplified - in a real implementation, you would have a state system)
	var properties = {"state": new_state}
	thing_creator.update_thing_properties(target_id, properties)

# Handle entity creation from interaction
func _handle_entity_creation(thing1_id: String, thing2_id: String, result: Dictionary, position: Vector3) -> void:
	if not result.has("create") or not result.create.has("type"):
		return

	var new_type = result.create.type
	var new_position = position

	# Create the new entity
	var new_thing_id = create_thing_from_word(new_type, new_position)

	# Add to result for reference
	result["new_thing_id"] = new_thing_id

	# Handle consumption of parent entities if specified
	if result.create.get("consume_parents", false):
		thing_creator.destroy_thing(thing1_id)
		thing_creator.destroy_thing(thing2_id)

# Handle entity consumption
func _handle_consumption(thing1_id: String, thing2_id: String, result: Dictionary) -> void:
	if not result.has("consume"):
		return

	var consume_data = result.consume

	# Determine which entity consumes and which is consumed
	var consumer_id = thing1_id
	var consumed_id = thing2_id

	if consume_data.target == "self":
		# The first entity is consumed
		consumer_id = thing2_id
		consumed_id = thing1_id

	# Apply energy transfer before destruction
	if consume_data.has("energy_transfer") and consume_data.energy_transfer > 0:
		var consumer = thing_creator.get_thing(consumer_id)
		if consumer.size() > 0:
			var energy_gain = consume_data.energy_transfer
			var properties = {"energy": energy_gain}
			thing_creator.update_thing_properties(consumer_id, properties)

	# Check consumption amount
	var consumption_amount = consume_data.get("amount", 1.0)
	if consumption_amount >= 0.9:
		# Complete consumption - destroy the entity
		thing_creator.destroy_thing(consumed_id)
	else:
		# Partial consumption - reduce size or other property
		var consumed = thing_creator.get_thing(consumed_id)
		if consumed.size() > 0:
			var properties = {"size": max(0.1, consumed.get("size", 1.0) * (1.0 - consumption_amount))}
			thing_creator.update_thing_properties(consumed_id, properties)

# Handle entity merging
func _handle_entity_merge(thing1_id: String, thing2_id: String, result: Dictionary, position: Vector3) -> void:
	if not result.has("merge"):
		return

	var merge_data = result.merge

	var thing1 = thing_creator.get_thing(thing1_id)
	var thing2 = thing_creator.get_thing(thing2_id)

	if thing1.size() == 0 or thing2.size() == 0:
		return

	# Determine result type - for now use the same type as thing1
	var merged_type = thing1.word_id

	# Create merged properties
	var properties = {}

	# Retain specified properties from first entity
	if merge_data.has("retain_properties"):
		for prop in merge_data.retain_properties:
			if thing1.properties.has(prop):
				properties[prop] = thing1.properties[prop]

	# Combine specified properties
	if merge_data.has("combine_properties"):
		for prop in merge_data.combine_properties:
			var combined_value = 0.0
			if thing1.properties.has(prop):
				combined_value += thing1.properties[prop]
			if thing2.properties.has(prop):
				combined_value += thing2.properties[prop]
			properties[prop] = combined_value

	# Create the merged entity
	var new_thing_id = create_thing_from_word(merged_type, position)

	# Apply merged properties
	if new_thing_id and properties.size() > 0:
		thing_creator.update_thing_properties(new_thing_id, properties)

	# Destroy the original entities
	thing_creator.destroy_thing(thing1_id)
	thing_creator.destroy_thing(thing2_id)

	# Add to result for reference
	result["merged_thing_id"] = new_thing_id

# Handle entity transformation
func _handle_transformation(thing1_id: String, thing2_id: String, result: Dictionary) -> void:
	if not result.has("transformation") or not result.transformation.triggered:
		return

	var transform_data = result.transformation

	# Determine which entity transforms
	var target_id = thing1_id
	if transform_data.has("target_entity") and transform_data.target_entity == "other":
		target_id = thing2_id

	# Get the target type
	var new_type = transform_data.target

	# Transform the entity
	var success = transform_thing(target_id, new_type)

	# Add transformation result
	result["transformation_success"] = success

# Transform a thing to a new type
func transform_thing(thing_id: String, new_type: String) -> bool:
	if not thing_creator or not akashic_records_manager:
		return false
	
	# Get thing data
	var thing_data = thing_creator.get_thing(thing_id)
	if thing_data.size() == 0:
		print("Cannot transform thing: thing " + thing_id + " not found")
		return false
	
	# Get current word type
	var current_word_id = thing_data.word_id
	
	# Check if new type exists in dictionary
	var new_word_data = akashic_records_manager.get_word(new_type)
	if new_word_data.size() == 0:
		print("Cannot transform thing: word " + new_type + " does not exist")
		return false
	
	# Get thing position
	var position = thing_data.position
	
	# Create new thing of the new type
	var new_thing_id = create_thing_from_word(new_type, position)
	
	if new_thing_id.is_empty():
		print("Failed to create transformed thing")
		return false
	
	# Destroy old thing
	thing_creator.destroy_thing(thing_id)
	
	# Emit signal
	emit_signal("entity_transformed", new_thing_id, current_word_id, new_type)
	
	print("Transformed thing " + thing_id + " from " + current_word_id + " to " + new_type + " (new ID: " + new_thing_id + ")")
	return true

# Manifest a word as a pattern of elements
func manifest_word_as_elements(word_id: String, position: Vector3, size: float = 10.0) -> Array:
	if not element_manager or not akashic_records_manager:
		return []
	
	# Check if word exists
	var word_data = akashic_records_manager.get_word(word_id)
	if word_data.size() == 0:
		print("Cannot manifest word: word " + word_id + " does not exist")
		return []
	
	# Use Element Manager to manifest the word
	var elements = element_manager.manifest_word(word_id, position, size)
	
	# Register all elements with the dictionary
	var entity_ids = []
	for element in elements:
		if is_instance_valid(element):
			var entity_id = register_element(element, element.get("type", "unknown"))
			if not entity_id.is_empty():
				entity_ids.append(entity_id)
	
	return entity_ids

# Create a dictionary entry for a visualization concept
func create_visualization_entry(concept_name: String, properties: Dictionary = {}) -> bool:
	if not akashic_records_manager:
		return false
	
	# Check if concept already exists
	var concept = akashic_records_manager.get_word(concept_name)
	if concept.size() > 0:
		print("Visualization concept " + concept_name + " already exists")
		return true
	
	# Create default properties if not provided
	var default_properties = {
		"visual_intensity": 0.7,
		"color_hue": randf(),
		"color_saturation": 0.8,
		"color_value": 0.9,
		"pattern_complexity": 0.5,
		"movement_speed": 0.5,
		"particle_count": 100,
		"lifetime": 5.0
	}
	
	# Merge with provided properties
	for key in properties:
		default_properties[key] = properties[key]
	
	# Create concept entry
	var concept_data = {
		"id": concept_name,
		"display_name": concept_name.capitalize(),
		"category": "visualization",
		"parent": "primordial",
		"description": "A visualization concept for manifestation",
		"properties": default_properties,
		"states": {
			"current": "manifest",
			"possible": ["manifest", "dissolve", "transform", "blend"]
		}
	}
	
	return akashic_records_manager.create_word(concept_name, "visualization", concept_data.properties)

# Send command to console
func send_console_command(command: String) -> void:
	if console_system and console_system.has_method("process_command"):
		console_system.process_command(command)
	else:
		print("Cannot send command: console system not found or incompatible")

# Add menu entry
func add_menu_entry(category: String, entry: Dictionary) -> bool:
	if menu_system and menu_system.has_method("add_menu_entry"):
		menu_system.add_menu_entry(category, entry)
		return true
	return false

# Create menu entries for element management
func create_element_menu_entries() -> void:
	if not menu_system:
		return
	
	# Create menu entries for each element type
	var element_types = ["fire", "water", "wood", "ash"]
	
	for element_type in element_types:
		var entry = {
			"id": "create_" + element_type,
			"display_name": "Create " + element_type.capitalize(),
			"description": "Creates a new " + element_type + " element at the cursor position",
			"action": "create_element",
			"parameters": {
				"type": element_type
			}
		}
		
		add_menu_entry("elements", entry)
	
	# Add transformation menu
	var transform_entry = {
		"id": "transform_element",
		"display_name": "Transform Element",
		"description": "Transform selected element to a new type",
		"action": "transform_element",
		"parameters": {
			"types": element_types
		}
	}
	
	add_menu_entry("elements", transform_entry)
	
	# Add word manifestation menu
	var manifest_entry = {
		"id": "manifest_word",
		"display_name": "Manifest Word",
		"description": "Manifest a word as a pattern of elements",
		"action": "manifest_word",
		"parameters": {
			"size": 10.0
		}
	}
	
	add_menu_entry("words", manifest_entry)

# Signal handlers

func _on_word_created(word_id: String) -> void:
	# A new word was created in the dictionary
	print("Word created in dictionary: " + word_id)
	emit_signal("dictionary_updated", word_id)
	
	# Update menu if needed
	# TODO

func _on_word_updated(word_id: String) -> void:
	# A word was updated in the dictionary
	print("Word updated in dictionary: " + word_id)
	emit_signal("dictionary_updated", word_id)

func _on_akashic_entity_created(entity_id: String) -> void:
	# An entity was created in the Akashic Records
	print("Entity created in Akashic Records: " + entity_id)
	
	# TODO: Check if we need to create a visual representation

func _on_akashic_interaction_processed(result) -> void:
	# An interaction was processed in the Akashic Records
	print("Interaction processed in Akashic Records: ", result.get("type", "unknown"))
	
	# TODO: Apply visual effects based on interaction result

func _on_element_created(element, type: String) -> void:
	# An element was created in the Element Manager
	print("Element created in Element Manager: " + type)
	
	# Register element with the dictionary
	register_element(element, type)

func _on_element_transformed(old_element, new_element) -> void:
	# An element was transformed in the Element Manager
	print("Element transformed in Element Manager")
	
	# Update dictionary entries
	if old_element and new_element:
		var old_type = old_element.get("type", "unknown")
		var new_type = new_element.get("type", "unknown")
		
		# Register new element
		register_element(new_element, new_type)
		
		emit_signal("entity_transformed", new_element.get_instance_id(), old_type, new_type)

func _on_thing_created(thing_id: String, word_id: String, position: Vector3) -> void:
	# A thing was created in the Thing Creator
	print("Thing created in Thing Creator: " + thing_id + " with word " + word_id)
	
	# Check if we need to create a visual element
	if element_manager:
		var word_data = akashic_records_manager.get_word(word_id)
		if word_data.size() > 0 and word_data.get("category", "") == "element":
			var element_type = word_id
			if element_type in ["fire", "water", "wood", "ash"]:
				element_manager.create_element(element_type, position)

func _on_thing_destroyed(thing_id: String) -> void:
	# A thing was destroyed in the Thing Creator
	print("Thing destroyed in Thing Creator: " + thing_id)
	
	# TODO: Handle visual cleanup if needed

func _on_thing_moved(thing_id: String, old_position: Vector3, new_position: Vector3) -> void:
	# A thing was moved in the Thing Creator
	# Update visual representation if exists

	# This would require a mapping between thing_ids and element instances
	# TODO: Implement if needed
	pass

# Safe method to find the element manager
func _find_element_manager() -> void:
	if not is_inside_tree():
		# Still not in tree? Try again later
		call_deferred("_find_element_manager")
		return

	var tree = get_tree()
	if tree != null:
		var nodes = tree.get_nodes_in_group("element_manager")
		if nodes.size() > 0:
			element_manager = nodes[0]
			print("Found element manager via group")
	else:
		print("Tree still not available for finding element manager")
