extends RefCounted
class_name JSHDatabaseInterface

# Database interface defines standard methods that all database systems should implement

# Connection and initialization
func initialize() -> bool:
    push_error("JSHDatabaseInterface: initialize() method must be implemented by subclass")
    return false

func is_initialized() -> bool:
    push_error("JSHDatabaseInterface: is_initialized() method must be implemented by subclass")
    return false

func connect_to_database(connection_params: Dictionary = {}) -> bool:
    push_error("JSHDatabaseInterface: connect_to_database() method must be implemented by subclass")
    return false

func disconnect_from_database() -> bool:
    push_error("JSHDatabaseInterface: disconnect_from_database() method must be implemented by subclass")
    return false

# Entity operations
func store_entity(entity: JSHUniversalEntity) -> bool:
    push_error("JSHDatabaseInterface: store_entity() method must be implemented by subclass")
    return false

func load_entity(entity_id: String) -> JSHUniversalEntity:
    push_error("JSHDatabaseInterface: load_entity() method must be implemented by subclass")
    return null

func entity_exists(entity_id: String) -> bool:
    push_error("JSHDatabaseInterface: entity_exists() method must be implemented by subclass")
    return false

func delete_entity(entity_id: String) -> bool:
    push_error("JSHDatabaseInterface: delete_entity() method must be implemented by subclass")
    return false

func update_entity(entity: JSHUniversalEntity) -> bool:
    push_error("JSHDatabaseInterface: update_entity() method must be implemented by subclass")
    return false

# Query operations
func find_entities_by_type(entity_type: String) -> Array:
    push_error("JSHDatabaseInterface: find_entities_by_type() method must be implemented by subclass")
    return []

func find_entities_by_property(property_name: String, property_value) -> Array:
    push_error("JSHDatabaseInterface: find_entities_by_property() method must be implemented by subclass")
    return []

func find_entities_by_criteria(criteria: Dictionary) -> Array:
    push_error("JSHDatabaseInterface: find_entities_by_criteria() method must be implemented by subclass")
    return []

# Collection operations
func create_collection(collection_name: String) -> bool:
    push_error("JSHDatabaseInterface: create_collection() method must be implemented by subclass")
    return false

func delete_collection(collection_name: String) -> bool:
    push_error("JSHDatabaseInterface: delete_collection() method must be implemented by subclass")
    return false

func collection_exists(collection_name: String) -> bool:
    push_error("JSHDatabaseInterface: collection_exists() method must be implemented by subclass")
    return false

func list_collections() -> Array:
    push_error("JSHDatabaseInterface: list_collections() method must be implemented by subclass")
    return []

# Index operations
func create_index(collection_name: String, field_name: String) -> bool:
    push_error("JSHDatabaseInterface: create_index() method must be implemented by subclass")
    return false

func delete_index(collection_name: String, field_name: String) -> bool:
    push_error("JSHDatabaseInterface: delete_index() method must be implemented by subclass")
    return false

func index_exists(collection_name: String, field_name: String) -> bool:
    push_error("JSHDatabaseInterface: index_exists() method must be implemented by subclass")
    return false

# Dictionary operations (for word definitions, etc.)
func store_dictionary_entry(dictionary_name: String, entry_key: String, entry_data: Dictionary) -> bool:
    push_error("JSHDatabaseInterface: store_dictionary_entry() method must be implemented by subclass")
    return false

func load_dictionary_entry(dictionary_name: String, entry_key: String) -> Dictionary:
    push_error("JSHDatabaseInterface: load_dictionary_entry() method must be implemented by subclass")
    return {}

func dictionary_entry_exists(dictionary_name: String, entry_key: String) -> bool:
    push_error("JSHDatabaseInterface: dictionary_entry_exists() method must be implemented by subclass")
    return false

func delete_dictionary_entry(dictionary_name: String, entry_key: String) -> bool:
    push_error("JSHDatabaseInterface: delete_dictionary_entry() method must be implemented by subclass")
    return false

func get_dictionary(dictionary_name: String) -> Dictionary:
    push_error("JSHDatabaseInterface: get_dictionary() method must be implemented by subclass")
    return {}

# Zone operations
func store_zone(zone_id: String, zone_data: Dictionary) -> bool:
    push_error("JSHDatabaseInterface: store_zone() method must be implemented by subclass")
    return false

func load_zone(zone_id: String) -> Dictionary:
    push_error("JSHDatabaseInterface: load_zone() method must be implemented by subclass")
    return {}

func zone_exists(zone_id: String) -> bool:
    push_error("JSHDatabaseInterface: zone_exists() method must be implemented by subclass")
    return false

func delete_zone(zone_id: String) -> bool:
    push_error("JSHDatabaseInterface: delete_zone() method must be implemented by subclass")
    return false

func get_entities_in_zone(zone_id: String) -> Array:
    push_error("JSHDatabaseInterface: get_entities_in_zone() method must be implemented by subclass")
    return []

# Transaction management
func begin_transaction() -> bool:
    push_error("JSHDatabaseInterface: begin_transaction() method must be implemented by subclass")
    return false

func commit_transaction() -> bool:
    push_error("JSHDatabaseInterface: commit_transaction() method must be implemented by subclass")
    return false

func rollback_transaction() -> bool:
    push_error("JSHDatabaseInterface: rollback_transaction() method must be implemented by subclass")
    return false

# Statistics and maintenance
func get_statistics() -> Dictionary:
    push_error("JSHDatabaseInterface: get_statistics() method must be implemented by subclass")
    return {}

func optimize_database() -> bool:
    push_error("JSHDatabaseInterface: optimize_database() method must be implemented by subclass")
    return false

func compact_database() -> bool:
    push_error("JSHDatabaseInterface: compact_database() method must be implemented by subclass")
    return false

func backup_database(backup_path: String) -> bool:
    push_error("JSHDatabaseInterface: backup_database() method must be implemented by subclass")
    return false