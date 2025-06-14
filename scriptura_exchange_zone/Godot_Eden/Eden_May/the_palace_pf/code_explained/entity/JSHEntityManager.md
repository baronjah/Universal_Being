# Script Documentation: JSHEntityManager

## Overview
JSHEntityManager is a central component that manages the creation, tracking, and processing of all entities in the JSH Ethereal Engine. It implements the singleton pattern for global access and provides comprehensive functionality for entity lifecycle management, including creation, registration, processing, transformation, and zone-based organization.

## File Information
- **File Path:** `/code/entity/JSHEntityManager.gd`
- **Lines of Code:** 535
- **Class Name:** JSHEntityManager
- **Extends:** Node

## Dependencies
- JSHUniversalEntity - Used for entity creation and management

## Core Properties

### Tracking Collections
| Property | Type | Description |
|----------|------|-------------|
| entities | Dictionary | Main collection of all entities indexed by entity_id |
| entities_by_type | Dictionary | Groups entities by their type |
| entities_by_tag | Dictionary | Groups entities by their tags |
| entities_by_zone | Dictionary | Groups entities by the zones they occupy |

### Processing Configuration
| Property | Type | Description |
|----------|------|-------------|
| auto_process | bool | Whether to automatically process entities in _process |
| process_batch_size | int | Maximum number of entities to process per batch |
| process_interval_ms | int | Minimum time between processing batches |
| last_process_time | int | Timestamp of last processing run |
| process_queue | Array | Queue of entity IDs waiting to be processed |

### Thresholds and Limits
| Property | Type | Description |
|----------|------|-------------|
| max_entities | int | Maximum number of entities allowed in the system |
| max_entities_per_zone | int | Maximum number of entities allowed in a single zone |
| complexity_limit | float | Upper complexity limit for entities |

## Signals
| Signal | Parameters | Description |
|--------|------------|-------------|
| entity_created | entity | Emitted when a new entity is created |
| entity_destroyed | entity_id | Emitted when an entity is destroyed |
| entity_split | original_entity, new_entities | Emitted when an entity splits into multiple entities |
| entity_merged | source_entities, new_entity | Emitted when multiple entities are merged |
| entity_updated | entity | Emitted when an entity's properties change |
| entity_moved | entity, old_zone, new_zone | Emitted when an entity changes zones |
| processing_completed | processed_count | Emitted after a batch of entities is processed |
| entity_limit_reached | current_count | Emitted when the entity limit is reached |

## Core Methods

### Singleton Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| get_instance | | JSHEntityManager | Returns the singleton instance, creating it if needed |
| _init | | void | Initializes the singleton instance |

### Entity Creation and Registration
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| create_entity | type, properties | JSHUniversalEntity | Creates a new entity of the specified type |
| register_entity | entity | bool | Registers an existing entity with the manager |
| unregister_entity | entity_id | bool | Removes an entity from the manager |

### Entity Processing
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _process | delta | void | Automatically processes entity batches |
| add_to_process_queue | entity_id | void | Adds an entity to the processing queue |
| process_entity_batch | | int | Processes a batch of entities and returns the count |
| handle_entity_split | entity | void | Handles the splitting of a complex entity |
| merge_entities | entity_ids | JSHUniversalEntity | Merges multiple entities into one |

### Zone Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| add_entity_to_zone | entity_id, zone_id | bool | Adds an entity to a specific zone |
| remove_entity_from_zone | entity_id, zone_id | bool | Removes an entity from a zone |

### Entity Retrieval
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| get_entity | entity_id | JSHUniversalEntity | Gets an entity by its ID |
| get_entities_by_type | type | Array | Gets all entities of a specific type |
| get_entities_by_tag | tag | Array | Gets all entities with a specific tag |
| get_entities_in_zone | zone_id | Array | Gets all entities in a specific zone |
| find_entities | criteria | Array | Searches for entities based on criteria |

### Signal Handlers
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _on_entity_transformed | old_type, new_type, entity | void | Handles entity type transformations |
| _on_entity_property_changed | property_name, old_value, new_value, entity | void | Handles property changes |
| _on_entity_complexity_changed | old_value, new_value, entity | void | Handles complexity changes |
| _on_entity_evolution_stage_changed | old_stage, new_stage, entity | void | Handles evolution stage changes |
| _on_entity_split | original_entity, new_entities, entity | void | Handles entity splitting |

### Statistics
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| get_statistics | | Dictionary | Returns detailed statistics about all entities |

## Entity Lifecycle Management

### Creation and Registration
The manager creates entities through the `create_entity` method, which initializes a new JSHUniversalEntity with the specified type and properties. After creation, the entity is registered with the manager through the `register_entity` method, which:

1. Adds the entity to the main entities dictionary
2. Indexes the entity by type, tags, and zones
3. Connects to entity signals to monitor changes
4. Adds the entity to the processing queue

### Entity Processing
The manager processes entities in batches to prevent performance issues. The `process_entity_batch` method:

1. Takes entities from the processing queue
2. Calls their `process` method to update state
3. Checks if entities need to split due to high complexity
4. Returns entities to the queue for future processing

### Entity Transformation and Evolution
The manager reacts to entity changes through signal handlers:

- `_on_entity_transformed`: Updates type indexing when entities change type
- `_on_entity_complexity_changed`: Prioritizes processing of high-complexity entities
- `_on_entity_evolution_stage_changed`: Prioritizes higher evolution stages

### Entity Splitting and Merging
The manager supports advanced entity operations:

- `handle_entity_split`: When an entity becomes too complex, it splits into multiple simpler entities
- `merge_entities`: Multiple entities can be combined into a single, more complex entity

### Zone Management
The manager organizes entities into zones for spatial organization:

- `add_entity_to_zone`: Associates an entity with a zone
- `remove_entity_from_zone`: Removes an entity from a zone
- `get_entities_in_zone`: Retrieves all entities in a specific zone

## Entity Query System

The manager provides a flexible entity query system through the `find_entities` method, which accepts a criteria dictionary with various filtering options:

```gdscript
# Find all fire entities with complexity over 50
var criteria = {
    "type": "fire",
    "min_complexity": 50
}
var fire_entities = entity_manager.find_entities(criteria)

# Find all entities in the "forest" zone with the "living" tag
var living_forest = entity_manager.find_entities({
    "zone": "forest",
    "tag": "living"
})

# Find entities with a specific property
var waterproof = entity_manager.find_entities({
    "property": "waterproof",
    "property_value": true
})
```

## Usage Examples

### Basic Entity Management
```gdscript
# Get the entity manager instance
var entity_manager = JSHEntityManager.get_instance()

# Create a new entity
var properties = { "energy": 100, "fluidity": 0.8 }
var water_entity = entity_manager.create_entity("water", properties)

# Add entity to a zone
entity_manager.add_entity_to_zone(water_entity.get_id(), "pond")

# Retrieve entities
var all_water = entity_manager.get_entities_by_type("water")
var pond_entities = entity_manager.get_entities_in_zone("pond")
```

### Entity Transformations
```gdscript
# Create an entity
var entity = entity_manager.create_entity("water")

# When the entity transforms, the manager automatically updates its tracking
entity.transform("ice")

# The entity can now be found with its new type
var ice_entities = entity_manager.get_entities_by_type("ice")
```

### Advanced Entity Operations
```gdscript
# Get some entities to merge
var entity_ids = [entity1.get_id(), entity2.get_id(), entity3.get_id()]

# Merge them into a new, more complex entity
var merged = entity_manager.merge_entities(entity_ids)

# Find all high-complexity entities that might split soon
var complex_entities = entity_manager.find_entities({
    "min_complexity": JSHUniversalEntity.COMPLEXITY_THRESHOLD_HIGH * 0.9
})
```

## Integration Points

The JSHEntityManager integrates with several other components:

- **JSHUniversalEntity**: Creates and manages entities
- **JSHWordManifestor**: Provides entities created from words
- **JSHSpatialManager**: Organizes entities in spatial zones
- **JSHEntityVisualizer**: Visualizes entities in the world
- **JSHEntityEvolution**: Manages entity evolution stages

## Notes and Considerations

1. **Performance**: The batch processing system is designed to handle large numbers of entities without causing performance issues.

2. **Entity Limits**: The manager enforces entity limits to prevent resource exhaustion:
   - `max_entities`: Total entities in the system (default: 10,000)
   - `max_entities_per_zone`: Entities per zone (default: 1,000)

3. **Signal Connections**: The manager connects to various entity signals to monitor their state changes.

4. **Thread Safety**: The entity manager is not designed to be thread-safe and should only be accessed from the main thread.

## Related Documentation

- [JSHUniversalEntity](JSHUniversalEntity.md) - The base entity class
- [JSHEntityEvolution](JSHEntityEvolution.md) - Entity evolution system
- [JSHEntityVisualizer](JSHEntityVisualizer.md) - Entity visualization
- [JSHSpatialManager](../spatial/JSHSpatialManager.md) - Spatial management system