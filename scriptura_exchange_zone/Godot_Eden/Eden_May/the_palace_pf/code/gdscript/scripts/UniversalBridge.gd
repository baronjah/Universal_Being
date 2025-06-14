extends Node
class_name UniversalBridgeSystem

# This class serves as the central connection point between all major systems:
# - Akashic Records (Dictionary)
# - Element System
# - Thing Creator
# - Menu/Console System
# - Zone Management

# Singleton instance
static var _instance = null

# System references
var akashic_records_manager = null
var element_manager = null
var thing_creator = null
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
		_instance = UniversalBridgeSystem.new()
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
	# Only try to find existing systems without creating new ones
	# for safety in our initial attempt

	# Find Akashic Records Manager (only if it already exists)
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")

	# Find Element Manager (only if it already exists)
	if has_node("/root/ElementManager"):
		element_manager = get_node("/root/ElementManager")
	elif is_inside_tree():
		var tree = get_tree()
		if tree != null:
			var nodes = tree.get_nodes_in_group("element_manager")
			if nodes.size() > 0:
				element_manager = nodes[0]

	# Find Thing Creator (only if it already exists)
	if has_node("/root/ThingCreator"):
		thing_creator = get_node("/root/ThingCreator")

	# Find Console System (only if it already exists)
	if has_node("/root/JSH_Console") or has_node("/root/main/JSH_console"):
		if has_node("/root/JSH_Console"):
			console_system = get_node("/root/JSH_Console")
		else:
			console_system = get_node("/root/main/JSH_console")

	# Print found systems for debugging
	if debug_mode:
		print("Found Akashic Records Manager: ", akashic_records_manager != null)
		print("Found Element Manager: ", element_manager != null)
		print("Found Thing Creator: ", thing_creator != null)
		print("Found Console System: ", console_system != null)

# Initialize any missing systems
func _initialize_missing_systems() -> void:
	# For now, just skip creating missing systems
	# We'll add these back gradually once we confirm the basics work
	print("Skipping system creation in initial simplified version")

	# Comment out the previous implementation for safety
	# Initialize Akashic Records Manager if needed
	#if not akashic_records_manager:
	#	var akashic_manager_script = load("res://code/gdscript/scripts/akashic_records/akashic_records_manager.gd")
	#	if akashic_manager_script:
	#		akashic_records_manager = akashic_manager_script.new()
	#		akashic_records_manager.name = "AkashicRecordsManager"
	#		get_tree().root.add_child(akashic_records_manager)
	#
	## Initialize Thing Creator if needed
	#if not thing_creator:
	#	var thing_creator_script = load("res://code/gdscript/scripts/akashic_records/thing_creator.gd")
	#	if thing_creator_script:
	#		thing_creator = thing_creator_script.new()
	#		thing_creator.name = "ThingCreator"
	#		get_tree().root.add_child(thing_creator)

# Connect signals between systems - simplified version
func _connect_signals() -> void:
	print("Signal connection skipped in initial simplified version")

	# Comment out previous implementation for safety
	# We'll add these back once the basic integration works

	## Connect Akashic Records signals
	#if akashic_records_manager:
	#	if not akashic_records_manager.is_connected("word_created", Callable(self, "_on_word_created")):
	#		akashic_records_manager.connect("word_created", Callable(self, "_on_word_created"))
	#
	#	if not akashic_records_manager.is_connected("word_updated", Callable(self, "_on_word_updated")):
	#		akashic_records_manager.connect("word_updated", Callable(self, "_on_word_updated"))
	#
	#	if not akashic_records_manager.is_connected("word_interaction_processed", Callable(self, "_on_word_interaction_processed")):
	#		akashic_records_manager.connect("word_interaction_processed", Callable(self, "_on_word_interaction_processed"))
	#
	## Connect Element Manager signals
	#if element_manager:
	#	if not element_manager.is_connected("element_created", Callable(self, "_on_element_created")):
	#		element_manager.connect("element_created", Callable(self, "_on_element_created"))
	#
	#	if not element_manager.is_connected("element_transformed", Callable(self, "_on_element_transformed")):
	#		element_manager.connect("element_transformed", Callable(self, "_on_element_transformed"))
	#
	## Connect Thing Creator signals
	#if thing_creator:
	#	if not thing_creator.is_connected("thing_created", Callable(self, "_on_thing_created")):
	#		thing_creator.connect("thing_created", Callable(self, "_on_thing_created"))
	#
	#	if not thing_creator.is_connected("thing_removed", Callable(self, "_on_thing_removed")):
	#		thing_creator.connect("thing_removed", Callable(self, "_on_thing_removed"))

# Ensure the primordial dictionary entry exists - simplified version
func _ensure_primordial_exists() -> void:
	print("Dictionary entry creation skipped in initial simplified version")

	# Comment out previous implementation for safety
	# We'll add it back once the basic integration works

	#if not akashic_records_manager:
	#	print("Cannot create primordial entry: Akashic Records Manager not found")
	#	return
	#
	#var primordial = akashic_records_manager.get_word("primordial")
	#if primordial.size() == 0:
	#	print("Creating primordial word definition")
	#	var primordial_data = {
	#		"id": "primordial",
	#		"display_name": "Primordial Essence",
	#		"category": "base",
	#		"description": "The fundamental essence from which all things can evolve",
	#		"properties": {
	#			"essence": 1.0,
	#			"stability": 1.0,
	#			"resonance": 0.5,
	#			"complexity": 0.0
	#		},
	#		"states": {
	#			"current": "stable",
	#			"possible": ["stable", "unstable", "transforming"]
	#		},
	#		"transformations": transformation_rules["primordial"]
	#	}
	#
	#	akashic_records_manager.create_word("primordial", "base", primordial_data.properties)
	#else:
	#	print("Primordial word definition already exists")

# Create basic element definitions if they don't exist - simplified version
func ensure_element_definitions() -> void:
	print("Element definitions creation skipped in initial simplified version")

	# Comment out previous implementation for safety
	# We'll add it back once the basic integration works

	#if not akashic_records_manager:
	#	print("Cannot create element definitions: Akashic Records Manager not found")
	#	return
	#
	#var elements = ["fire", "water", "wood", "ash"]
	#var properties = {
	#	"fire": {
	#		"essence": 0.9,
	#		"stability": 0.3,
	#		"resonance": 0.8,
	#		"complexity": 0.2,
	#		"heat": 0.9,
	#		"energy": 0.8,
	#		"light": 0.7
	#	},
	#	"water": {
	#		"essence": 0.8,
	#		"stability": 0.7,
	#		"resonance": 0.6,
	#		"complexity": 0.3,
	#		"flow": 0.9,
	#		"clarity": 0.7,
	#		"life_support": 0.8
	#	},
	#	"wood": {
	#		"essence": 0.7,
	#		"stability": 0.8,
	#		"resonance": 0.5,
	#		"complexity": 0.4,
	#		"growth": 0.8,
	#		"structure": 0.7,
	#		"life": 0.6
	#	},
	#	"ash": {
	#		"essence": 0.6,
	#		"stability": 0.9,
	#		"resonance": 0.3,
	#		"complexity": 0.2,
	#		"fertilizer": 0.7,
	#		"dissolution": 0.6,
	#		"transformation": 0.5
	#	}
	#}
	#
	#for element in elements:
	#	var element_def = akashic_records_manager.get_word(element)
	#	if element_def.size() == 0:
	#		print("Creating " + element + " word definition")
	#		var element_data = {
	#			"id": element,
	#			"display_name": element.capitalize(),
	#			"category": "element",
	#			"parent": "primordial",
	#			"description": "A basic elemental form",
	#			"properties": properties[element],
	#			"states": {
	#				"current": "stable",
	#				"possible": ["stable", "unstable", "transforming", "consuming", "diminishing"]
	#			},
	#			"transformations": transformation_rules.get(element, [])
	#		}
	#
	#		akashic_records_manager.create_word(element, "element", element_data.properties)
	#	else:
	#		print(element.capitalize() + " word definition already exists")

# Register an element with the dictionary - simplified version
func register_element(element, type_name: String) -> String:
	print("Element registration skipped in initial simplified version")

	# Just return a dummy entity ID for now
	var element_id = element.get_instance_id() if element else 0
	return "entity_" + type_name + "_" + str(element_id) + "_dummy"

	# Comment out previous implementation for safety
	# We'll add it back once the basic integration works

	#if not akashic_records_manager or not element:
	#	return ""
	#
	## Generate a unique ID
	#var element_id = element.get_instance_id()
	#var word_id = type_name + "_" + str(element_id)
	#
	## Get element position
	#var position = element.global_position
	#
	## Create entity in Akashic Records
	#var entity_id = "entity_" + word_id
	#var properties = {
	#	"element_id": element_id,
	#	"temperature": element.get("temperature", 0.0) if element.has("temperature") else 0.0,
	#	"energy": element.get("energy", 0.0) if element.has("energy") else 0.0,
	#	"mass": element.get("mass", 1.0) if element.has("mass") else 1.0
	#}
	#
	#var success = akashic_records_manager.create_entity(entity_id, type_name, Vector3(position.x, position.y, position.z), properties)
	#
	#if success:
	#	# Store reference to dictionary entry in element
	#	if element.has_method("set_dictionary_entry"):
	#		element.set_dictionary_entry(word_id)
	#
	#	# Emit signal
	#	emit_signal("entity_registered", entity_id, word_id, element_id)
	#
	#	return entity_id
	#
	#return ""

# Create a thing from a word definition - simplified version
func create_thing_from_word(word_id: String, position: Vector3) -> String:
	print("Thing creation skipped in initial simplified version")

	# Return a dummy thing ID
	return "thing_" + word_id + "_" + str(randi()) + "_dummy"

	# Comment out previous implementation for safety
	# We'll add it back once the basic integration works

	#if not thing_creator or not akashic_records_manager:
	#	return ""
	#
	## Check if word exists
	#var word_data = akashic_records_manager.get_word(word_id)
	#if word_data.size() == 0:
	#	print("Cannot create thing: word " + word_id + " does not exist")
	#	return ""
	#
	## Create thing
	#var thing_id = thing_creator.create_thing(word_id, position, word_data.get("properties", {}))
	#
	#if thing_id.is_empty():
	#	print("Failed to create thing from word: " + word_id)
	#	return ""
	#
	#print("Created thing " + thing_id + " from word " + word_id)
	#
	## If element manager exists, try to create visual element
	#if element_manager and word_data.get("category", "") == "element":
	#	var element_type = word_id
	#	if element_type in ["fire", "water", "wood", "ash"]:
	#		var element = element_manager.create_element(element_type, position)
	#		if element:
	#			print("Created visual element for thing " + thing_id)
	#
	#return thing_id

# Process interaction between two things - simplified version
func process_thing_interaction(thing1_id: String, thing2_id: String) -> Dictionary:
	print("Thing interaction skipped in initial simplified version")

	# Return a dummy successful interaction
	return {
		"success": true,
		"type": "interaction",
		"description": "Dummy interaction between " + thing1_id + " and " + thing2_id
	}

	# Comment out previous implementation for safety
	# We'll add it back once the basic integration works

	#if not thing_creator or not akashic_records_manager:
	#	return {"success": false, "reason": "required_systems_not_found"}
	#
	## Get thing word IDs
	#var word1_id = thing_creator.get_thing_word(thing1_id)
	#var word2_id = thing_creator.get_thing_word(thing2_id)
	#
	#if word1_id.is_empty() or word2_id.is_empty():
	#	return {"success": false, "reason": "thing_words_not_found"}
	#
	## Process word interaction in Akashic Records
	#var interaction_result = akashic_records_manager.process_word_interaction(word1_id, word2_id)
	#
	## Apply visual effects
	#if interaction_result.success and interaction_result.has("result"):
	#	var result_word_id = interaction_result.get("result")
	#
	#	# Create a new thing for the result if needed
	#	if not result_word_id.is_empty():
	#		# Calculate midpoint between the two things
	#		var pos1 = thing_creator.get_thing_position(thing1_id)
	#		var pos2 = thing_creator.get_thing_position(thing2_id)
	#		var midpoint = (pos1 + pos2) / 2
	#
	#		# Create the result thing
	#		var result_thing_id = create_thing_from_word(result_word_id, midpoint)
	#		interaction_result["result_thing_id"] = result_thing_id
	#
	## Emit signal
	#emit_signal("interaction_processed", thing1_id, thing2_id, interaction_result)
	#
	#return interaction_result

# Transform a thing to a new type - simplified version
func transform_thing(thing_id: String, new_type: String) -> bool:
	print("Thing transformation skipped in initial simplified version")

	# Return true to indicate success
	return true

	# Comment out previous implementation for safety
	# We'll add it back once the basic integration works

	#if not thing_creator or not akashic_records_manager:
	#	return false
	#
	## Check if the thing exists
	#if not thing_creator.has_thing(thing_id):
	#	print("Cannot transform thing: " + thing_id + " does not exist")
	#	return false
	#
	## Check if the new type exists in the dictionary
	#var type_definition = akashic_records_manager.get_word(new_type)
	#if type_definition.size() == 0:
	#	print("Cannot transform thing: type " + new_type + " does not exist")
	#	return false
	#
	## Get the current type and position
	#var current_type = thing_creator.get_thing_word(thing_id)
	#var position = thing_creator.get_thing_position(thing_id)
	#
	## Remove the old thing
	#thing_creator.remove_thing(thing_id)
	#
	## Create a new thing of the new type
	#var new_thing_id = create_thing_from_word(new_type, position)
	#
	#if new_thing_id.is_empty():
	#	print("Failed to transform thing " + thing_id + " to " + new_type)
	#	return false
	#
	#print("Transformed thing " + thing_id + " to " + new_type + " (new ID: " + new_thing_id + ")")
	#
	## Emit signal
	#emit_signal("entity_transformed", new_thing_id, current_type, new_type)
	#
	#return true

# Manifest a word as a pattern of elements - simplified version
func manifest_word_as_elements(word_id: String, position: Vector3, size: float = 10.0) -> Array:
	print("Element manifestation skipped in initial simplified version")

	# Return a dummy entity ID array
	return ["entity_" + word_id + "_dummy_1", "entity_" + word_id + "_dummy_2"]

	# Comment out previous implementation for safety
	# We'll add it back once the basic integration works

	#if not element_manager or not akashic_records_manager:
	#	return []
	#
	## Check if word exists
	#var word_data = akashic_records_manager.get_word(word_id)
	#if word_data.size() == 0:
	#	print("Cannot manifest word: word " + word_id + " does not exist")
	#	return []
	#
	## Use Element Manager to manifest the word
	#var elements = element_manager.manifest_word(word_id, position, size)
	#
	## Register all elements with the dictionary
	#var entity_ids = []
	#for element in elements:
	#	if is_instance_valid(element):
	#		var entity_id = register_element(element, element.get("type", "unknown"))
	#		if not entity_id.is_empty():
	#			entity_ids.append(entity_id)
	#
	#return entity_ids

# Signal handlers

func _on_word_created(word_id: String) -> void:
	# A new word was created in the dictionary
	print("Word created in dictionary: " + word_id)
	emit_signal("dictionary_updated", word_id)

func _on_word_updated(word_id: String) -> void:
	# A word was updated in the dictionary
	print("Word updated in dictionary: " + word_id)
	emit_signal("dictionary_updated", word_id)

func _on_word_interaction_processed(result) -> void:
	# An interaction was processed in the Akashic Records
	print("Interaction processed in Akashic Records: ", result.get("type", "unknown"))

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

func _on_thing_removed(thing_id: String) -> void:
	# A thing was destroyed in the Thing Creator
	print("Thing destroyed in Thing Creator: " + thing_id)

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