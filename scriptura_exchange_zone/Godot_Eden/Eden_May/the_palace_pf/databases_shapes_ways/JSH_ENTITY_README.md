# JSH Universal Entity System

This document outlines the JSH Universal Entity System, a framework designed for the Eden project that enables the creation, management, and evolution of entities within a dynamic game world.

## Core Components

### JSHUniversalEntity

The fundamental building block of the system. Each entity has:

- **Unique Identity**: Each entity has a unique ID and classification (type)
- **Properties**: Custom key-value pairs that define the entity's attributes
- **Transformation History**: A record of every type change the entity undergoes
- **References**: Connections to other entities (parent-child, transformations, etc.)
- **Complexity**: A measure of the entity's internal complexity that increases over time
- **Evolution Stages**: Entities can evolve through stages as their complexity increases
- **Self-Splitting Capability**: When an entity becomes too complex, it can split into multiple simpler entities

```gdscript
# Creating a basic entity
var entity = JSHUniversalEntity.new("", "fire", {
    "energy": 10,
    "intensity": 3
})

# Transforming an entity
entity.transform("water")

# Setting properties
entity.set_property("energy", 15)

# Adding tags
entity.add_tag("important")
```

### JSHEntityManager

A singleton manager that handles entity creation, processing, and lifecycle management:

- **Entity Tracking**: Maintains registries of entities by type, tag, and zone
- **Batch Processing**: Efficiently processes entities in batches
- **Interaction Handling**: Manages entity interactions and transformations
- **Zone Management**: Organizes entities into spatial zones
- **Query System**: Find entities based on various criteria

```gdscript
# Get the singleton instance
var entity_manager = JSHEntityManager.get_instance()

# Create an entity
var entity = entity_manager.create_entity("fire", {
    "energy": 10,
    "intensity": 3
})

# Add entity to a zone
entity_manager.add_entity_to_zone(entity.get_id(), "zone1")

# Find all entities of a specific type
var fire_entities = entity_manager.get_entities_by_type("fire")

# Find entities by criteria
var criteria = {
    "type": "fire",
    "min_complexity": 5.0,
    "tag": "important"
}
var found_entities = entity_manager.find_entities(criteria)
```

## Key Concepts

### Entity Complexity and Evolution

Entities have a complexity score that increases based on:

1. **Properties**: More properties = higher complexity
2. **References**: More connections to other entities = higher complexity  
3. **Age**: Older entities have higher complexity
4. **Transformations**: More transformations = higher complexity

As complexity increases, entities advance through evolution stages (0-3). When an entity's complexity exceeds a threshold (default: 100), it can split into multiple simpler entities.

### Entity Interactions

Entities can interact with each other based on their types, producing various effects:

- **Intensify**: Increases properties/complexity
- **Diminish**: Decreases properties/complexity
- **Consume**: One entity consumes another
- **Fuse**: Entities combine to form a new entity
- **Transform**: Entity changes type
- **Split**: Entity divides into multiple entities
- **Create**: Interaction creates a new entity
- **Transmute**: Both entities transform

The InteractionMatrix class defines how different entity types interact.

### Zones

Entities exist within zones, which are spatial containers:

- **Zone Membership**: Entities can belong to multiple zones
- **Zone Limits**: Each zone has a maximum entity capacity
- **Spatial Queries**: Find entities within specific zones

## Self-Evolving Database Integration

The JSH Entity System is designed to support the self-evolving database architecture:

1. **Data Point Splitting**: Entities (data points) that grow too complex automatically split into multiple entities
2. **Hierarchical Structure**: Parent-child relationships track data point evolution
3. **Metadata Storage**: Entity metadata and properties store database fields
4. **Indexing Support**: Entity tags and types provide efficient search capabilities

## Usage Examples

### Creating and Evolving Entities

```gdscript
# Create a primordial entity
var entity = entity_manager.create_entity("primordial")

# Add properties to increase complexity
for i in range(20):
    entity.set_property("property_" + str(i), i)

# Process the entity to update complexity
entity.process(0.0)

# Check evolution stage
print("Entity evolution stage: ", entity.evolution_stage)

# Force a split if complexity is high enough
if entity.complexity > JSHUniversalEntity.COMPLEXITY_THRESHOLD_HIGH:
    var new_entities = entity.attempt_split()
    print("Entity split into ", new_entities.size(), " new entities")
```

### Entity Interactions

```gdscript
# Get interaction effect between two entity types
var effect = interaction_matrix.get_interaction_effect("fire", "water")

# Process interaction between two entities
var entity1 = entity_manager.get_entity(entity1_id)
var entity2 = entity_manager.get_entity(entity2_id)

# The universal bridge would handle this in a real implementation
var result = process_interaction_effect(entity1, entity2, effect)

# Check the result
if result.success:
    print("Interaction effect: ", result.effect)
    if result.transformations.size() > 0:
        print("Entities transformed")
    if result.new_entities.size() > 0:
        print("New entities created")
```

### Finding Entities

```gdscript
# Find entities by type
var fire_entities = entity_manager.get_entities_by_type("fire")

# Find entities by tag
var important_entities = entity_manager.get_entities_by_tag("important")

# Find entities in a zone
var zone_entities = entity_manager.get_entities_in_zone("zone1")

# Find entities by complex criteria
var criteria = {
    "type": "fire",
    "min_complexity": 5.0,
    "evolution_stage": 2,
    "tag": "important",
    "zone": "zone1"
}
var found_entities = entity_manager.find_entities(criteria)
```

## Integration with Existing Systems

The JSH Entity System integrates with the existing Akashic Records system:

- **UniversalBridge**: Bridge between entity system and records system
- **AkashicRecordsManager**: Global record keeper of all entities
- **Dictionary Integration**: Entity types and properties connect to dictionary definitions

## Testing

The system includes a test harness for verifying functionality:

1. **JSHEntityTest**: A test script that creates and manages test entities
2. **JSHEntityTestScene**: A test scene for interactive testing
3. **Statistics Gathering**: Track entity counts, complexity, and other metrics

## Next Steps

1. **Database Integration**: Connect entities to persistent storage
2. **Spatial System**: Enhance zone system with spatial partitioning
3. **UI Components**: Create interfaces for visualizing entities
4. **Performance Optimization**: Implement entity culling and LOD systems
5. **Event System**: Add more sophisticated event handling for entity interactions