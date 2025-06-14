# Script Documentation: CoreUniversalEntity

## Overview
CoreUniversalEntity is the foundational entity class of the JSH Ethereal Engine. It represents a universal entity that can manifest from words, transform between different forms, evolve through stages, and interact with other entities in the system. Each entity has a visual representation in 3D space with form-specific appearances and evolution effects.

## File Information
- **File Path:** `/code/core/UniversalEntity_Enhanced.gd`
- **Lines of Code:** 1395
- **Class Name:** CoreUniversalEntity
- **Extends:** Node3D

## Dependencies
- Godot 4.x Node3D
- Various 3D primitives (SphereMesh, CylinderMesh, etc.)
- StandardMaterial3D for visual representations
- GPUParticles3D for particle effects

## Properties

### Core Identity Properties
| Property | Type | Description |
|----------|------|-------------|
| entity_id | String | Unique identifier for the entity |
| source_word | String | The word that this entity was manifested from |
| entity_type | String | The type of entity (default: "primordial") |
| manifestation_level | float | Degree of manifestation from 0.0 (potential) to 1.0 (fully manifested) |

### Form and Properties
| Property | Type | Description |
|----------|------|-------------|
| current_form | String | The visual form of the entity (e.g., "seed", "flame", "crystal") |
| properties | Dictionary | Dynamic properties derived from the source word |
| evolution_stage | int | Current evolution stage (0-5) |
| creation_timestamp | String | When the entity was created |
| transformation_history | Array | Record of all transformations |
| references | Dictionary | References to other entities by type |

### Complexity and Evolution
| Property | Type | Description |
|----------|------|-------------|
| complexity | float | Complexity level that affects evolution |
| parent_entities | Array | IDs of entities that created this entity |
| child_entities | Array | IDs of entities created from this entity |
| last_processed_time | int | Last time the entity was processed |
| should_split | bool | Whether the entity should split due to high complexity |
| metadata | Dictionary | Additional data about the entity |
| tags | Array | Tags for categorization |
| zones | Array | Zones that the entity belongs to |

### Relationships
| Property | Type | Description |
|----------|------|-------------|
| parent_entity | CoreUniversalEntity | Direct parent entity reference |
| connected_entities | Array | Entities connected to this entity |

### Reality Context
| Property | Type | Description |
|----------|------|-------------|
| reality_context | String | Context of reality ("physical", "digital", "astral", etc.) |
| dimension_layer | int | Layer of dimension (0 = base reality) |

### Visual Components
| Property | Type | Description |
|----------|------|-------------|
| visual_container | Node3D | Container for visual representations |
| effect_container | Node3D | Container for particle effects |
| particle_systems | Dictionary | References to particle systems by type |

## Signals
| Signal | Parameters | Description |
|--------|------------|-------------|
| entity_manifested | entity | Emitted when an entity is created from a word |
| entity_transformed | entity, old_form, new_form | Emitted when an entity transforms to a new form |
| entity_evolved | entity, old_stage, new_stage | Emitted when an entity evolves to a new stage |
| entity_connected | entity, target_entity, connection_type | Emitted when an entity connects to another entity |
| transformed | old_type, new_type | Emitted when an entity changes type |
| property_changed | property_name, old_value, new_value | Emitted when a property changes |
| interacted | other_entity, result | Emitted when an entity interacts with another entity |
| complexity_changed | old_value, new_value | Emitted when complexity changes |
| evolution_stage_changed | old_stage, new_stage | Emitted when evolution stage changes |
| entity_split | original_entity, new_entities | Emitted when an entity splits into multiple entities |
| entity_merged | source_entities, new_entity | Emitted when multiple entities merge |

## Core Methods

### Initialization
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _init | id, type, init_properties | void | Initializes a new entity with the given ID, type, and properties |
| _ready | | void | Sets up initial visual containers and representation |

### Manifestation System
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| manifest_from_word | word, influence | CoreUniversalEntity | Creates an entity from a word with the given influence |
| transform | new_type | bool | Changes the entity type |
| transform_to | new_form, transformation_time | CoreUniversalEntity | Transforms the entity to a new visual form |
| evolve | evolution_factor | CoreUniversalEntity | Evolves the entity to the next stage |

### Connection System
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| connect_to | target_entity, connection_type | bool | Connects this entity to another entity |
| become_child_of | parent | bool | Makes this entity a child of another entity |

### Property Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| set_property | property_name, value | void | Sets a property value |
| get_property | property_name, default_value | any | Gets a property value |
| interact_with | other_entity | Dictionary | Interacts with another entity |

### Reference Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| add_reference | reference_type, target_entity_id | void | Adds a reference to another entity |
| remove_reference | reference_type, target_entity_id | bool | Removes a reference to an entity |
| add_transformation_record | action, from_type, to_type | void | Records a transformation |

### Complexity System
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| calculate_initial_complexity | | float | Calculates initial complexity based on type and properties |
| update_complexity | | void | Updates complexity and checks for evolution/splitting |
| calculate_complexity | | float | Calculates current complexity based on various factors |

### Evolution System
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| check_evolution_stage | | void | Checks if entity should evolve |
| calculate_evolution_stage | | int | Calculates appropriate evolution stage based on complexity |

### Splitting and Merging
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| check_split_threshold | | void | Checks if entity should split due to complexity |
| attempt_split | | Array | Attempts to split entity into multiple new entities |
| merge_entities | entities | CoreUniversalEntity | Static method to merge multiple entities into one |

### Zone Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| add_to_zone | zone_id | bool | Adds entity to a zone |
| remove_from_zone | zone_id | bool | Removes entity from a zone |
| get_zones | | Array | Gets zones the entity belongs to |

### Tag Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| add_tag | tag | bool | Adds a tag to the entity |
| remove_tag | tag | bool | Removes a tag from the entity |
| has_tag | tag | bool | Checks if entity has a tag |
| get_tags | | Array | Gets all entity tags |

### Metadata Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| set_metadata | key, value | void | Sets metadata value |
| get_metadata | key, default_value | any | Gets metadata value |
| remove_metadata | key | bool | Removes metadata value |

### Lifecycle Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| process | delta | void | Processes entity updates over time |

### Serialization
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| to_dict | | Dictionary | Converts entity to serializable dictionary |
| from_dict | data | bool | Rebuilds entity from dictionary data |

## Visual Representation Methods
| Method | Description |
|--------|-------------|
| _update_visual_representation | Updates visual based on current form and evolution stage |
| _create_seed_visual | Creates visual for seed form |
| _create_flame_visual | Creates visual for flame form |
| _create_droplet_visual | Creates visual for droplet form |
| _create_crystal_visual | Creates visual for crystal form |
| _create_wisp_visual | Creates visual for wisp form |
| _create_flow_visual | Creates visual for flow form |
| _create_void_spark_visual | Creates visual for void spark form |
| _create_pattern_visual | Creates visual for pattern form |
| _create_spark_visual | Creates visual for spark form |
| _create_orb_visual | Creates visual for orb form |
| _create_sprout_visual | Creates visual for sprout form |
| _create_light_mote_visual | Creates visual for light mote form |
| _create_shadow_essence_visual | Creates visual for shadow essence form |
| _create_default_visual | Creates default visual for unknown forms |
| _add_particle_system | Adds particle effects for a specific type |
| _set_transformation_progress | Handles visual transition between forms |
| _finalize_transformation | Completes transformation process |
| _update_properties_for_evolution | Updates properties based on evolution stage |
| _apply_evolution_effects | Applies visual effects based on evolution stage |
| _create_connection_visual | Creates visual connection between entities |

## Usage Examples

### Creating a basic entity
```gdscript
# Create a new primordial entity
var entity = CoreUniversalEntity.new()

# Manifest it from a word
entity.manifest_from_word("fire")

# Add to scene
add_child(entity)
```

### Evolution and transformation
```gdscript
# Evolve the entity to increase complexity
entity.evolve(0.5)

# Transform to a different form
entity.transform_to("crystal", 2.0)
```

### Entity connections
```gdscript
# Connect two entities
var entity1 = CoreUniversalEntity.new()
var entity2 = CoreUniversalEntity.new()

entity1.manifest_from_word("water")
entity2.manifest_from_word("earth")

entity1.connect_to(entity2, "harmony")
```

### Merging entities
```gdscript
# Create entities for merging
var entities = []
entities.append(CoreUniversalEntity.new().manifest_from_word("fire"))
entities.append(CoreUniversalEntity.new().manifest_from_word("water"))

# Merge them into a new entity
var merged_entity = CoreUniversalEntity.merge_entities(entities)

# Add the merged entity to the scene
add_child(merged_entity)
```

## Integration Points
CoreUniversalEntity integrates with several other components:

- **Word Manifestation System**: Entities are created from words through the WordManifestor
- **Entity Management System**: Entities are tracked and managed by the EntityManager
- **Spatial Management**: Entities exist in spatial contexts managed by the SpatialManager
- **Evolution System**: Evolution is handled by the EntityEvolution component
- **Visualization System**: Visual representation integrated with the EntityVisualizer

## Notes and Considerations
- Entity complexity growth over time can lead to splitting, creating emergent behavior
- The visual representation system is designed to work with the Godot 4.x rendering system
- Forms are closely tied to elemental properties derived from words
- The entity system follows a component-based design where functionality can be extended

## Related Documentation
- [Core Word Manifestor](CoreWordManifestor.md)
- [Entity Manager](../entity/JSHEntityManager.md)
- [Entity Evolution](../entity/JSHEntityEvolution.md)
- [Entity Visualizer](../visualization/JSHEntityVisualizer.md)