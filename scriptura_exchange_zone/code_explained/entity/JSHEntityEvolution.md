# JSHEntityEvolution

The `JSHEntityEvolution` system manages the evolutionary life cycle of entities within the JSH Ethereal Engine. It handles how entities transform and progress through different stages based on their properties, complexity, and environmental conditions.

## Overview

Entities in the JSH Ethereal Engine are not static; they can evolve over time based on both internal and external factors. The evolution system defines a structured progression path for different entity types, with each stage having specific requirements and potential transformations.

## Core Concepts

### Evolution Stages

Evolution stages represent discrete points in an entity's development. Each stage:
- Belongs to a specific entity type
- Has a numerical index indicating its position in the evolution sequence
- Requires a minimum complexity value
- May have specific property requirements (e.g., water level, sunlight)
- Can transform the entity into a different type
- Can trigger custom effect scripts

### Evolution Paths

Evolution paths are sequences of connected stages that define how an entity can progress. A path consists of:
- A starting stage (typically with index 0)
- One or more intermediate stages
- Branching possibilities (an entity might evolve along different paths)
- Optional transformations (changing the entity's fundamental type)

### Evolution Requirements

Each evolution stage specifies requirements that must be met for an entity to evolve, including:
- Minimum complexity level
- Property thresholds (minimum or maximum values)
- Boolean conditions (property must equal or not equal a specific value)
- Proper sequencing (must be in the correct previous stage)

## Key Features

### Stage Definition and Management

- Define evolution stages for any entity type
- Set complexity requirements and property thresholds
- Connect stages to create sequential evolution paths
- Transform entities into new types at specific stages

### Evolution Checking

- Determine if an entity can evolve to a specific stage
- Find all potential evolution options for an entity
- Process evolution for batches of entities over time
- Automatically evolve entities when conditions are met

### Persistence

- Save evolution configurations to file in JSON format
- Load evolution configurations from saved files
- Reset to default stages when needed

### Utility Functions

- Get information about an entity's current stage
- Find the available next stages for an entity
- Get comprehensive information about stages and requirements
- Initialize entities with appropriate evolution properties

## Implementation Details

### EvolutionStage Class

An inner class that defines a single evolution stage with the following properties:
- `stage_name`: Unique identifier for the stage
- `entity_type`: The type of entity this stage applies to
- `stage_index`: Numerical position in the evolution sequence
- `required_complexity`: Minimum complexity value needed
- `requirements`: Dictionary of property requirements
- `transforms_to`: Optional entity type transformation
- `effect_script`: Optional GDScript code to run on evolution
- `next_stages`: Array of possible next stage names

### Key Methods

#### Stage Management

- `define_evolution_stage()`: Creates a new evolution stage
- `add_next_stage()`: Connects two stages in sequence
- `reset_stages()`: Clears all stages and restores defaults

#### Entity Evolution

- `get_entity_stage()`: Determines an entity's current stage
- `get_next_stages()`: Lists possible evolution targets
- `can_evolve_to_stage()`: Checks if requirements are met
- `evolve_entity_to_stage()`: Performs the actual evolution
- `process_batch_evolution()`: Handles evolution for multiple entities

#### Persistence

- `save_to_file()`: Serializes all stages to JSON
- `load_from_file()`: Loads stages from a JSON file

#### Utilities

- `get_evolvable_entity_types()`: Lists all entity types with evolution paths
- `get_stages_for_entity_type()`: Lists all stages for a given entity type
- `get_initial_stage()`: Finds the starting stage for an entity type
- `get_stage_info()`: Retrieves detailed information about a stage
- `initialize_entity_evolution()`: Sets up a new entity with evolution properties

## Example: Plant Evolution Path

The JSHEntityEvolution system includes a default example of plant evolution:

1. **seed** (stage 0): Starting point with no requirements
2. **seedling** (stage 1): Requires complexity 1.0, minimum water level 2.0, minimum sunlight 1.0
3. **young** (stage 2): Requires complexity 2.0, increased water, sunlight, and soil quality
4. **mature** (stage 3): Requires complexity 4.0, higher resource levels, and minimum age
5. **flowering** (stage 4): Requires complexity 6.0, even higher resource levels and age
6. **fruit_bearing** (stage 5): Requires complexity 8.0, maximum resource levels, sufficient age, and pollination

This example demonstrates how entities can progress through stages with increasingly complex requirements.

## Practical Use

### Defining Custom Evolution Paths

```gdscript
# Define a custom evolution path for a water entity
var evolution_system = JSHEntityEvolution.get_instance()

# Define stages
evolution_system.define_evolution_stage("droplet", "water", 0, 0.0, {})
evolution_system.define_evolution_stage("puddle", "water", 1, 2.0, {
    "volume": {"min": 5.0}
})
evolution_system.define_evolution_stage("pond", "water", 2, 4.0, {
    "volume": {"min": 20.0},
    "depth": {"min": 1.0}
})
evolution_system.define_evolution_stage("lake", "water", 3, 8.0, {
    "volume": {"min": 100.0},
    "depth": {"min": 5.0}
})

# Connect stages
evolution_system.add_next_stage("droplet", "puddle")
evolution_system.add_next_stage("puddle", "pond")
evolution_system.add_next_stage("pond", "lake")
```

### Checking Evolution Options for an Entity

```gdscript
var entity = JSHUniversalEntity.new("water")
entity.set_property("volume", 25.0)
entity.set_property("depth", 1.5)
entity.complexity = 5.0

var evolution_system = JSHEntityEvolution.get_instance()
var options = evolution_system.get_available_evolution_options(entity)

print("Available evolution options: ", options)
# Output might be: Available evolution options: ["pond"]
```

### Manually Evolving an Entity

```gdscript
var entity = JSHUniversalEntity.new("plant")
entity.set_property("water_level", 6.0)
entity.set_property("sunlight", 4.0)
entity.set_property("soil_quality", 3.0)
entity.set_property("age", 15.0)
entity.complexity = 5.0

var evolution_system = JSHEntityEvolution.get_instance()
if evolution_system.can_evolve_to_stage(entity, "mature"):
    evolution_system.evolve_entity_to_stage(entity, "mature")
    print("Entity evolved to mature stage!")
```

### Processing Batch Evolution

```gdscript
func _process(delta):
    var all_entities = JSHEntityManager.get_instance().get_all_entities()
    var evolution_system = JSHEntityEvolution.get_instance()
    
    var evolved_count = evolution_system.process_batch_evolution(all_entities, delta)
    if evolved_count > 0:
        print(str(evolved_count) + " entities evolved this frame!")
```

## Integration with Other Systems

The `JSHEntityEvolution` system works closely with:

- **JSHUniversalEntity**: Entities store their evolution stage and related properties
- **JSHEntityManager**: Manages collections of entities that can evolve
- **JSHSpatialManager**: Environmental factors in zones may influence evolution
- **JSHWordManifestor**: Words can create entities with specific evolution paths

## Technical Considerations

### Performance

The batch evolution processing is designed for efficiency, checking entities at intervals rather than every frame. The `evolution_check_interval` property (default 5.0 seconds) controls how often an entity is evaluated for evolution.

### Extensibility

The system supports:
- Custom stage requirements
- Custom evolution paths
- Entity type transformations
- Custom effect scripts at evolution points

### Security Note

The `_run_effect_script()` method executes GDScript code stored in the evolution stage. In a production environment, this should be replaced with a more structured approach to prevent security issues.