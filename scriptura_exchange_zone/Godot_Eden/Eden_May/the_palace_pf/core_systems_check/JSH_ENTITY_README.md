# JSH Universal Entity System

## Overview

The Universal Entity System implements the core Eden philosophy: **"Everything is a point that can become anything."** The system provides a foundation for all objects in the Eden universe, from simple primordial particles to complex evolved entities.

## Key Components

### 1. UniversalEntity (class)

The base entity class that represents any point in the system.

- **Location**: `code/gdscript/scripts/akashic_records/universal_entity.gd`
- **Key Features**:
  - Core identity properties (ID, type, history)
  - Transformation capabilities
  - Property dictionary for flexible attributes
  - State management
  - Connection system to other entities
  - Interaction rules

### 2. EntityManager

Manages all Universal Entity instances, providing creation, transformation, and interactions.

- **Location**: `code/gdscript/scripts/core/entity_manager.gd`
- **Key Features**:
  - Entity creation and removal
  - Entity tracking and retrieval
  - Pattern generation (circles, grids, etc.)
  - Spatial queries (nearby entities)
  - Entity interaction processing
  - Persistence (saving/loading)

### 3. Universal Bridge Integration

The UniversalBridge connects the Entity System with other core systems:

- **Location**: `code/gdscript/scripts/core/universal_bridge.gd`
- **Key Features**:
  - Access to entity creation/management
  - Entity interaction processing
  - Signal propagation
  - Console integration

## Key Concepts

### Entity Types

Entities start as "primordial" and can transform into various types:
- **Element**: Basic building blocks (fire, water, earth, air)
- **Particle**: Smaller, more nimble entities
- **Wave**: Energy-focused entities
- **Form**: Structure-oriented entities

### Transformation

Entities gather transformation energy and can evolve into new forms:
1. Energy accumulates through interactions
2. When threshold is reached, transformation becomes possible
3. New forms have increased complexity and modified properties

### Complexity

As entities transform and evolve, they gain complexity:
- Higher complexity = more capabilities
- At threshold levels, entities may split or spawn new entities
- Complexity influences interaction outcomes

### Connections

Entities can form connections with others:
- Connections allow energy/property transfer
- Connected entities can form composite structures
- Connection strength varies based on resonance

## Usage Examples

### Creating Basic Entities

```gdscript
# Via UniversalBridge
var entity_id = universal_bridge.create_universal_entity("primordial", Vector3(0, 0, 0))

# Via EntityManager
var entity_id = entity_manager.create_entity("element", Vector3(1, 2, 3), {"essence": 0.8})
```

### Creating Entity Patterns

```gdscript
# Create a circle of entities
var circle_entities = universal_bridge.create_entity_pattern(
    Vector3(0, 0, 0),  # center
    "circle",          # pattern type
    "element",         # entity type
    8,                 # count
    5.0                # radius
)

# Available patterns: "circle", "grid", "random", "sphere"
```

### Transforming Entities

```gdscript
# Add transformation energy
entity_manager.add_energy_to_entity(entity_id, 50.0)

# Transform when ready
if entity.transformation_energy >= entity.transformation_threshold:
    entity_manager.transform_entity(entity_id, "evolved_form", {
        "complexity": 0.5,
        "resonance": 0.7
    })
```

### Processing Interactions

```gdscript
var result = universal_bridge.process_universal_entity_interaction(entity1_id, entity2_id)

# Check results
if result.success:
    print("Interaction type: " + result.type)
    print("Effects: " + str(result.effects))
```

## Testing

A test scene is provided to verify functionality:

- **Location**: `code/gdscript/scenes/universal_entity_test.tscn`
- **Script**: `code/gdscript/scripts/tests/universal_entity_test.gd`

Run this scene to verify:
- Entity creation
- Transformation
- Interaction
- Pattern generation

## Integration with Other Systems

The Universal Entity system integrates with:

1. **Akashic Records**: For entity type definitions
2. **Console System**: For command-line interaction
3. **Thing Creator**: For visual manifestation
4. **Zone Manager**: For spatial organization

## Future Development

- Advanced pattern generation
- Composite entity structures
- Self-organization capabilities
- Procedural behavior generation
- Entity evolution visualization