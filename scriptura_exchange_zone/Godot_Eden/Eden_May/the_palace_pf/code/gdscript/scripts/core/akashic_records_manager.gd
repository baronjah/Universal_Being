# OLD FILE - Use core_akashic_records_manager.gd instead
extends Node
# This class name conflicts with the autoload singleton
# class_name AkashicRecordsManager

# Singleton instance
static var _instance = null

# Static function to get the singleton instance
static func get_instance() -> AkashicRecordsManager:
	if not _instance:
		_instance = AkashicRecordsManager.new()
	return _instance

# Signals
signal akashic_records_initialized
signal word_interaction_processed(result)
signal word_evolution_occurred(word_id)
signal word_created(word_id)
signal entity_created(entity_id)

# Dictionary system
var dynamic_dictionary = null

# Interaction engine
var interaction_engine = null

# Zone management
var zone_manager = null

# Evolution manager
var evolution_manager = null

# Constants
const USER_DICTIONARY_PATH = "user://akashic_records/dictionary"
const USER_ZONES_PATH = "user://akashic_records/zones"

func _ready():
	print("Initializing Akashic Records...")
	_initialize_dictionary()
	_initialize_interaction_engine()
	_initialize_zone_manager()
	_initialize_evolution_system()
	emit_signal("akashic_records_initialized")
	print("Akashic Records initialized")

# Initialize the dictionary system
func _initialize_dictionary() -> void:
	dynamic_dictionary = load("res://code/gdscript/scripts/akashic_records/dynamic_dictionary.gd").new()
	dynamic_dictionary.name = "DynamicDictionary"
	add_child(dynamic_dictionary)
	dynamic_dictionary.initialize(USER_DICTIONARY_PATH)
	
	# Create default entries if needed
	_create_default_entries()

# Initialize the interaction engine
func _initialize_interaction_engine() -> void:
	interaction_engine = load("res://code/gdscript/scripts/akashic_records/interaction_engine.gd").new()
	interaction_engine.name = "InteractionEngine"
	add_child(interaction_engine)
	
	# Set up basic interaction rules
	_create_basic_interactions()

# Initialize the zone manager
func _initialize_zone_manager() -> void:
	zone_manager = load("res://code/gdscript/scripts/akashic_records/zone_manager.gd").new()
	zone_manager.name = "ZoneManager"
	add_child(zone_manager)
	zone_manager.initialize(USER_ZONES_PATH)

# Create default dictionary entries
func _create_default_entries() -> void:
	# Check if dictionary is empty
	if dynamic_dictionary.words.size() == 0:
		# Create primordial
		create_word("primordial", "base", {
			"essence": 1.0,
			"stability": 1.0,
			"resonance": 0.5,
			"complexity": 0.0
		})

		# Create basic elements
		create_word("fire", "element", {
			"essence": 0.9,
			"stability": 0.3,
			"resonance": 0.8,
			"heat": 0.9,
			"energy": 0.8,
			"light": 0.7
		}, "primordial")
		
		create_word("water", "element", {
			"essence": 0.8,
			"stability": 0.7,
			"resonance": 0.6,
			"flow": 0.9,
			"clarity": 0.7,
			"moisture": 0.8
		}, "primordial")
		
		create_word("wood", "element", {
			"essence": 0.7,
			"stability": 0.8,
			"resonance": 0.5,
			"growth": 0.7,
			"structure": 0.6,
			"life": 0.7
		}, "primordial")
		
		create_word("ash", "element", {
			"essence": 0.6,
			"stability": 0.9,
			"resonance": 0.3,
			"fertilizer": 0.7,
			"dissolution": 0.6,
			"transformation": 0.5
		}, "primordial")
		
		print("Dictionary loaded with " + str(dynamic_dictionary.words.size()) + " words")

# Create basic interaction rules
func _create_basic_interactions() -> void:
	# Fire + Water -> Vapor
	dynamic_dictionary.add_interaction_rule("fire", "water", "vapor", {"temperature": "> 0.7"})
	
	# Wood + Water -> Enhanced Wood (enhanced growth)
	var wood_data = get_word("wood")
	if !wood_data.is_empty() && wood_data.has("properties"):
		var enhanced_properties = wood_data.properties.duplicate()
		enhanced_properties["growth"] = 0.8
		enhanced_properties["moisture"] = 0.9
		
		# Create enhanced_wood if it doesn't exist
		if !dynamic_dictionary.words.has("enhanced_wood"):
			create_word("enhanced_wood", "element", enhanced_properties)
			
		# Add interaction rule
		dynamic_dictionary.add_interaction_rule("wood", "water", "enhanced_wood", {"moisture": "< 0.8"})
	
	# Ash + Water -> Soil
	var soil_properties = {
		"fertility": 0.9,
		"moisture": 0.7,
		"density": 0.8,
		"nutrients": 0.8
	}
	
	# Create soil if it doesn't exist
	if !dynamic_dictionary.words.has("soil"):
		create_word("soil", "element", soil_properties)
	
	# Add the interaction rule
	dynamic_dictionary.add_interaction_rule("ash", "water", "soil")

# Initialize the evolution system
func _initialize_evolution_system() -> void:
	evolution_manager = load("res://code/gdscript/scripts/akashic_records/evolution_manager.gd").new()
	evolution_manager.name = "EvolutionManager"
	add_child(evolution_manager)
	evolution_manager.initialize(dynamic_dictionary)
	print("Evolution system initialized")

# Public API

# Create a new word entry
func create_word(id: String, category: String, properties: Dictionary = {}, parent_id: String = "") -> bool:
	# Check if word already exists
	if dynamic_dictionary.words.has(id):
		return false
		
	# Create word entry
	var success = dynamic_dictionary.add_word(id, category, properties, parent_id)
	
	if success:
		# Emit signal
		emit_signal("word_created", id)
	
	return success

# Get a word definition by ID
func get_word(word_id: String) -> Dictionary:
	if dynamic_dictionary && dynamic_dictionary.has_method("get_word"):
		var word = dynamic_dictionary.get_word(word_id)
		if word:
			# Ensure we return a Dictionary, not an Object
			if word is Dictionary:
				return word
			elif word.has_method("to_dict"):
				# If it's a custom WordEntry with a to_dict method
				return word.to_dict()
			elif word.has_method("get_properties"):
				# Try to convert the object to a dictionary
				var result = {}
				result["id"] = word_id
				result["properties"] = word.get_properties()
				if word.has_method("get_category"):
					result["category"] = word.get_category()
				return result
	return {}

# Get statistics about the dictionary
func get_dictionary_stats() -> Dictionary:
	var stats = {
		"words": []
	}
	
	if dynamic_dictionary:
		# If dynamic_dictionary has a get_all_word_ids method, use it
		if dynamic_dictionary.has_method("get_all_word_ids"):
			stats.words = dynamic_dictionary.get_all_word_ids()
		# Otherwise, try to access words directly if it's a property
		elif dynamic_dictionary.get("words") is Dictionary:
			stats.words = dynamic_dictionary.words.keys()
		# Fallback to at least some basic words
		else:
			stats.words = ["primordial", "fire", "water", "wood", "ash"]
	
	return stats

# Get a word's properties
func get_word_properties(word_id: String) -> Dictionary:
	var word_data = get_word(word_id)
	if word_data.has("properties"):
		return word_data.properties
	return {}

# Process an interaction between two words
func process_word_interaction(word1_id: String, word2_id: String, context: Dictionary = {}) -> Dictionary:
	# Check if words exist
	if not dynamic_dictionary.words.has(word1_id) or not dynamic_dictionary.words.has(word2_id):
		return {"success": false, "error": "Words not found"}
	
	# Get words as dictionaries
	var word1_data = get_word(word1_id)
	var word2_data = get_word(word2_id)
	
	# Process interaction directly with dictionary if possible
	if interaction_engine.has_method("process_interaction_with_dict"):
		return interaction_engine.process_interaction_with_dict(word1_data, word2_data, context)
		
	# Fallback implementation
	var result = {
		"success": true,
		"type": "interaction",
		"description": "Interaction between " + word1_id + " and " + word2_id,
		"result": ""
	}
	
	# Look for an interaction rule
	if dynamic_dictionary.has_method("get_interaction_result"):
		var rule_result = dynamic_dictionary.get_interaction_result(word1_id, word2_id, context)
		if rule_result.size() > 0:
			result["result"] = rule_result.get("result", "")
			result["description"] = rule_result.get("description", result["description"])
	
	emit_signal("word_interaction_processed", result)
	return result

# Create an entity in the system
func create_entity(entity_id: String, type: String, position: Vector3, properties: Dictionary = {}) -> bool:
	# Create entity in appropriate zone
	var zone_id = zone_manager.get_zone_for_position(position)
	
	# Create entity in zone
	var success = zone_manager.add_entity_to_zone(zone_id, entity_id, type, position, properties)
	
	if success:
		# Emit signal
		emit_signal("entity_created", entity_id)
	
	return success

# Search words in the dictionary
func search_words(query: String = "", category: String = "") -> Array:
	var matching_words = []
	
	if dynamic_dictionary && dynamic_dictionary.words:
		for word_id in dynamic_dictionary.words:
			var word = dynamic_dictionary.get_word(word_id)
			
			# Skip if not a Dictionary or doesn't have required properties
			if not word:
				continue
				
			# Check category filter if set
			if !category.is_empty() && word.get("category", "") != category:
				continue
				
			# Check query if set
			if !query.is_empty():
				if !word_id.to_lower().contains(query.to_lower()):
					# If word ID doesn't match, check properties
					var found = false
					for prop_name in word.get("properties", {}):
						if prop_name.to_lower().contains(query.to_lower()):
							found = true
							break
							
					if !found:
						continue
			
			# Add to results if all filters pass
			matching_words.append(word_id)
	
	return matching_words

# Change a word's state
func change_word_state(word_id: String, new_state: String) -> bool:
	if dynamic_dictionary && dynamic_dictionary.has_method("set_word_state"):
		return dynamic_dictionary.set_word_state(word_id, new_state)
	return false

# Instantiate an entity from a word type
func instantiate_entity(word_id: String, position: Vector3) -> String:
	var entity_id = word_id + "_" + str(randi())
	
	if create_entity(entity_id, word_id, position):
		return entity_id
	
	return ""

# Initialize with default configuration
func initialize() -> void:
	_initialize_dictionary()
	_initialize_interaction_engine()
	_initialize_zone_manager()
	_initialize_evolution_system()
	emit_signal("akashic_records_initialized")