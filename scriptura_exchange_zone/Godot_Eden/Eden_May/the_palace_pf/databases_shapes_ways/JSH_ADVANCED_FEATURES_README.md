# JSH Advanced Features - Phase 5

This document describes the advanced features implemented in Phase 5 of the Eden project. These systems build upon the core architecture established in Phases 1-4 and provide powerful tools for creating a self-evolving, dynamic entity ecosystem.

## Overview

The Phase 5 advanced features include:

1. **Interaction Matrix**: Defines how entities interact with each other based on their types and properties
2. **Entity Evolution**: Manages the progression of entities through different evolution stages
3. **Data Transformation**: Provides a flexible system for dynamic transformations of entity data
4. **Event System**: Facilitates communication between different components of the system
5. **Query Language**: Enables complex entity searches with filtering, sorting, and projections
6. **Advanced System Integration**: Ties all systems together and provides a unified interface

## JSHInteractionMatrix

The Interaction Matrix system defines rules for how entities interact with each other, and what effects these interactions have.

### Key Features

- Define interaction rules between entity types
- Specify probability and conditions for interactions
- Support various effects:
  - Transform: Change entity types
  - Spawn: Create new entities
  - Evolve: Change entity properties or stage
  - Merge: Combine multiple entities
  - Split: Divide entities into multiple new entities
- Cooldown timers to prevent excessive interactions
- Process interactions for individual entities or groups

### Usage Example

```gdscript
# Define an interaction rule between water and seed
var interaction_matrix = JSHInteractionMatrix.get_instance()
interaction_matrix.add_interaction_rule(
    "water", "seed", 0.8, "transform", {
        "target_becomes": "plant_seedling",
        "source_consumed": true
    }
)

# Process interaction between two entities
var water_entity = entity_manager.get_entity("water_123")
var seed_entity = entity_manager.get_entity("seed_456")
interaction_matrix.process_interaction(water_entity, seed_entity)
```

## JSHEntityEvolution

The Entity Evolution system manages how entities progress through different stages over time, based on their properties and complexity.

### Key Features

- Define evolution stages for different entity types
- Set complexity and property requirements for evolution
- Automate evolution based on time and conditions
- Handle entity transformations during evolution
- Track evolution history and paths

### Usage Example

```gdscript
# Define an evolution stage
var evolution_system = JSHEntityEvolution.get_instance()
evolution_system.define_evolution_stage(
    "seedling", "plant", 1, 1.0, {
        "water_level": {"min": 2.0},
        "sunlight": {"min": 1.0}
    }, "plant_seedling"
)

# Set up stage connections
evolution_system.add_next_stage("seed", "seedling")

# Initialize entity evolution
var plant_entity = entity_manager.get_entity("plant_123")
evolution_system.initialize_entity_evolution(plant_entity)

# Check if entity can evolve
if evolution_system.can_evolve_to_stage(plant_entity, "seedling"):
    evolution_system.evolve_entity_to_stage(plant_entity, "seedling")
```

## JSHDataTransformation

The Data Transformation system provides a flexible way to modify and process entity properties and behavior.

### Key Features

- Define reusable transformation templates
- Apply various data operations:
  - Math operations: add, subtract, multiply, divide
  - String operations: concat, replace, etc.
  - Collection operations: merge, split
  - Conditional operations: if-then-else logic
- Evaluate expressions and formulas
- Process batches of entities with transformations

### Usage Example

```gdscript
# Register a transformation template
var transformation_system = JSHDataTransformation.get_instance()
transformation_system.register_transformation_template(
    "growth",
    "Increases size, mass, and complexity of an entity over time",
    [
        {
            "operation": "multiply",
            "property": "size",
            "value": 1.1
        },
        {
            "operation": "add",
            "property": "complexity",
            "value": 0.2
        }
    ],
    ["plant", "animal", "tree"]
)

# Apply transformation to an entity
var tree_entity = entity_manager.get_entity("tree_123")
transformation_system.apply_transformation("growth", tree_entity)
```

## JSHEventSystem

The Event System facilitates communication between different components of the system using an event-based architecture.

### Key Features

- Subscribe to events with callbacks
- Emit events with custom data
- Define event channels for organizing related events
- Filter events based on criteria
- Priority-based event handling
- One-time event subscriptions
- Event history tracking and replay

### Usage Example

```gdscript
# Subscribe to an event
var event_system = JSHEventSystem.get_instance()
var subscriber_id = event_system.subscribe("entity_created", func(event_name, event_data):
    print("Entity created: " + event_data.entity_id)
)

# Subscribe to a channel
event_system.subscribe_to_channel("entity", func(event_name, event_data):
    print("Entity event: " + event_name)
)

# Emit an event
event_system.emit_event("entity_created", {
    "entity_id": "entity_123",
    "entity_type": "tree"
})

# Unsubscribe
event_system.unsubscribe("entity_created", subscriber_id)
```

## JSHQueryLanguage

The Query Language provides a flexible way to search for entities using complex queries with filtering, sorting, and projections.

### Key Features

- Create queries using a fluent API or query strings
- Filter entities by type, properties, and tags
- Complex conditions with AND, OR, NOT operators
- Sort results by multiple properties
- Paginate results with limit and offset
- Project specific properties in results
- Group results by properties
- Parse query strings into structured queries

### Usage Example

```gdscript
# Create a query using the API
var query_system = JSHQueryLanguage.get_instance()
var query = query_system.create_query()
query_system.add_types(query, ["tree"])
query_system.add_where_condition(query, "height", ">", 10.0)
query_system.add_sort(query, "age", JSHQueryLanguage.SortDirection.DESCENDING)
query_system.set_limit(query, 5)

# Execute the query
var results = query_system.execute_query(query)

# Create a query using a string
var query_string = "TYPE(animal) WHERE diet == 'carnivore' AND speed > 50 SORT BY speed DESC"
var parsed_query = query_system.parse_query_string(query_string)
var string_results = query_system.execute_query(parsed_query)
```

## JSHAdvancedSystemIntegration

The Advanced System Integration module ties all the advanced systems together and provides a unified interface for working with them.

### Key Features

- Initialize and manage all advanced systems
- Process entity interactions and evolutions on a timed interval
- Handle events from all systems
- Register console commands for working with advanced features
- Automate common workflows between systems

### Usage Example

```gdscript
# Initialize all advanced systems
var advanced_systems = JSHAdvancedSystemIntegration.get_instance()
advanced_systems.initialize()

# Later, shut down all systems
advanced_systems.shutdown()
```

## Console Commands

The Advanced System Integration module registers several console commands for working with the advanced features:

- `interaction.list`: Lists all interaction rules
- `interaction.trigger <source_id> <target_id>`: Triggers an interaction between entities
- `evolution.stages [entity_type]`: Lists evolution stages for an entity type
- `evolution.evolve <entity_id> <target_stage>`: Evolves an entity to a specific stage
- `transform.list`: Lists all transformation templates
- `transform.apply <entity_id> <template> [params]`: Applies a transformation to an entity
- `query.run <query_string>`: Runs a query using query language

## Integration with Existing Systems

These advanced features build upon and integrate with the core systems from Phases 1-4:

- **Entity System**: Enhanced with interactions, evolution, and transformations
- **Database System**: Extended with advanced query capabilities
- **Spatial System**: Integrated with interactions and events
- **UI System**: Connected through events and console commands

## Getting Started

To start using the advanced features, initialize the Advanced System Integration:

```gdscript
func _ready():
    # Initialize basic systems first
    var entity_manager = JSHEntityManager.get_instance()
    var database_manager = JSHDatabaseManager.get_instance()
    var spatial_manager = JSHSpatialManager.get_instance()
    var console_manager = JSHConsoleManager.get_instance()
    
    # Then initialize advanced systems
    var advanced_systems = JSHAdvancedSystemIntegration.get_instance()
    advanced_systems.initialize()
```

## Conclusion

These advanced features complete the architecture for the Eden project, providing a powerful set of tools for creating a self-evolving, dynamic entity ecosystem. The combination of interactions, evolution, transformations, events, and queries enables the creation of complex, emergent behaviors and patterns within the virtual world.

---

*Documentation for JSH Advanced Features - Eden Project Phase 5*