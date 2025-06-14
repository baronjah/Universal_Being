extends Node
class_name AkashicRecordsManagerA

# Public property for initialization status
var is_initialized: bool = false

# References to subsystems
var dynamic_dictionary: DynamicDictionary
var interaction_engine: InteractionEngine
var zone_manager: ZoneManager
var evolution_manager = null

# Paths to dictionary files
const BASE_DICTIONARY_PATH = "res://dictionary/root_dictionary.json"
const USER_DICTIONARY_PATH = "user://dictionary/user_dictionary.json"

signal akashic_records_initialized
signal word_interaction_processed(result)
signal word_evolution_occurred(word_id)
signal word_created(word_id)
signal entity_created(entity_id)

func _ready():
	print("Initializing Akashic Records...")
	
	# Create subsystems
	dynamic_dictionary = DynamicDictionary.new()
	interaction_engine = InteractionEngine.new()
	zone_manager = ZoneManager.new()
	
	# Add as children
	add_child(dynamic_dictionary)
	add_child(interaction_engine)
	add_child(zone_manager)
	
	# Connect subsystems
	interaction_engine.dictionary = dynamic_dictionary
	dynamic_dictionary.interaction_engine = interaction_engine
	
	# Connect signals
	interaction_engine.connect("interaction_processed", Callable(self, "_on_interaction_processed"))
	dynamic_dictionary.connect("dictionary_loaded", Callable(self, "_on_dictionary_loaded"))
	
	# Load base dictionary
	_load_or_create_base_dictionary()
	
	# Create root zone
	var universe_bounds = AABB(Vector3(-1000, -1000, -1000), Vector3(2000, 2000, 2000))
	zone_manager.create_zone("universe", universe_bounds)
	zone_manager.activate_zone("universe")
	
	# Initialize evolution system if available
	_initialize_evolution_system()
	
	# Mark as initialized
	is_initialized = true
	emit_signal("akashic_records_initialized")
	print("Akashic Records initialized")

func _load_or_create_base_dictionary() -> void:
	# Try loading the user dictionary first
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("user://dictionary/"):
			dir.make_dir_recursive("user://dictionary/")
	
	var user_dict_loaded = false
	
	if FileAccess.file_exists(USER_DICTIONARY_PATH):
		user_dict_loaded = dynamic_dictionary.load_dictionary(USER_DICTIONARY_PATH)
	
	# If no user dictionary, try loading the base dictionary
	if not user_dict_loaded:
		var base_dict_loaded = dynamic_dictionary.load_dictionary(BASE_DICTIONARY_PATH)
		
		# If no base dictionary exists either, create a new one
		if not base_dict_loaded:
			_create_base_dictionary()

func _create_base_dictionary() -> void:
	print("Creating new base dictionary...")
	
	# Create base elements
	_create_element("fire", {
		"heat": 0.8,
		"light": 0.7,
		"energy": 0.9,
		"consumption": 0.5
	}, {
		"flame": {"default": true},
		"ember": {"properties": {"heat": 0.3, "light": 0.2}}
	})
	
	_create_element("water", {
		"flow": 0.8,
		"transparency": 0.7,
		"temperature": 0.4,
		"density": 0.6
	}, {
		"liquid": {"default": true},
		"ice": {"properties": {"flow": 0.0, "temperature": 0.0}},
		"vapor": {"properties": {"flow": 0.9, "density": 0.1}}
	})
	
	_create_element("wood", {
		"growth": 0.3,
		"density": 0.6,
		"moisture": 0.5,
		"flexibility": 0.4
	}, {
		"living": {"default": true},
		"dry": {"properties": {"moisture": 0.1, "flexibility": 0.2}}
	})
	
	_create_element("ash", {
		"density": 0.2,
		"fertility": 0.7,
		"heat_retention": 0.3,
		"dispersal": 0.8
	}, {
		"powder": {"default": true}
	})
	
	# Create interactions
	_add_interactions()
	
	# Save dictionary
	dynamic_dictionary.save_dictionary(BASE_DICTIONARY_PATH)
	dynamic_dictionary.save_dictionary(USER_DICTIONARY_PATH)
	print("Base dictionary created")

func _create_element(id: String, properties: Dictionary, states: Dictionary) -> void:
	var element = WordEntry.new(id, "element")
	element.properties = properties
	element.states = states
	
	# Find default state
	for state in states:
		if states[state].get("default", false):
			element.current_state = state
			break
	
	dynamic_dictionary.add_word(element)

func _add_interactions() -> void:
	# Fire + Wood -> Ash
	dynamic_dictionary.add_interaction_rule("fire", "wood", "ash", {"heat": "> 0.5"})
	
	# Water + Fire -> Vapor
	dynamic_dictionary.add_interaction_rule("water", "fire", "vapor", {"temperature": "> 0.7"})
	
	# Wood + Water -> Living Wood (enhanced growth)
	var wood_data = get_word("wood")
	if !wood_data.is_empty() && wood_data.has("properties"):
		var enhanced_properties = wood_data.properties.duplicate()
		enhanced_properties["growth"] = 0.8
		enhanced_properties["moisture"] = 0.9

		# Create enhanced_wood if it doesn't exist
		if !dynamic_dictionary.words.has("enhanced_wood"):
			create_word("enhanced_wood", "element", enhanced_properties)
		# Enhanced word is already added by create_word
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

func _initialize_evolution_system() -> void:
	# Try to load the evolution manager script
	var script = load("res://code/gdscript/scripts/akashic_records/evolution_manager.gd")
	if script:
		evolution_manager = script.new()
		evolution_manager.name = "EvolutionManager"
		evolution_manager.akashic_records = self
		add_child(evolution_manager)
		print("Evolution system initialized")
	else:
		print("Evolution manager script not found")

# Signal handlers
func _on_interaction_processed(word1_id, word2_id, result_id, success) -> void:
	if success:
		emit_signal("word_interaction_processed", {
			"word1": word1_id,
			"word2": word2_id,
			"result": result_id,
			"success": success
		})

func _on_dictionary_loaded() -> void:
	print("Dictionary loaded with ", dynamic_dictionary.words.size(), " words")

# Public API

func create_word(id: String, category: String, properties: Dictionary = {}, parent_id: String = "") -> bool:
	# Check if word already exists
	if dynamic_dictionary.words.has(id):
		return false
	
	# Create word
	var word = WordEntry.new(id, category)
	word.properties = properties
	
	# Set parent
	if not parent_id.is_empty():
		word.parent_id = parent_id
	
	# Add to dictionary
	return dynamic_dictionary.add_word(word)

func add_word_interaction(word1_id: String, word2_id: String, result_id: String, conditions: Dictionary = {}) -> bool:
	# Check if words exist
	if not dynamic_dictionary.words.has(word1_id) or not dynamic_dictionary.words.has(word2_id):
		return false
	
	# Add interaction rule
	dynamic_dictionary.add_interaction_rule(word1_id, word2_id, result_id, conditions)
	return true

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

func instantiate_entity(word_id: String, position: Vector3, zone_id: String = "universe") -> String:
	# Check if word exists
	if not dynamic_dictionary.words.has(word_id):
		return ""
	
	# Generate entity ID
	var entity_id = word_id + "_" + str(randi())
	
	# Add to zone
	if zone_manager.add_entity_to_zone(zone_id, entity_id, position):
		return entity_id
	
	return ""

func get_entities_near_position(position: Vector3, radius: float) -> Array:
	return zone_manager.get_entities_at_position(position, radius)

func search_words(query: String, category: String = "") -> Array:
	return dynamic_dictionary.search_words(query, category)

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

func get_word_properties(word_id: String) -> Dictionary:
	var word_data = get_word(word_id)
	if word_data.has("properties"):
		return word_data.properties
	return {}

func get_word_states(word_id: String) -> Dictionary:
	var word_data = get_word(word_id)
	if word_data.has("states"):
		return word_data.states
	return {}

func change_word_state(word_id: String, new_state: String) -> bool:
	# We can't use the get_word method here since we need the actual object
	if dynamic_dictionary && dynamic_dictionary.has_method("change_word_state"):
		return dynamic_dictionary.change_word_state(word_id, new_state)
	return false

func add_word_property(word_id: String, property_name: String, value) -> bool:
	# We can't use get_word method here since we need to modify the object
	if dynamic_dictionary && dynamic_dictionary.has_method("add_word_property"):
		return dynamic_dictionary.add_word_property(word_id, property_name, value)
	elif dynamic_dictionary && dynamic_dictionary.has_method("update_word_property"):
		return dynamic_dictionary.update_word_property(word_id, property_name, value)
	return false

func get_word_hierarchy(word_id: String, max_depth: int = -1) -> Dictionary:
	return dynamic_dictionary.get_word_hierarchy(word_id, max_depth)

func save_all() -> bool:
	# Save dictionary
	var dict_saved = dynamic_dictionary.save_dictionary(USER_DICTIONARY_PATH)
	
	# Save zones
	var zones_saved = true
	for zone_id in zone_manager.zones:
		zones_saved = zones_saved and zone_manager.save_zone(zone_id)
	
	return dict_saved and zones_saved

# Static instance access
static var _instance = null

static func get_instance() -> AkashicRecordsManagerA:
	if not _instance:
		_instance = AkashicRecordsManagerA.new()
	return _instance

func _enter_tree():
	_instance = self