extends Node
class_name AkashicRecordsManagerA

# Singleton pattern
static var _instance: AkashicRecordsManagerA = null

# Public property for initialization status
var is_initialized: bool = false

# Static function to get the singleton instance
static func get_instance() -> AkashicRecordsManagerA:
    if not _instance:
        _instance = AkashicRecordsManagerA.new()
    return _instance

# System references
var jsh_records_system: Node = null
var jsh_database_system: Node = null

# Entity tracking
var entities: Dictionary = {}
var entities_by_type: Dictionary = {}

# Dictionary tracking
var dictionaries: Dictionary = {}

# Zone management
var zone_manager: ZoneManager = null

# Signals
signal entity_registered(entity)
signal entity_updated(entity)
signal entity_removed(entity_id)
signal dictionary_updated(dict_name)
signal zone_updated(zone_id)

func _ready() -> void:
    print("AkashicRecordsManager: Ready")

func initialize(records_system: Node = null, database_system: Node = null) -> void:
    jsh_records_system = records_system
    jsh_database_system = database_system

    print("AkashicRecordsManagerA: Initialized with system references")

    # Initialize core dictionaries
    _init_core_dictionaries()

    # Initialize zone manager
    _init_zone_manager()

    # Mark as initialized
    is_initialized = true
    print("AkashicRecordsManagerA: Marked as initialized")

# Entity management
func register_entity(entity: Node) -> bool:
    if entity == null or not entity is UniversalEntity:
        print("AkashicRecordsManager: Cannot register invalid entity")
        return false
    
    var entity_id = entity.get_id()
    var entity_type = entity.get_type()
    
    # Store in main entities dictionary
    entities[entity_id] = entity
    
    # Add to type-based tracking
    if not entities_by_type.has(entity_type):
        entities_by_type[entity_type] = []
    entities_by_type[entity_type].append(entity_id)
    
    # Connect to entity signals
    entity.connect("transformed", Callable(self, "_on_entity_transformed").bind(entity))
    entity.connect("property_changed", Callable(self, "_on_entity_property_changed").bind(entity))
    
    # Emit signal
    emit_signal("entity_registered", entity)
    
    print("AkashicRecordsManager: Registered entity ", entity_id, " of type ", entity_type)
    return true

func unregister_entity(entity_id: String) -> bool:
    if not entities.has(entity_id):
        print("AkashicRecordsManager: Cannot unregister non-existent entity ", entity_id)
        return false
    
    var entity = entities[entity_id]
    var entity_type = entity.get_type()
    
    # Remove from type-based tracking
    if entities_by_type.has(entity_type):
        var index = entities_by_type[entity_type].find(entity_id)
        if index >= 0:
            entities_by_type[entity_type].remove_at(index)
    
    # Disconnect from entity signals
    if entity.is_connected("transformed", Callable(self, "_on_entity_transformed")):
        entity.disconnect("transformed", Callable(self, "_on_entity_transformed"))
    
    if entity.is_connected("property_changed", Callable(self, "_on_entity_property_changed")):
        entity.disconnect("property_changed", Callable(self, "_on_entity_property_changed"))
    
    # Remove from main entities dictionary
    entities.erase(entity_id)
    
    # Emit signal
    emit_signal("entity_removed", entity_id)
    
    print("AkashicRecordsManager: Unregistered entity ", entity_id)
    return true

func update_entity_type(entity_id: String, new_type: String) -> bool:
    if not entities.has(entity_id):
        print("AkashicRecordsManager: Cannot update non-existent entity ", entity_id)
        return false
    
    var entity = entities[entity_id]
    var old_type = entity.get_type()
    
    # No need to update if type hasn't changed
    if old_type == new_type:
        return true
    
    # Remove from old type-based tracking
    if entities_by_type.has(old_type):
        var index = entities_by_type[old_type].find(entity_id)
        if index >= 0:
            entities_by_type[old_type].remove_at(index)
    
    # Add to new type-based tracking
    if not entities_by_type.has(new_type):
        entities_by_type[new_type] = []
    entities_by_type[new_type].append(entity_id)
    
    # Emit signal
    emit_signal("entity_updated", entity)
    
    print("AkashicRecordsManager: Updated entity ", entity_id, " type from ", old_type, " to ", new_type)
    return true

# Dictionary management
func _init_core_dictionaries() -> void:
    # Initialize core dictionaries
    dictionaries["entity_types"] = {
        "primordial": {
            "description": "The base form of all entities, pure potential",
            "properties": {},
            "transformations": ["fire", "water", "wood", "ash", "air", "earth", "metal"]
        },
        "fire": {
            "description": "Element of transformation and energy",
            "properties": {"energy": 10, "intensity": 3},
            "interactions": ["intensify", "diminish", "consume", "transform"]
        },
        "water": {
            "description": "Element of fluidity and life",
            "properties": {"energy": 8, "intensity": 2},
            "interactions": ["diminish", "fuse", "intensify", "transform", "create"]
        },
        "wood": {
            "description": "Element of growth and vitality",
            "properties": {"energy": 7, "intensity": 2},
            "interactions": ["consumed", "intensify", "fuse", "transform"]
        },
        "ash": {
            "description": "Element of remainder and renewal",
            "properties": {"energy": 3, "intensity": 1},
            "interactions": ["diminish", "transform", "fuse", "split"]
        },
        "air": {
            "description": "Element of movement and freedom",
            "properties": {"energy": 6, "intensity": 2},
            "interactions": ["intensify", "create", "split", "fuse", "transform"]
        },
        "earth": {
            "description": "Element of stability and grounding",
            "properties": {"energy": 9, "intensity": 1},
            "interactions": ["transform", "create", "intensify", "fuse"]
        },
        "metal": {
            "description": "Element of structure and conductivity",
            "properties": {"energy": 8, "intensity": 2},
            "interactions": ["transform", "diminish", "create", "fuse"]
        }
    }
    
    dictionaries["interaction_effects"] = {
        "none": {
            "description": "No effect occurs",
            "transformative": false
        },
        "intensify": {
            "description": "Increases the intensity of an entity",
            "transformative": false
        },
        "diminish": {
            "description": "Decreases the intensity of an entity",
            "transformative": false
        },
        "consume": {
            "description": "One entity consumes another",
            "transformative": true
        },
        "fuse": {
            "description": "Entities combine to form a new entity",
            "transformative": true
        },
        "transform": {
            "description": "Entity changes its nature",
            "transformative": true
        },
        "split": {
            "description": "Entity divides into multiple entities",
            "transformative": true
        },
        "create": {
            "description": "Interaction creates a new entity",
            "transformative": true
        },
        "transmute": {
            "description": "Both entities transform into new types",
            "transformative": true
        }
    }
    
    # Emit signals for dictionary updates
    emit_signal("dictionary_updated", "entity_types")
    emit_signal("dictionary_updated", "interaction_effects")
    
    print("AkashicRecordsManager: Core dictionaries initialized")

func get_dictionary(dict_name: String) -> Dictionary:
    if dictionaries.has(dict_name):
        return dictionaries[dict_name]
    return {}

func update_dictionary(dict_name: String, dict_data: Dictionary) -> bool:
    dictionaries[dict_name] = dict_data
    emit_signal("dictionary_updated", dict_name)
    return true

func add_dictionary_entry(dict_name: String, entry_key: String, entry_data: Dictionary) -> bool:
    if not dictionaries.has(dict_name):
        dictionaries[dict_name] = {}
    
    dictionaries[dict_name][entry_key] = entry_data
    emit_signal("dictionary_updated", dict_name)
    return true

# Zone management
func _init_zone_manager() -> void:
    # Get the singleton instance of ZoneManager
    zone_manager = ZoneManager.get_instance()

    # Connect signals
    zone_manager.connect("zone_created", Callable(self, "_on_zone_created"))
    zone_manager.connect("zone_updated", Callable(self, "_on_zone_updated"))
    zone_manager.connect("entity_added_to_zone", Callable(self, "_on_entity_added_to_zone"))
    zone_manager.connect("entity_removed_from_zone", Callable(self, "_on_entity_removed_from_zone"))

    print("AkashicRecordsManager: Zone manager initialized")

# Zone management - forward calls to ZoneManager
func create_zone(zone_id: String, zone_name: String, boundaries: Dictionary, properties: Dictionary = {}) -> bool:
    return zone_manager.create_zone(zone_id, zone_name, boundaries, properties)

func add_entity_to_zone(entity_id: String, zone_id: String) -> bool:
    if not entities.has(entity_id):
        print("AkashicRecordsManager: Cannot add non-existent entity to zone: ", entity_id)
        return false

    return zone_manager.add_entity_to_zone(entity_id, zone_id)

func _on_zone_created(zone_id: String) -> void:
    emit_signal("zone_updated", zone_id)

func _on_zone_updated(zone_id: String) -> void:
    emit_signal("zone_updated", zone_id)

func _on_entity_added_to_zone(entity_id: String, zone_id: String) -> void:
    # Could implement special logic here if needed
    pass

func _on_entity_removed_from_zone(entity_id: String, zone_id: String) -> void:
    # Could implement special logic here if needed
    pass

# Signal handlers
func _on_entity_transformed(old_type: String, new_type: String, entity: Node) -> void:
    update_entity_type(entity.get_id(), new_type)

func _on_entity_property_changed(property_name: String, old_value, new_value, entity: Node) -> void:
    emit_signal("entity_updated", entity)

# Getters for entities
func get_entity_by_id(entity_id: String) -> Node:
    if entities.has(entity_id):
        return entities[entity_id]
    return null

func get_entities_by_type(type: String) -> Array:
    var result = []
    
    if entities_by_type.has(type):
        for entity_id in entities_by_type[type]:
            if entities.has(entity_id):
                result.append(entities[entity_id])
    
    return result

func get_all_entity_types() -> Array:
    return entities_by_type.keys()

func get_entity_count_by_type(type: String) -> int:
    if entities_by_type.has(type):
        return entities_by_type[type].size()
    return 0

# Zone queries - forward to ZoneManager
func get_zone_by_id(zone_id: String) -> Dictionary:
    return zone_manager.get_zone(zone_id)

func get_entities_in_zone(zone_id: String) -> Array:
    var result = []
    var entity_ids = zone_manager.get_entities_in_zone(zone_id)

    for entity_id in entity_ids:
        if entities.has(entity_id):
            result.append(entities[entity_id])

    return result

func get_entity_zone(entity_id: String) -> String:
    return zone_manager.get_entity_zone(entity_id)

func get_all_zones() -> Array:
    return zone_manager.get_all_zones()

# Dictionary functionality for words/definitions
func get_word(word: String) -> Dictionary:
    # Check if the word exists in entity_types dictionary
    var entity_types = get_dictionary("entity_types")
    if entity_types.has(word):
        return entity_types[word]

    # Check other dictionaries if needed
    # For now, return an empty dictionary if word not found
    return {}

func get_dictionary_stats() -> Dictionary:
    var stats = {
        "words": [],
        "dictionaries": [],
        "total_words": 0
    }

    # Get all words from entity_types
    var entity_types = get_dictionary("entity_types")
    for word in entity_types.keys():
        stats["words"].append(word)

    # Get all dictionary names
    for dict_name in dictionaries.keys():
        stats["dictionaries"].append(dict_name)

    # Calculate total words across all dictionaries
    stats["total_words"] = stats["words"].size()

    return stats