# Script Documentation: CoreThingCreator

## Overview
CoreThingCreator is a central manager class for creating, transforming, and managing Universal Entities in the JSH Ethereal Engine. It serves as the primary integration point between the word manifestation system, universal entities, and the Akashic Records database.

## File Information
- **File Path:** `/code/gdscript/scripts/core/CoreThingCreator.gd`
- **Class Name:** CoreThingCreator
- **Extends:** Node

## Dependencies
- CoreUniversalEntity
- CoreWordManifestor
- AkashicRecordsManager

## Properties

### Core References
| Property | Type | Description |
|----------|------|-------------|
| universal_entity_class | GDScript | Reference to the CoreUniversalEntity class |
| word_manifestor | Node | Reference to the word manifestation system |
| akashic_records_manager | Node | Reference to the Akashic Records manager |

### State Tracking
| Property | Type | Description |
|----------|------|-------------|
| active_entities | Dictionary | Maps entity_id to entity instances |
| entity_patterns | Dictionary | Maps pattern_id to arrays of entity_ids |

## Signals
| Signal | Parameters | Description |
|--------|------------|-------------|
| entity_created | entity_id, word, position | Emitted when a new entity is created |
| entity_transformed | entity_id, old_form, new_form | Emitted when an entity changes form |
| entity_evolved | entity_id, old_stage, new_stage | Emitted when an entity evolves |
| entity_connected | entity_id, target_id, connection_type | Emitted when entities are connected |
| pattern_created | pattern_id, entities | Emitted when a pattern of entities is created |

## Core Methods

### Initialization
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _init | | void | Constructor that sets the node name |
| _ready | | void | Initializes required components |
| _load_required_classes | | void | Loads CoreUniversalEntity and CoreWordManifestor |
| _initialize_akashic_records | | void | Initializes AkashicRecordsManager |

### Entity Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| create_entity | word, position, evolution_stage | String | Creates an entity from a word at a position |
| remove_entity | entity_id | bool | Removes an entity from the world |
| get_all_entities | | Array | Returns all active entity IDs |
| get_entity | entity_id | Node | Returns the entity instance |

### Entity Manipulation
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| connect_entities | entity1_id, entity2_id, connection_type | bool | Connects two entities |
| transform_entity | entity_id, new_form, transformation_time | bool | Transforms entity to a new form |
| evolve_entity | entity_id, evolution_factor | bool | Evolves entity to next stage |
| process_entity_interaction | entity1_id, entity2_id | Dictionary | Processes interaction between entities |

### Pattern Generation
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| create_pattern | word, pattern_type, position, count, radius | String | Creates a pattern of entities |

## Pattern Types
- **circle**: Arranges entities in a circle
- **grid**: Arranges entities in a grid layout
- **random**: Arranges entities in random positions
- **sphere**: Arranges entities in a spherical pattern

## Signal Handlers
| Method | Description |
|--------|-------------|
| _on_entity_transformed | Relays entity transform signals |
| _on_entity_evolved | Relays entity evolution signals |

## Usage Examples

### Creating an Entity
```gdscript
var thing_creator = CoreThingCreator.get_instance()
var entity_id = thing_creator.create_entity("fire", Vector3(0, 0, 0))
print("Created entity: " + entity_id)
```

### Creating a Pattern
```gdscript
var thing_creator = CoreThingCreator.get_instance()
var pattern_id = thing_creator.create_pattern("water", "circle", Vector3(0, 0, 0), 8, 5.0)
print("Created pattern: " + pattern_id)
```

### Evolving an Entity
```gdscript
var thing_creator = CoreThingCreator.get_instance()
var success = thing_creator.evolve_entity("fire_123456")
```

## Integration with Other Systems

### Universal Entity System
CoreThingCreator directly creates and manages CoreUniversalEntity instances, serving as a factory and manager for all entities in the world.

### Word Manifestation
The CoreThingCreator uses the word manifestation system to convert words into entity properties and characteristics.

### Akashic Records
Entities created by CoreThingCreator are registered with the Akashic Records for persistence and relationship tracking.

### User Interface
The CoreThingCreator provides a common API for UI systems to create and manipulate entities without directly accessing the CoreUniversalEntity instances.

## Notes and Best Practices
- Always use CoreThingCreator to create, transform and evolve entities rather than manipulating them directly
- Use the singleton pattern to access the instance: `CoreThingCreator.get_instance()`
- When creating patterns, consider the visual impact of too many entities in close proximity
- Always check the return values of methods to ensure operations were successful