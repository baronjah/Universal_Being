# Akashic Records System

This is a self-evolving database system where entities can transform into other types based on interactions, and data that gets too large automatically splits into separate files while maintaining references.

## Core Features

1. **Universal Entity System**: Everything starts as a primordial entity that can transform into anything
2. **Self-Evolving Database**: Data that grows too large becomes its own file automatically
3. **Interaction Matrix**: Defines how different entity types interact with each other
4. **Zone Management**: Spatial organization of entities
5. **Debug UI**: Visual interface for testing and exploring the system

## Installation

1. Copy all `.gd` files to your Godot project's scripts directory
2. Add the scene `akashic_test_scene.tscn` to your project
3. Run the scene to test the system

## Files

- `JSH_Akashic_Records.gd`: Main controller that initializes all components
- `akashic_records_manager.gd`: Manages entity tracking and dictionaries
- `database_integrator.gd`: Handles database splitting and file management
- `universal_entity.gd`: Base entity class that can transform into anything
- `universal_bridge.gd`: Connects systems and processes interactions
- `interaction_matrix.gd`: Defines interaction rules between entity types
- `zone_manager.gd`: Manages spatial organization of entities
- `debug_ui.gd`: Testing interface for the Akashic Records system
- `akashic_test.gd`: Simple test script to demonstrate usage

## Usage

### Basic Example

```gdscript
# Get a reference to the Akashic Records system
var akashic = get_node("JSH_AkashicRecords")

# Create a primordial entity
var entity = akashic.create_entity("primordial", {"energy": 10})

# Transform it into fire
akashic.transform_entity(entity, "fire")

# Create a water entity
var water_entity = akashic.create_entity("water", {"energy": 5})

# Interact them (will produce steam based on interaction rules)
var result = akashic.process_interaction(entity, water_entity)
```

### Keyboard Shortcuts

- `F3`: Toggle debug UI
- `F1`: Run tests (in test scene)

## Using the Debug UI

The debug UI provides a visual interface for:

1. Viewing all entities and their properties
2. Creating new entities
3. Transforming entities
4. Testing interactions between entities
5. Monitoring database splitting

## Customizing the System

### Adding New Entity Types

Edit the `_init_core_dictionaries()` method in `akashic_records_manager.gd` to add new entity types:

```gdscript
dictionaries["entity_types"]["new_type"] = {
    "description": "Description of the new type",
    "properties": {"property1": value1, "property2": value2},
    "interactions": ["effect1", "effect2"]
}
```

### Adding New Interaction Rules

Edit the `interaction_rules` dictionary in `interaction_matrix.gd` to add new interaction rules:

```gdscript
interaction_rules["type1"]["type2"] = {
    "result": "effect_name",
    "probability": 0.7,
    "new_type": "result_type"
}
```

### Customizing Database Splitting

Edit the constants in `database_integrator.gd` to customize when database splitting occurs:

```gdscript
const MAX_ENTRIES_PER_FILE = 1000  # Split when more than 1000 entries
const MAX_FILE_SIZE_KB = 500       # Split when larger than 500KB
const CHECK_INTERVAL = 5.0         # Check every 5 seconds
```

## Integration with Existing JSH Systems

The JSH_AkashicRecords class will automatically try to find and connect to existing JSH systems (records_system, data_splitter, database_system) in your scene. If they're not found, it will create placeholders.

To ensure proper connection, add your JSH systems to the "jsh_systems" group:

```gdscript
# In your existing JSH system scripts
func _ready():
    add_to_group("jsh_systems")
```