# JSH Spatial System

This document outlines the JSH Spatial System, a framework for managing the spatial organization of entities in the game world, with support for zones, partitioning, and optimized spatial queries.

## Core Components

### JSHSpatialInterface

An abstract interface defining the standard methods that all spatial management systems should implement:

- **Zone Operations**: create_zone, delete_zone, update_zone, zone_exists, get_zone, get_all_zones
- **Zone Queries**: get_zones_in_radius, get_zones_in_box, zone_contains_point
- **Entity Zone Management**: add_entity_to_zone, remove_entity_from_zone, get_entity_zones, get_entities_in_zone
- **Entity Position Management**: set_entity_position, get_entity_position, move_entity
- **Spatial Queries**: get_entities_in_radius, get_entities_in_box, get_nearest_entities, cast_ray
- **Visibility and Culling**: set_active_zone, get_active_zone, set_visible_zones, get_visible_zones, is_entity_visible
- **Zone Subdivision**: subdivide_zone, merge_zones, get_parent_zone, get_child_zones
- **Zone Transitions**: register_zone_transition, get_zone_transitions, transition_entity

### JSHSpatialManager

A comprehensive spatial management system that implements the spatial interface:

- **Zone Management**: Creates, deletes, and updates zones with hierarchical organization
- **Entity Tracking**: Tracks entity positions and zone membership
- **Spatial Partitioning**: Uses octree and grid-based partitioning for efficient spatial queries
- **Dynamic Loading/Unloading**: Automatically loads and unloads zones based on distance from active zone
- **Signal System**: Emits signals for zone and entity spatial events
- **Performance Optimization**: Implements visibility culling and priority-based processing

### JSHSpatialGrid

A uniform grid-based spatial partitioning system for efficient entity queries:

- **Cell-Based Organization**: Divides space into uniform cells
- **Multi-Zone Support**: Maintains separate grids for each zone
- **Fast Spatial Queries**: Optimized for point, box, and sphere queries
- **Dynamic Updates**: Efficiently handles moving entities

### JSHOctree

A hierarchical spatial partitioning system for zone management:

- **Recursive Subdivision**: Divides space into hierarchical octants
- **Node-Based Organization**: Stores zones in an octree node hierarchy
- **Efficient Zone Queries**: Optimized for zone lookups by spatial criteria
- **Adaptive Structure**: Dynamically adjusts node size based on zone density

## Key Concepts

### Zone System

The spatial system organizes the game world into zones:

1. **Zone Hierarchy**: Zones can have parent-child relationships
2. **Zone Boundaries**: Each zone has defined 3D boundaries
3. **Zone Properties**: Zones can have custom properties (biome, difficulty, etc.)
4. **Zone Transitions**: Connections between zones (portals, boundaries, etc.)
5. **Automatic Subdivision**: Zones can be automatically subdivided when they contain too many entities

### Spatial Partitioning

The system uses two types of spatial partitioning:

1. **Grid Partitioning**: Fast uniform grid for entity lookups
   - Constant-time insertion and removal
   - Efficient for dynamic entities that move frequently
   - Good for dense, evenly distributed entities

2. **Octree Partitioning**: Hierarchical space division for zone management
   - Logarithmic query complexity
   - Efficient for large, sparse worlds
   - Adaptive to different zone densities

### Dynamic Loading

The system optimizes memory and processing by dynamically loading and unloading zones:

1. **Active Zone**: The primary zone where the player or focus is located
2. **Visible Zones**: Zones that are currently loaded and visible
3. **Loading Radius**: Zones within a certain distance of the active zone are automatically loaded
4. **Zone Connections**: Connected zones remain loaded even if outside the loading radius
5. **Priority Loading**: Zones are loaded based on importance and visibility

## Usage Examples

### Creating and Managing Zones

```gdscript
# Create a spatial manager
var spatial_manager = JSHSpatialManager.get_instance()

# Create a zone
var zone_data = {
    "name": "Forest Zone",
    "bounds": {
        "min_x": -500, "max_x": 500,
        "min_y": 0, "max_y": 100,
        "min_z": -500, "max_z": 500
    },
    "level": 0,
    "is_root": true,
    "autoload": true,
    "properties": {
        "biome": "forest",
        "ambient_light": 0.7
    }
}

spatial_manager.create_zone("forest_zone", zone_data)

# Subdivide a zone
var child_zones = spatial_manager.subdivide_zone("forest_zone", Vector3i(2, 2, 2))
print("Created " + str(child_zones.size()) + " child zones")

# Set active zone
spatial_manager.set_active_zone("forest_zone")
```

### Managing Entity Positions

```gdscript
# Create an entity
var entity = entity_manager.create_entity("fire", {
    "energy": 10,
    "intensity": 3,
    "collision_radius": 5.0
})

# Set entity position
var position = Vector3(100, 10, 50)
spatial_manager.set_entity_position(entity.get_id(), position)

# Add entity to zone
spatial_manager.add_entity_to_zone(entity.get_id(), "forest_zone")

# Move entity to new position
spatial_manager.move_entity(entity.get_id(), Vector3(120, 10, 60))

# Get entity's current position
var current_pos = spatial_manager.get_entity_position(entity.get_id())
```

### Creating Zone Transitions

```gdscript
# Register a transition between two zones
spatial_manager.register_zone_transition("forest_zone", "mountain_zone", {
    "type": "portal",
    "bidirectional": true,
    "position": Vector3(500, 50, 0),  # Position of the transition point
    "target_position": Vector3(-500, 50, 0)  # Where the entity appears in the target zone
})

# Transition an entity to another zone
spatial_manager.transition_entity(entity.get_id(), "mountain_zone")

# Get all transitions from a zone
var transitions = spatial_manager.get_zone_transitions("forest_zone")
for transition in transitions:
    print("Transition to " + transition.target_zone)
```

### Spatial Queries

```gdscript
# Get entities within a radius
var center = Vector3(100, 10, 100)
var radius = 50.0
var entities_in_radius = spatial_manager.get_entities_in_radius(center, radius)

# Filter by type
var fire_entities = spatial_manager.get_entities_in_radius(center, radius, {
    "type": "fire"
})

# Get entities in a box
var min_bounds = Vector3(50, 0, 50)
var max_bounds = Vector3(150, 20, 150)
var entities_in_box = spatial_manager.get_entities_in_box(min_bounds, max_bounds)

# Get nearest entities
var nearest = spatial_manager.get_nearest_entities(center, 5, 100.0)

# Cast a ray
var ray_start = Vector3(0, 10, 0)
var ray_end = Vector3(100, 10, 0)
var ray_result = spatial_manager.cast_ray(ray_start, ray_end)

if ray_result.hit:
    print("Hit entity: " + ray_result.entity.get_id())
    print("Hit position: " + str(ray_result.position))
    print("Hit distance: " + str(ray_result.distance))
```

### Zone Visibility and Loading

```gdscript
# Set active zone
spatial_manager.set_active_zone("forest_zone")

# Get visible zones
var visible_zones = spatial_manager.get_visible_zones()

# Manually set visible zones
spatial_manager.set_visible_zones(["forest_zone", "mountain_zone"])

# Check if entity is visible
var is_visible = spatial_manager.is_entity_visible(entity.get_id())

# Get zones at a position
var zones = spatial_manager.get_zones_containing_point(Vector3(100, 10, 100))
```

## Integration with Existing Systems

The JSH Spatial System integrates with the existing JSH Entity and Database Systems:

- **Entity System Integration**: Automatically tracks entity positions and zone membership
- **Database Integration**: Saves and loads zone data and entity spatial information
- **Signal Integration**: Emits signals that other systems can connect to for spatial events

The system also provides a framework for integration with rendering systems:

- **Visibility Determination**: Provides information about which entities should be rendered
- **Level of Detail**: Supports different detail levels based on distance
- **Culling Support**: Implements frustum and distance-based culling

## Hierarchical Zone Organization

Zones are organized in a hierarchy to support different detail levels and efficient spatial management:

1. **Root Zones**: Top-level zones that define major world areas
2. **Child Zones**: Subdivisions of parent zones for more detailed areas
3. **Automatic Subdivision**: Zones can be automatically subdivided based on entity density
4. **Dynamic Merging**: Child zones can be merged back into parent zones for performance

```
- Root Zone (World)
  |
  +-- Zone Level 1A (Continent)
  |    |
  |    +-- Zone Level 2A (Region)
  |    |    |
  |    |    +-- Zone Level 3A (Area)
  |    |    |
  |    |    +-- Zone Level 3B (Area)
  |    |
  |    +-- Zone Level 2B (Region)
  |
  +-- Zone Level 1B (Continent)
       |
       +-- Zone Level 2C (Region)
```

## Testing

The system includes a test harness for verifying functionality:

1. **JSHSpatialTest**: A test script that demonstrates spatial operations
2. **JSHSpatialTestScene**: A test scene for interactive testing
3. **Movement Simulation**: Tests entity movement across zone boundaries
4. **Query Testing**: Tests spatial query performance and accuracy

## Next Steps

1. **Terrain Integration**: Connect zones to terrain generation and management
2. **Physics Integration**: Integrate with physics system for more accurate collision detection
3. **Visual Debugging**: Add visualizations for zones, boundaries, and transitions
4. **LOD System**: Implement level of detail system for entities based on distance
5. **Path Finding**: Add path finding across zones and within zones