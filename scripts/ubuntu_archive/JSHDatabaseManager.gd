extends Node
class_name JSHDatabaseManager

# Singleton pattern
static var _instance: JSHDatabaseManager = null

static func get_instance() -> JSHDatabaseManager:
    if not _instance:
        _instance = JSHDatabaseManager.new()
    return _instance

# Database backend reference
var database: JSHDatabaseInterface = null
var file_storage: JSHFileStorageAdapter = null

# Default collection names
const ENTITY_COLLECTION = "entities"
const DICTIONARY_COLLECTION = "dictionaries"
const ZONE_COLLECTION = "zones"

# Entity manager reference (for syncing)
var entity_manager: JSHEntityManager = null

# Initialization and processing flags
var is_initialized: bool = false
var auto_save_enabled: bool = true
var auto_save_interval: float = 30.0  # seconds
var time_since_last_save: float = 0.0
var pending_saves: Dictionary = {}
var save_in_progress: bool = false

# Cache settings
var use_caching: bool = true
var entity_cache: Dictionary = {}
var entity_cache_limit: int = 1000
var collection_cache: Dictionary = {}

# Signals
signal database_initialized
signal entity_saved(entity_id)
signal entity_loaded(entity_id, entity)
signal entity_deleted(entity_id)
signal save_completed(success, count)
signal database_error(error_message)

func _init() -> void:
    if _instance == null:
        _instance = self
        name = "JSHDatabaseManager"
        print("JSHDatabaseManager: Instance created")

func _process(delta: float) -> void:
    if auto_save_enabled and is_initialized:
        time_since_last_save += delta
        
        if time_since_last_save >= auto_save_interval:
            time_since_last_save = 0.0
            save_pending_entities()

# Initialization
func initialize(backend: JSHDatabaseInterface = null, storage_adapter: JSHFileStorageAdapter = null) -> bool:
    print("JSHDatabaseManager: Initializing")
    
    # Set up database
    if backend:
        database = backend
    else:
        # Default to file system database if no backend specified
        database = JSHFileSystemDatabase.new()
    
    # Set up file storage adapter
    if storage_adapter:
        file_storage = storage_adapter
    else:
        file_storage = JSHFileStorageAdapter.new()
    
    # Initialize database backend
    var db_init_success = database.initialize()
    if not db_init_success:
        push_error("JSHDatabaseManager: Failed to initialize database backend")
        emit_signal("database_error", "Failed to initialize database backend")
        return false
    
    # Initialize file storage
    var storage_init_success = file_storage.initialize()
    if not storage_init_success:
        push_error("JSHDatabaseManager: Failed to initialize file storage")
        emit_signal("database_error", "Failed to initialize file storage")
        return false
    
    # Ensure core collections exist
    ensure_core_collections()
    
    # Try to get entity manager instance
    entity_manager = JSHEntityManager.get_instance()
    if entity_manager:
        print("JSHDatabaseManager: Connected to EntityManager")
        # Connect to signals for auto-saving
        entity_manager.connect("entity_updated", Callable(self, "_on_entity_updated"))
        entity_manager.connect("entity_created", Callable(self, "_on_entity_created"))
        entity_manager.connect("entity_destroyed", Callable(self, "_on_entity_destroyed"))
    
    is_initialized = true
    emit_signal("database_initialized")
    print("JSHDatabaseManager: Initialization complete")
    
    return true

func ensure_core_collections() -> void:
    # Create the standard collections if they don't exist
    if not database.collection_exists(ENTITY_COLLECTION):
        database.create_collection(ENTITY_COLLECTION)
        print("JSHDatabaseManager: Created entity collection")
    
    if not database.collection_exists(DICTIONARY_COLLECTION):
        database.create_collection(DICTIONARY_COLLECTION)
        print("JSHDatabaseManager: Created dictionary collection")
    
    if not database.collection_exists(ZONE_COLLECTION):
        database.create_collection(ZONE_COLLECTION)
        print("JSHDatabaseManager: Created zone collection")
    
    # Create standard indexes
    database.create_index(ENTITY_COLLECTION, "entity_type")
    database.create_index(ENTITY_COLLECTION, "zones")
    database.create_index(ENTITY_COLLECTION, "tags")
    database.create_index(ENTITY_COLLECTION, "evolution_stage")
    
    print("JSHDatabaseManager: Core collections and indexes verified")

# Entity operations
func save_entity(entity: JSHUniversalEntity, immediate: bool = false) -> bool:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return false
    
    var entity_id = entity.get_id()
    
    # If immediate save requested or entity is large, save now
    if immediate or entity.complexity > JSHUniversalEntity.COMPLEXITY_THRESHOLD_MED:
        var result = database.store_entity(entity)
        if result:
            # Update cache
            if use_caching:
                entity_cache[entity_id] = entity
            
            emit_signal("entity_saved", entity_id)
            print("JSHDatabaseManager: Saved entity " + entity_id)
        else:
            emit_signal("database_error", "Failed to save entity " + entity_id)
            return false
        
        return result
    else:
        # Otherwise, add to pending saves
        pending_saves[entity_id] = entity
        return true

func load_entity(entity_id: String) -> JSHUniversalEntity:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return null
    
    # Check cache first
    if use_caching and entity_cache.has(entity_id):
        print("JSHDatabaseManager: Entity " + entity_id + " found in cache")
        var entity = entity_cache[entity_id]
        emit_signal("entity_loaded", entity_id, entity)
        return entity
    
    # Load from database
    var entity = database.load_entity(entity_id)
    if entity:
        print("JSHDatabaseManager: Loaded entity " + entity_id)
        
        # Add to cache
        if use_caching:
            entity_cache[entity_id] = entity
            clean_cache_if_needed()
        
        emit_signal("entity_loaded", entity_id, entity)
    else:
        print("JSHDatabaseManager: Entity " + entity_id + " not found in database")
    
    return entity

func entity_exists(entity_id: String) -> bool:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return false
    
    # Check cache first
    if use_caching and entity_cache.has(entity_id):
        return true
    
    # Check database
    return database.entity_exists(entity_id)

func delete_entity(entity_id: String) -> bool:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return false
    
    # Remove from pending saves if present
    if pending_saves.has(entity_id):
        pending_saves.erase(entity_id)
    
    # Remove from cache if present
    if use_caching and entity_cache.has(entity_id):
        entity_cache.erase(entity_id)
    
    # Delete from database
    var result = database.delete_entity(entity_id)
    if result:
        print("JSHDatabaseManager: Deleted entity " + entity_id)
        emit_signal("entity_deleted", entity_id)
    else:
        emit_signal("database_error", "Failed to delete entity " + entity_id)
    
    return result

# Batch operations
func save_pending_entities() -> bool:
    if save_in_progress or pending_saves.size() == 0:
        return true
    
    save_in_progress = true
    print("JSHDatabaseManager: Saving " + str(pending_saves.size()) + " pending entities")
    
    var success = true
    var saved_count = 0
    var entity_ids = pending_saves.keys()
    
    database.begin_transaction()
    
    for entity_id in entity_ids:
        var entity = pending_saves[entity_id]
        var result = database.store_entity(entity)
        
        if result:
            saved_count += 1
            
            # Update cache
            if use_caching:
                entity_cache[entity_id] = entity
        else:
            print("JSHDatabaseManager: Failed to save entity " + entity_id)
            success = false
    
    if success:
        database.commit_transaction()
        pending_saves.clear()
    else:
        database.rollback_transaction()
    
    save_in_progress = false
    emit_signal("save_completed", success, saved_count)
    
    return success

func load_entities_by_type(entity_type: String) -> Array:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return []
    
    return database.find_entities_by_type(entity_type)

func load_entities_by_criteria(criteria: Dictionary) -> Array:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return []
    
    return database.find_entities_by_criteria(criteria)

# Dictionary operations
func save_dictionary_entry(dictionary_name: String, entry_key: String, entry_data: Dictionary) -> bool:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return false
    
    # Save to database
    var result = database.store_dictionary_entry(dictionary_name, entry_key, entry_data)
    
    if result:
        print("JSHDatabaseManager: Saved dictionary entry " + dictionary_name + ":" + entry_key)
        
        # Clear collection cache if using caching
        if use_caching and collection_cache.has(dictionary_name):
            collection_cache.erase(dictionary_name)
    else:
        emit_signal("database_error", "Failed to save dictionary entry " + dictionary_name + ":" + entry_key)
    
    return result

func load_dictionary_entry(dictionary_name: String, entry_key: String) -> Dictionary:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return {}
    
    return database.load_dictionary_entry(dictionary_name, entry_key)

func get_dictionary(dictionary_name: String) -> Dictionary:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return {}
    
    # Check cache first
    if use_caching and collection_cache.has(dictionary_name):
        return collection_cache[dictionary_name]
    
    # Load from database
    var dictionary = database.get_dictionary(dictionary_name)
    
    # Cache the result
    if use_caching:
        collection_cache[dictionary_name] = dictionary
    
    return dictionary

# Zone operations
func save_zone(zone_id: String, zone_data: Dictionary) -> bool:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return false
    
    return database.store_zone(zone_id, zone_data)

func load_zone(zone_id: String) -> Dictionary:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return {}
    
    return database.load_zone(zone_id)

func get_entities_in_zone(zone_id: String) -> Array:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return []
    
    return database.get_entities_in_zone(zone_id)

# Cache management
func clean_cache_if_needed() -> void:
    if not use_caching or entity_cache.size() <= entity_cache_limit:
        return
    
    print("JSHDatabaseManager: Entity cache limit reached, cleaning...")
    
    # Remove oldest entities until we're under the limit
    var excess_count = entity_cache.size() - entity_cache_limit
    var keys = entity_cache.keys()
    
    # Simple approach: just remove the first N items
    # In a more sophisticated system, we would use LRU or another cache eviction policy
    for i in range(excess_count):
        if i < keys.size():
            entity_cache.erase(keys[i])
    
    print("JSHDatabaseManager: Removed " + str(excess_count) + " items from cache")

func clear_cache() -> void:
    entity_cache.clear()
    collection_cache.clear()
    print("JSHDatabaseManager: Cache cleared")

# Entity manager signals
func _on_entity_updated(entity: JSHUniversalEntity) -> void:
    if auto_save_enabled:
        save_entity(entity)

func _on_entity_created(entity: JSHUniversalEntity) -> void:
    if auto_save_enabled:
        save_entity(entity)

func _on_entity_destroyed(entity_id: String) -> void:
    if auto_save_enabled:
        delete_entity(entity_id)

# Database management
func compact_database() -> bool:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return false
    
    return database.compact_database()

func optimize_database() -> bool:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return false
    
    return database.optimize_database()

func backup_database(backup_path: String) -> bool:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return false
    
    return database.backup_database(backup_path)

func get_database_statistics() -> Dictionary:
    if not is_initialized:
        emit_signal("database_error", "Database not initialized")
        return {}
    
    var stats = database.get_statistics()
    
    # Add cache stats
    stats["cache"] = {
        "enabled": use_caching,
        "entity_cache_size": entity_cache.size(),
        "entity_cache_limit": entity_cache_limit,
        "collection_cache_size": collection_cache.size(),
        "pending_saves": pending_saves.size()
    }
    
    return stats