# JSH Database System

This document outlines the JSH Database System, a framework for persistent storage and retrieval of entities and related data, integrated with the JSH Universal Entity System for the Eden project.

## Core Components

### JSHDatabaseInterface

An abstract interface defining the standard methods that all database backends should implement:

- **Connection Operations**: initialize, connect_to_database, disconnect_from_database
- **Entity Operations**: store_entity, load_entity, entity_exists, update_entity, delete_entity
- **Query Operations**: find_entities_by_type, find_entities_by_property, find_entities_by_criteria
- **Collection Operations**: create_collection, delete_collection, collection_exists, list_collections
- **Dictionary Operations**: store_dictionary_entry, load_dictionary_entry, get_dictionary
- **Zone Operations**: store_zone, load_zone, zone_exists, delete_zone, get_entities_in_zone
- **Transaction Management**: begin_transaction, commit_transaction, rollback_transaction
- **Database Maintenance**: optimize_database, compact_database, backup_database

### JSHDatabaseManager

A singleton manager that provides a high-level interface to database operations:

- **Initialization and Setup**: initialize, ensure_core_collections, connect_to_entity_manager
- **Entity Storage and Retrieval**: save_entity, load_entity, delete_entity, load_entities_by_type
- **Batch Operations**: save_pending_entities - efficiently saves multiple entities in one transaction
- **Dictionary Management**: save_dictionary_entry, load_dictionary_entry, get_dictionary
- **Zone Management**: save_zone, load_zone, get_entities_in_zone
- **Cache Management**: entity_cache, clean_cache_if_needed, clear_cache
- **Database Maintenance**: compact_database, optimize_database, backup_database

### JSHFileSystemDatabase

A concrete implementation of JSHDatabaseInterface that stores data in the file system:

- **Directory Structure**: Organizes entities by type, stores dictionaries and zones in separate directories
- **Indexing System**: Maintains indexes for fast entity queries by type, tag, zone, and other properties
- **File Handling**: Efficient handling of file operations with transaction support
- **Query System**: Optimized entity search using indexes when available

### JSHFileStorageAdapter

A low-level adapter for file system operations:

- **File Operations**: save_data, load_data, append_data, delete_file, copy_file, move_file
- **Entity Data Handling**: save_entity_data, load_entity_data, entity_data_exists, delete_entity_data
- **Media File Handling**: save_media_file, load_media_file, media_file_exists, delete_media_file
- **Temporary File Management**: create_temp_file, cleanup_temp_files
- **Lock Management**: lock_file, unlock_file, is_file_locked

## Key Concepts

### Self-Evolving Database Architecture

The JSH Database System supports the self-evolving database architecture:

1. **Entity-Based Storage**: Each entity is stored as a separate file, allowing for independent evolution
2. **Type-Based Organization**: Entities are organized by type for efficient retrieval
3. **Index-Based Retrieval**: Indexes keep track of entities by various properties for fast queries
4. **Automatic Entity Splitting**: When entities grow too complex, they are split into multiple entities
5. **Hierarchical Tracking**: Parent-child relationships are maintained as entities evolve
6. **Optimized Storage**: Compression and binary formats available for efficient storage

### Caching and Performance

The database system uses caching to improve performance:

1. **Entity Cache**: Recently used entities are cached in memory for faster access
2. **Collection Cache**: Frequently accessed dictionaries and other collections are cached
3. **Lazy Writing**: Changes are batched and written to disk periodically to reduce I/O
4. **Indexing**: Fast indexes are maintained for common query patterns
5. **Adaptive Optimization**: The database can reorganize itself for better performance

### Transaction Support

The database provides basic transaction support:

1. **Begin Transaction**: Start a series of related operations
2. **Commit Transaction**: Persist all changes made during a transaction
3. **Rollback Transaction**: Discard changes made during a transaction
4. **Atomic Operations**: Ensure that operations like entity splitting are atomic

## Usage Examples

### Initializing the Database

```gdscript
# Create file storage adapter
var file_storage = JSHFileStorageAdapter.new()
file_storage.initialize()

# Create database backend
var database = JSHFileSystemDatabase.new()

# Initialize database manager
var database_manager = JSHDatabaseManager.get_instance()
database_manager.initialize(database, file_storage)

# Connect to entity manager
var entity_manager = JSHEntityManager.get_instance()
```

### Creating and Saving Entities

```gdscript
# Create entity with entity manager
var entity = entity_manager.create_entity("fire", {
    "energy": 10,
    "intensity": 3
})

# Add tags
entity.add_tag("important")
entity.add_tag("player_created")

# Add to zone
entity_manager.add_entity_to_zone(entity.get_id(), "zone1")

# Save entity to database
database_manager.save_entity(entity)

# Database manager will automatically save entities
# when they are updated or created if auto_save_enabled is true
entity.set_property("energy", 15)  # Will be automatically saved
```

### Loading Entities

```gdscript
# Load entity by ID
var entity = database_manager.load_entity("entity_123")

if entity:
    print("Loaded entity: " + entity.get_id() + " of type " + entity.get_type())
    
    # Modify and save
    entity.set_property("modified", true)
    database_manager.save_entity(entity)

# Load multiple entities
var fire_entities = database_manager.load_entities_by_type("fire")
print("Loaded " + str(fire_entities.size()) + " fire entities")

# Complex queries
var criteria = {
    "type": "fire",
    "tag": "important",
    "min_complexity": 5.0,
    "zone": "zone1"
}
var query_results = database_manager.load_entities_by_criteria(criteria)
```

### Working with Dictionaries

```gdscript
# Create a dictionary
var word_definitions = {
    "fire": {
        "description": "Element of transformation and energy",
        "properties": {"energy": 10, "intensity": 3}
    },
    "water": {
        "description": "Element of fluidity and life",
        "properties": {"energy": 8, "intensity": 2}
    }
}

# Save dictionary
database_manager.save_dictionary_entry("entity_types", "elements", word_definitions)

# Load dictionary
var elements = database_manager.load_dictionary_entry("entity_types", "elements")

# Add new entry
elements["earth"] = {
    "description": "Element of stability and grounding",
    "properties": {"energy": 9, "intensity": 1}
}

# Save updated dictionary
database_manager.save_dictionary_entry("entity_types", "elements", elements)
```

### Zone Management

```gdscript
# Create a zone
var zone_data = {
    "id": "forest_zone",
    "name": "Forest Zone",
    "boundaries": {
        "min_x": -1000, "max_x": 1000,
        "min_y": 0, "max_y": 500,
        "min_z": -1000, "max_z": 1000
    },
    "properties": {
        "biome": "forest",
        "ambient_light": 0.7,
        "spawn_types": ["tree", "grass", "animal"]
    }
}

# Save zone
database_manager.save_zone("forest_zone", zone_data)

# Add entities to zone
entity_manager.add_entity_to_zone(entity1.get_id(), "forest_zone")
entity_manager.add_entity_to_zone(entity2.get_id(), "forest_zone")

# Get entities in zone from database
var zone_entities = database_manager.get_entities_in_zone("forest_zone")
```

### Database Maintenance

```gdscript
# Optimize database (rebuild indexes, etc.)
database_manager.optimize_database()

# Compact database (remove unused space, etc.)
database_manager.compact_database()

# Backup database
database_manager.backup_database("user://backups/db_backup_" + Time.get_date_string_from_system())

# Clear memory cache
database_manager.clear_cache()
```

## Integration with Existing Systems

The JSH Database System integrates with the existing JSH Entity System:

- **EntityManager Integration**: Auto-saves entities when they are created or updated
- **Signal Handling**: Responds to entity_created, entity_updated, and entity_destroyed signals
- **Lifecycle Management**: Ensures entity persistence across application sessions
- **Zone Synchronization**: Keeps zone entity membership synchronized with persistent storage

The system also provides a framework for integration with the AkashicRecordsManager:

- **Dictionary Storage**: Stores and loads dictionaries for word definitions
- **Entity Indexing**: Maintains indexes for efficient entity retrieval
- **Hierarchical Management**: Supports parent-child relationships between entities

## Testing

The system includes a test harness for verifying functionality:

1. **JSHDatabaseTest**: A test script that demonstrates database operations
2. **JSHDatabaseTestScene**: A test scene for interactive testing
3. **Statistics Gathering**: Track entity counts, database size, and operation statistics

## Next Steps

1. **Threading Support**: Add support for background saving and loading operations
2. **Enhanced Querying**: Implement more advanced query capabilities
3. **Remote Database**: Add capability to connect to remote database servers
4. **Conflict Resolution**: Add better support for handling conflicts during entity merges
5. **Data Migration**: Add tools for migrating data between database schemas