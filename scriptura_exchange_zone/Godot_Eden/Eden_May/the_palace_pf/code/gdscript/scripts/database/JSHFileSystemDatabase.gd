extends JSHDatabaseInterface
class_name JSHFileSystemDatabase

# Default directory paths
const DEFAULT_DB_ROOT = "user://database/"
const DEFAULT_BACKUP_DIR = "user://database_backup/"
const DEFAULT_TEMP_DIR = "user://database_temp/"

# Database structure paths
var db_root_path: String = DEFAULT_DB_ROOT
var entity_path: String = db_root_path + "entities/"
var dictionary_path: String = db_root_path + "dictionaries/"
var zone_path: String = db_root_path + "zones/"
var index_path: String = db_root_path + "indexes/"
var metadata_path: String = db_root_path + "metadata/"

# Collection and index tracking
var collections: Dictionary = {}
var indexes: Dictionary = {}

# Initialization state
var _initialized: bool = false

# File formats
enum FileFormat {
    JSON,
    BINARY,
    COMPRESSED
}

var file_format: int = FileFormat.JSON
var use_compression: bool = false
var auto_create_dirs: bool = true

# Statistics
var stats: Dictionary = {
    "entity_count": 0,
    "dictionary_count": 0,
    "zone_count": 0,
    "total_size_bytes": 0,
    "operations": {
        "reads": 0,
        "writes": 0,
        "deletes": 0
    }
}

# Initialization
func _init(root_path: String = "") -> void:
    if not root_path.is_empty():
        db_root_path = root_path
        
        # Update other paths
        entity_path = db_root_path + "entities/"
        dictionary_path = db_root_path + "dictionaries/"
        zone_path = db_root_path + "zones/"
        index_path = db_root_path + "indexes/"
        metadata_path = db_root_path + "metadata/"

func initialize() -> bool:
    print("JSHFileSystemDatabase: Initializing at " + db_root_path)
    
    # Ensure directories exist
    if auto_create_dirs:
        ensure_directories()
    
    # Load collection metadata
    load_collections()
    
    # Load index metadata
    load_indexes()
    
    # Update stats
    update_statistics()
    
    _initialized = true
    print("JSHFileSystemDatabase: Initialized")
    return true

func is_initialized() -> bool:
    return _initialized

func connect_to_database(connection_params: Dictionary = {}) -> bool:
    # For file system database, connection is just initialization
    if not _initialized:
        return initialize()
    return true

func disconnect_from_database() -> bool:
    # Save any pending metadata
    save_collections()
    save_indexes()
    
    # Reset stats
    update_statistics()
    
    return true

# Directory management
func ensure_directories() -> void:
    var dir = DirAccess.open("user://")
    
    # Create main directories
    dir.make_dir_recursive(entity_path)
    dir.make_dir_recursive(dictionary_path)
    dir.make_dir_recursive(zone_path)
    dir.make_dir_recursive(index_path)
    dir.make_dir_recursive(metadata_path)
    
    print("JSHFileSystemDatabase: Directories created")

func get_entity_dir_for_type(entity_type: String) -> String:
    # Create type-specific directory for better organization
    var type_path = entity_path + entity_type + "/"
    
    # Ensure directory exists
    if auto_create_dirs:
        var dir = DirAccess.open("user://")
        dir.make_dir_recursive(type_path)
    
    return type_path

func get_entity_file_path(entity_id: String, entity_type: String = "") -> String:
    var type_dir = ""
    
    if entity_type.is_empty():
        # Use default entity directory
        type_dir = entity_path
    else:
        # Use type-specific directory
        type_dir = get_entity_dir_for_type(entity_type)
    
    return type_dir + entity_id + get_file_extension()

func get_dictionary_file_path(dictionary_name: String) -> String:
    return dictionary_path + dictionary_name + get_file_extension()

func get_zone_file_path(zone_id: String) -> String:
    return zone_path + zone_id + get_file_extension()

func get_index_file_path(collection_name: String, field_name: String) -> String:
    return index_path + collection_name + "_" + field_name + get_file_extension()

func get_file_extension() -> String:
    match file_format:
        FileFormat.JSON:
            return ".json"
        FileFormat.BINARY:
            return ".dat"
        FileFormat.COMPRESSED:
            return ".json.gz"
        _:
            return ".json"

# Entity operations
func store_entity(entity: JSHUniversalEntity) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    var entity_id = entity.get_id()
    var entity_type = entity.get_type()
    
    # Convert entity to dictionary
    var entity_data = entity.to_dict()
    
    # Save to file
    var file_path = get_entity_file_path(entity_id, entity_type)
    var success = save_to_file(file_path, entity_data)
    
    if success:
        # Update indexes
        update_entity_indexes(entity)
        
        # Update stats
        stats.operations.writes += 1
        
        # Update entity count
        if not entity_exists(entity_id):
            stats.entity_count += 1
    
    return success

func load_entity(entity_id: String) -> JSHUniversalEntity:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return null
    
    # Try to find entity
    var entity_type = ""
    var entity_path = ""
    
    # First, check if we know the type (more efficient)
    for type in collections:
        var type_index = get_entity_type_index(type)
        if type_index.has(entity_id):
            entity_type = type
            entity_path = get_entity_file_path(entity_id, entity_type)
            break
    
    # If not found, check in the default entity folder
    if entity_path.is_empty():
        entity_path = get_entity_file_path(entity_id)
    
    # Load data from file
    var entity_data = load_from_file(entity_path)
    
    if entity_data.is_empty():
        return null
    
    # Update stats
    stats.operations.reads += 1
    
    # Create entity from data
    var entity = JSHUniversalEntity.new()
    entity.from_dict(entity_data)
    
    return entity

func entity_exists(entity_id: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    # First, check in type indexes
    for type in collections:
        var type_index = get_entity_type_index(type)
        if type_index.has(entity_id):
            return true
    
    # If not found in indexes, check the file system
    var file_path = get_entity_file_path(entity_id)
    var file = FileAccess.open(file_path, FileAccess.READ)
    
    if file:
        file.close()
        return true
    
    return false

func delete_entity(entity_id: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    # Find the entity file
    var entity_type = ""
    var file_path = ""
    
    # Check in type indexes
    for type in collections:
        var type_index = get_entity_type_index(type)
        if type_index.has(entity_id):
            entity_type = type
            file_path = get_entity_file_path(entity_id, entity_type)
            break
    
    # If not found, try default path
    if file_path.is_empty():
        file_path = get_entity_file_path(entity_id)
    
    # Delete file
    var dir = DirAccess.open("user://")
    if dir.file_exists(file_path):
        var result = dir.remove(file_path)
        
        if result == OK:
            # Remove from indexes
            remove_entity_from_indexes(entity_id, entity_type)
            
            # Update stats
            stats.operations.deletes += 1
            stats.entity_count -= 1
            
            return true
    
    return false

func update_entity(entity: JSHUniversalEntity) -> bool:
    # Same as store_entity for file system database
    return store_entity(entity)

# Query operations
func find_entities_by_type(entity_type: String) -> Array:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return []
    
    var result = []
    
    # Check if we have an index for this type
    var type_index = get_entity_type_index(entity_type)
    
    if not type_index.is_empty():
        # Load entities using the index
        for entity_id in type_index:
            var entity = load_entity(entity_id)
            if entity:
                result.append(entity)
    else:
        # Scan entity directory
        var type_dir = get_entity_dir_for_type(entity_type)
        var dir = DirAccess.open(type_dir)
        
        if dir:
            dir.list_dir_begin()
            var file_name = dir.get_next()
            
            while not file_name.is_empty():
                if not dir.current_is_dir() and file_name.ends_with(get_file_extension()):
                    var entity_id = file_name.get_basename()
                    var entity = load_entity(entity_id)
                    
                    if entity and entity.get_type() == entity_type:
                        result.append(entity)
                
                file_name = dir.get_next()
    
    return result

func find_entities_by_property(property_name: String, property_value) -> Array:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return []
    
    var result = []
    
    # Check if we have an index for this property
    var prop_index = get_property_index(property_name)
    
    if not prop_index.is_empty() and prop_index.has(str(property_value)):
        # Load entities using the index
        var entity_ids = prop_index[str(property_value)]
        for entity_id in entity_ids:
            var entity = load_entity(entity_id)
            if entity:
                result.append(entity)
    else:
        # Need to scan all entities - this is inefficient
        # First, look in all type directories
        for type in collections:
            var type_dir = get_entity_dir_for_type(type)
            var dir = DirAccess.open(type_dir)
            
            if dir:
                dir.list_dir_begin()
                var file_name = dir.get_next()
                
                while not file_name.is_empty():
                    if not dir.current_is_dir() and file_name.ends_with(get_file_extension()):
                        var entity_id = file_name.get_basename()
                        var entity = load_entity(entity_id)
                        
                        if entity and entity.get_property(property_name) == property_value:
                            result.append(entity)
                    
                    file_name = dir.get_next()
    
    return result

func find_entities_by_criteria(criteria: Dictionary) -> Array:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return []
    
    var result = []
    var candidate_ids = []
    
    # Try to use the most selective index first
    if criteria.has("type"):
        # Start with type index
        var type_index = get_entity_type_index(criteria.type)
        candidate_ids = type_index.duplicate()
    elif criteria.has("tag") and indexes.has("entities_tag"):
        # Use tag index
        var tag_index = indexes.entities_tag
        if tag_index.has(criteria.tag):
            candidate_ids = tag_index[criteria.tag].duplicate()
    elif criteria.has("zone") and indexes.has("entities_zone"):
        # Use zone index
        var zone_index = indexes.entities_zone
        if zone_index.has(criteria.zone):
            candidate_ids = zone_index[criteria.zone].duplicate()
    else:
        # Need to scan all entities
        candidate_ids = get_all_entity_ids()
    
    # If we have no candidates, return empty result
    if candidate_ids.is_empty():
        return []
    
    # Filter candidates
    for entity_id in candidate_ids:
        var entity = load_entity(entity_id)
        
        if not entity:
            continue
        
        var matches = true
        
        # Check each criterion
        for key in criteria:
            match key:
                "type":
                    if entity.get_type() != criteria.type:
                        matches = false
                        break
                "tag":
                    if not criteria.tag in entity.get_tags():
                        matches = false
                        break
                "zone":
                    if not criteria.zone in entity.get_zones():
                        matches = false
                        break
                "min_complexity":
                    if entity.complexity < criteria.min_complexity:
                        matches = false
                        break
                "max_complexity":
                    if entity.complexity > criteria.max_complexity:
                        matches = false
                        break
                "evolution_stage":
                    if entity.evolution_stage != criteria.evolution_stage:
                        matches = false
                        break
                "min_evolution_stage":
                    if entity.evolution_stage < criteria.min_evolution_stage:
                        matches = false
                        break
                "property":
                    if not criteria.has("property_value"):
                        continue
                    if entity.get_property(criteria.property) != criteria.property_value:
                        matches = false
                        break
                "property_exists":
                    if not entity.properties.has(criteria.property_exists):
                        matches = false
                        break
        
        if matches:
            result.append(entity)
    
    return result

func get_all_entity_ids() -> Array:
    var result = []
    
    # Check all type indexes first
    for type in collections:
        var type_index = get_entity_type_index(type)
        for entity_id in type_index:
            if not entity_id in result:
                result.append(entity_id)
    
    # Also check the main entity directory
    var dir = DirAccess.open(entity_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while not file_name.is_empty():
            if not dir.current_is_dir() and file_name.ends_with(get_file_extension()):
                var entity_id = file_name.get_basename()
                if not entity_id in result:
                    result.append(entity_id)
            
            file_name = dir.get_next()
    
    return result

# Collection operations
func create_collection(collection_name: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    # For file system database, collections are just directories
    var collection_path = db_root_path + collection_name + "/"
    
    # Create directory
    var dir = DirAccess.open("user://")
    dir.make_dir_recursive(collection_path)
    
    # Add to collections
    if not collections.has(collection_name):
        collections[collection_name] = {
            "name": collection_name,
            "path": collection_path,
            "created": Time.get_datetime_string_from_system()
        }
    
    # Save collections metadata
    save_collections()
    
    return true

func delete_collection(collection_name: String) -> bool:
    if not _initialized or not collections.has(collection_name):
        return false
    
    # Get collection path
    var collection_path = collections[collection_name].path
    
    # Delete all files in collection
    var dir = DirAccess.open(collection_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while not file_name.is_empty():
            if not dir.current_is_dir():
                dir.remove(file_name)
            
            file_name = dir.get_next()
        
        # Remove directory
        dir = DirAccess.open("user://")
        dir.remove(collection_path)
    
    # Remove from collections
    collections.erase(collection_name)
    
    # Save collections metadata
    save_collections()
    
    return true

func collection_exists(collection_name: String) -> bool:
    if not _initialized:
        return false
    
    return collections.has(collection_name)

func list_collections() -> Array:
    if not _initialized:
        return []
    
    return collections.keys()

func load_collections() -> void:
    var file_path = metadata_path + "collections" + get_file_extension()
    var data = load_from_file(file_path)
    
    if not data.is_empty():
        collections = data
    else:
        # Initialize with default collections
        collections = {
            "entities": {
                "name": "entities",
                "path": entity_path,
                "created": Time.get_datetime_string_from_system()
            },
            "dictionaries": {
                "name": "dictionaries",
                "path": dictionary_path,
                "created": Time.get_datetime_string_from_system()
            },
            "zones": {
                "name": "zones",
                "path": zone_path,
                "created": Time.get_datetime_string_from_system()
            }
        }

func save_collections() -> void:
    var file_path = metadata_path + "collections" + get_file_extension()
    save_to_file(file_path, collections)

# Index operations
func create_index(collection_name: String, field_name: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    var index_name = collection_name + "_" + field_name
    
    # Check if index already exists
    if indexes.has(index_name):
        return true
    
    # Create empty index
    indexes[index_name] = {}
    
    # If this is an entity collection, populate the index
    if collection_name == "entities":
        build_entity_index(field_name)
    
    # Save index metadata
    save_indexes()
    
    print("JSHFileSystemDatabase: Created index " + index_name)
    return true

func delete_index(collection_name: String, field_name: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    var index_name = collection_name + "_" + field_name
    
    # Remove index
    if indexes.has(index_name):
        indexes.erase(index_name)
        
        # Delete index file
        var file_path = get_index_file_path(collection_name, field_name)
        var dir = DirAccess.open("user://")
        if dir.file_exists(file_path):
            dir.remove(file_path)
        
        # Save index metadata
        save_indexes()
        
        print("JSHFileSystemDatabase: Deleted index " + index_name)
        return true
    
    return false

func index_exists(collection_name: String, field_name: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    var index_name = collection_name + "_" + field_name
    return indexes.has(index_name)

func load_indexes() -> void:
    var file_path = metadata_path + "indexes" + get_file_extension()
    var index_metadata = load_from_file(file_path)
    
    if not index_metadata.is_empty():
        # Load metadata about indexes
        var index_names = index_metadata.keys()
        
        for index_name in index_names:
            # Load actual index data
            var index_file_path = index_path + index_name + get_file_extension()
            var index_data = load_from_file(index_file_path)
            
            if not index_data.is_empty():
                indexes[index_name] = index_data
            else:
                # Create empty index
                indexes[index_name] = {}
    else:
        # Initialize with standard indexes
        indexes = {
            "entities_entity_type": {},
            "entities_zones": {},
            "entities_tags": {},
            "entities_evolution_stage": {}
        }
        
        # Build initial indexes
        build_entity_index("entity_type")
        build_entity_index("zones")
        build_entity_index("tags")
        build_entity_index("evolution_stage")
    
    print("JSHFileSystemDatabase: Loaded " + str(indexes.size()) + " indexes")

func save_indexes() -> void:
    # Save index metadata
    var index_metadata = {}
    
    for index_name in indexes:
        var parts = index_name.split("_", true, 1)
        
        if parts.size() >= 2:
            var collection = parts[0]
            var field = parts[1]
            
            index_metadata[index_name] = {
                "collection": collection,
                "field": field,
                "updated": Time.get_datetime_string_from_system()
            }
    
    var metadata_file_path = metadata_path + "indexes" + get_file_extension()
    save_to_file(metadata_file_path, index_metadata)
    
    # Save actual index data
    for index_name in indexes:
        var file_path = index_path + index_name + get_file_extension()
        save_to_file(file_path, indexes[index_name])
    
    print("JSHFileSystemDatabase: Saved " + str(indexes.size()) + " indexes")

func build_entity_index(field_name: String) -> void:
    var index_name = "entities_" + field_name
    var index_data = {}
    
    # Scan all entity files
    var all_entity_ids = get_all_entity_ids()
    
    for entity_id in all_entity_ids:
        var entity = load_entity(entity_id)
        
        if entity:
            update_entity_index(entity, field_name, index_data)
    
    # Save to index
    indexes[index_name] = index_data
    
    print("JSHFileSystemDatabase: Built index " + index_name + " with " + str(all_entity_ids.size()) + " entities")

func update_entity_indexes(entity: JSHUniversalEntity) -> void:
    var entity_id = entity.get_id()
    
    # Update type index
    var type_index_name = "entities_entity_type"
    if indexes.has(type_index_name):
        var entity_type = entity.get_type()
        var type_index = indexes[type_index_name]
        
        # Add to type index
        if not type_index.has(entity_type):
            type_index[entity_type] = []
        
        if not entity_id in type_index[entity_type]:
            type_index[entity_type].append(entity_id)
    
    # Update zones index
    var zones_index_name = "entities_zones"
    if indexes.has(zones_index_name):
        var zones = entity.get_zones()
        var zones_index = indexes[zones_index_name]
        
        # Add to zones index
        for zone in zones:
            if not zones_index.has(zone):
                zones_index[zone] = []
            
            if not entity_id in zones_index[zone]:
                zones_index[zone].append(entity_id)
    
    # Update tags index
    var tags_index_name = "entities_tags"
    if indexes.has(tags_index_name):
        var tags = entity.get_tags()
        var tags_index = indexes[tags_index_name]
        
        # Add to tags index
        for tag in tags:
            if not tags_index.has(tag):
                tags_index[tag] = []
            
            if not entity_id in tags_index[tag]:
                tags_index[tag].append(entity_id)
    
    # Update evolution stage index
    var stage_index_name = "entities_evolution_stage"
    if indexes.has(stage_index_name):
        var stage = str(entity.evolution_stage)
        var stage_index = indexes[stage_index_name]
        
        # Add to stage index
        if not stage_index.has(stage):
            stage_index[stage] = []
        
        if not entity_id in stage_index[stage]:
            stage_index[stage].append(entity_id)
    
    # Update other indexed fields
    for index_name in indexes:
        if index_name.begins_with("entities_") and not index_name in [
            type_index_name, zones_index_name, tags_index_name, stage_index_name
        ]:
            var field = index_name.split("_", true, 1)[1]
            update_entity_index(entity, field, indexes[index_name])
    
    # Save indexes
    save_indexes()

func update_entity_index(entity: JSHUniversalEntity, field_name: String, index_data: Dictionary) -> void:
    var entity_id = entity.get_id()
    
    # Get field value
    var field_value = null
    
    match field_name:
        "entity_type":
            field_value = entity.get_type()
        "zones":
            var zones = entity.get_zones()
            for zone in zones:
                if not index_data.has(zone):
                    index_data[zone] = []
                
                if not entity_id in index_data[zone]:
                    index_data[zone].append(entity_id)
            
            return  # Special case, already handled
        "tags":
            var tags = entity.get_tags()
            for tag in tags:
                if not index_data.has(tag):
                    index_data[tag] = []
                
                if not entity_id in index_data[tag]:
                    index_data[tag].append(entity_id)
            
            return  # Special case, already handled
        "evolution_stage":
            field_value = str(entity.evolution_stage)
        _:
            # Check if it's a property
            field_value = entity.get_property(field_name)
            if field_value == null:
                # Check if it's a metadata field
                field_value = entity.get_metadata(field_name)
                if field_value == null:
                    return  # Field not found
    
    # Convert to string for index key
    var key = str(field_value)
    
    # Add to index
    if not index_data.has(key):
        index_data[key] = []
    
    if not entity_id in index_data[key]:
        index_data[key].append(entity_id)

func remove_entity_from_indexes(entity_id: String, entity_type: String = "") -> void:
    # Remove from all indexes
    for index_name in indexes:
        var index_data = indexes[index_name]
        
        if index_name == "entities_entity_type" and not entity_type.is_empty():
            # Remove from type index
            if index_data.has(entity_type):
                var type_list = index_data[entity_type]
                var idx = type_list.find(entity_id)
                if idx >= 0:
                    type_list.remove_at(idx)
        else:
            # For other indexes, need to scan all keys
            for key in index_data:
                var value_list = index_data[key]
                var idx = value_list.find(entity_id)
                if idx >= 0:
                    value_list.remove_at(idx)
    
    # Save indexes
    save_indexes()

func get_entity_type_index(entity_type: String) -> Array:
    var index_name = "entities_entity_type"
    
    if indexes.has(index_name) and indexes[index_name].has(entity_type):
        return indexes[index_name][entity_type]
    
    return []

func get_property_index(property_name: String) -> Dictionary:
    var index_name = "entities_" + property_name
    
    if indexes.has(index_name):
        return indexes[index_name]
    
    return {}

# Dictionary operations
func store_dictionary_entry(dictionary_name: String, entry_key: String, entry_data: Dictionary) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    # Get dictionary
    var dictionary = load_dictionary(dictionary_name)
    
    # Add or update entry
    dictionary[entry_key] = entry_data
    
    # Save updated dictionary
    var file_path = get_dictionary_file_path(dictionary_name)
    var success = save_to_file(file_path, dictionary)
    
    if success:
        stats.operations.writes += 1
    
    return success

func load_dictionary_entry(dictionary_name: String, entry_key: String) -> Dictionary:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return {}
    
    # Get dictionary
    var dictionary = load_dictionary(dictionary_name)
    
    # Check if entry exists
    if dictionary.has(entry_key):
        stats.operations.reads += 1
        return dictionary[entry_key]
    
    return {}

func dictionary_entry_exists(dictionary_name: String, entry_key: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    # Get dictionary
    var dictionary = load_dictionary(dictionary_name)
    
    return dictionary.has(entry_key)

func delete_dictionary_entry(dictionary_name: String, entry_key: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    # Get dictionary
    var dictionary = load_dictionary(dictionary_name)
    
    # Check if entry exists
    if dictionary.has(entry_key):
        # Remove entry
        dictionary.erase(entry_key)
        
        # Save updated dictionary
        var file_path = get_dictionary_file_path(dictionary_name)
        var success = save_to_file(file_path, dictionary)
        
        if success:
            stats.operations.deletes += 1
        
        return success
    
    return false

func get_dictionary(dictionary_name: String) -> Dictionary:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return {}
    
    return load_dictionary(dictionary_name)

func load_dictionary(dictionary_name: String) -> Dictionary:
    var file_path = get_dictionary_file_path(dictionary_name)
    var data = load_from_file(file_path)
    
    stats.operations.reads += 1
    
    if data.is_empty():
        return {}
    
    return data

# Zone operations
func store_zone(zone_id: String, zone_data: Dictionary) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    # Save to file
    var file_path = get_zone_file_path(zone_id)
    var success = save_to_file(file_path, zone_data)
    
    if success:
        # Update zone count
        if not zone_exists(zone_id):
            stats.zone_count += 1
        
        stats.operations.writes += 1
    
    return success

func load_zone(zone_id: String) -> Dictionary:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return {}
    
    var file_path = get_zone_file_path(zone_id)
    var data = load_from_file(file_path)
    
    stats.operations.reads += 1
    
    return data

func zone_exists(zone_id: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    var file_path = get_zone_file_path(zone_id)
    var file = FileAccess.open(file_path, FileAccess.READ)
    
    if file:
        file.close()
        return true
    
    return false

func delete_zone(zone_id: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    var file_path = get_zone_file_path(zone_id)
    var dir = DirAccess.open("user://")
    
    if dir.file_exists(file_path):
        var result = dir.remove(file_path)
        
        if result == OK:
            stats.operations.deletes += 1
            stats.zone_count -= 1
            
            return true
    
    return false

func get_entities_in_zone(zone_id: String) -> Array:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return []
    
    var result = []
    
    # Check if we have an index for zones
    var index_name = "entities_zones"
    
    if indexes.has(index_name) and indexes[index_name].has(zone_id):
        var entity_ids = indexes[index_name][zone_id]
        
        for entity_id in entity_ids:
            var entity = load_entity(entity_id)
            if entity:
                result.append(entity)
    else:
        # Need to scan all entities - inefficient
        var all_entity_ids = get_all_entity_ids()
        
        for entity_id in all_entity_ids:
            var entity = load_entity(entity_id)
            
            if entity and zone_id in entity.get_zones():
                result.append(entity)
    
    return result

# Transaction management
func begin_transaction() -> bool:
    # For a simple file system database, transactions aren't fully supported
    # We could implement a basic journal system for atomicity
    print("JSHFileSystemDatabase: Begin transaction")
    return true

func commit_transaction() -> bool:
    print("JSHFileSystemDatabase: Commit transaction")
    return true

func rollback_transaction() -> bool:
    print("JSHFileSystemDatabase: Rollback transaction")
    return false

# File operations
func save_to_file(file_path: String, data) -> bool:
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    
    if file:
        match file_format:
            FileFormat.JSON:
                file.store_string(JSON.stringify(data, "  "))
            FileFormat.BINARY:
                file.store_var(data)
            FileFormat.COMPRESSED:
                var json_string = JSON.stringify(data)
                file.store_buffer(json_string.to_utf8_buffer().compress(FileAccess.COMPRESSION_GZIP))
        
        file.close()
        return true
    
    push_error("JSHFileSystemDatabase: Failed to save file - " + file_path)
    return false

func load_from_file(file_path: String):
    var file = FileAccess.open(file_path, FileAccess.READ)
    
    if file:
        var data = null
        
        match file_format:
            FileFormat.JSON:
                var json_string = file.get_as_text()
                var json_result = JSON.parse_string(json_string)
                if json_result != null:
                    data = json_result
            FileFormat.BINARY:
                data = file.get_var()
            FileFormat.COMPRESSED:
                var compressed_data = file.get_buffer(file.get_length())
                var json_string = compressed_data.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP).get_string_from_utf8()
                var json_result = JSON.parse_string(json_string)
                if json_result != null:
                    data = json_result
        
        file.close()
        return data
    
    return null

# Statistics and maintenance
func update_statistics() -> void:
    # Count entities
    stats.entity_count = 0
    var dir = DirAccess.open(entity_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while not file_name.is_empty():
            if not dir.current_is_dir() and file_name.ends_with(get_file_extension()):
                stats.entity_count += 1
            
            file_name = dir.get_next()
        
        # Also check type directories
        for type in collections:
            var type_dir = get_entity_dir_for_type(type)
            dir = DirAccess.open(type_dir)
            
            if dir:
                dir.list_dir_begin()
                file_name = dir.get_next()
                
                while not file_name.is_empty():
                    if not dir.current_is_dir() and file_name.ends_with(get_file_extension()):
                        stats.entity_count += 1
                    
                    file_name = dir.get_next()
    
    # Count dictionaries
    stats.dictionary_count = 0
    dir = DirAccess.open(dictionary_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while not file_name.is_empty():
            if not dir.current_is_dir() and file_name.ends_with(get_file_extension()):
                stats.dictionary_count += 1
            
            file_name = dir.get_next()
    
    # Count zones
    stats.zone_count = 0
    dir = DirAccess.open(zone_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while not file_name.is_empty():
            if not dir.current_is_dir() and file_name.ends_with(get_file_extension()):
                stats.zone_count += 1
            
            file_name = dir.get_next()
    
    # Calculate total size
    stats.total_size_bytes = calculate_directory_size(db_root_path)
    
    print("JSHFileSystemDatabase: Updated statistics")

func calculate_directory_size(dir_path: String) -> int:
    var total_size = 0
    var dir = DirAccess.open(dir_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while not file_name.is_empty():
            if dir.current_is_dir():
                if file_name != "." and file_name != "..":
                    total_size += calculate_directory_size(dir_path + file_name + "/")
            else:
                # Get file size
                var file = FileAccess.open(dir_path + file_name, FileAccess.READ)
                if file:
                    total_size += file.get_length()
                    file.close()
            
            file_name = dir.get_next()
    
    return total_size

func get_statistics() -> Dictionary:
    return stats

func optimize_database() -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    # Rebuild all indexes
    for index_name in indexes:
        var parts = index_name.split("_", true, 1)
        
        if parts.size() >= 2 and parts[0] == "entities":
            var field = parts[1]
            indexes[index_name] = {}
            build_entity_index(field)
    
    # Update statistics
    update_statistics()
    
    print("JSHFileSystemDatabase: Database optimized")
    return true

func compact_database() -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    # For file system database, compaction isn't as relevant
    # But we can cleanup empty directories and regenerate indexes
    
    # Cleanup empty directories
    cleanup_empty_directories()
    
    # Rebuild indexes
    for index_name in indexes:
        var parts = index_name.split("_", true, 1)
        
        if parts.size() >= 2 and parts[0] == "entities":
            var field = parts[1]
            indexes[index_name] = {}
            build_entity_index(field)
    
    print("JSHFileSystemDatabase: Database compacted")
    return true

func cleanup_empty_directories() -> void:
    # Entity type directories
    for type in collections:
        var type_dir = get_entity_dir_for_type(type)
        var dir = DirAccess.open(type_dir)
        
        if dir:
            dir.list_dir_begin()
            var has_files = false
            var file_name = dir.get_next()
            
            while not file_name.is_empty():
                if not dir.current_is_dir():
                    has_files = true
                    break
                
                file_name = dir.get_next()
            
            if not has_files:
                dir = DirAccess.open("user://")
                dir.remove(type_dir)
                print("JSHFileSystemDatabase: Removed empty directory " + type_dir)
    
    print("JSHFileSystemDatabase: Cleaned up empty directories")

func backup_database(backup_path: String) -> bool:
    if not _initialized:
        push_error("JSHFileSystemDatabase: Not initialized")
        return false
    
    # Ensure backup directory exists
    var dir = DirAccess.open("user://")
    dir.make_dir_recursive(backup_path)
    
    # Copy all files
    var result = copy_directory(db_root_path, backup_path)
    
    if result:
        print("JSHFileSystemDatabase: Database backed up to " + backup_path)
    else:
        push_error("JSHFileSystemDatabase: Backup failed")
    
    return result

func copy_directory(from_dir: String, to_dir: String) -> bool:
    var dir = DirAccess.open(from_dir)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while not file_name.is_empty():
            if dir.current_is_dir():
                if file_name != "." and file_name != "..":
                    # Create subdirectory in target
                    var dir_to = DirAccess.open("user://")
                    dir_to.make_dir_recursive(to_dir + file_name + "/")
                    
                    # Copy subdirectory
                    copy_directory(from_dir + file_name + "/", to_dir + file_name + "/")
            else:
                # Copy file
                var file_from = FileAccess.open(from_dir + file_name, FileAccess.READ)
                var file_to = FileAccess.open(to_dir + file_name, FileAccess.WRITE)
                
                if file_from and file_to:
                    var content = file_from.get_buffer(file_from.get_length())
                    file_to.store_buffer(content)
                    
                    file_from.close()
                    file_to.close()
                else:
                    push_error("JSHFileSystemDatabase: Failed to copy file " + file_name)
                    return false
            
            file_name = dir.get_next()
        
        return true
    
    return false