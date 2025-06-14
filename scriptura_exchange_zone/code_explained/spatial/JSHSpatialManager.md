# Script Documentation: JSHSpatialManager

## Overview
JSHSpatialManager is a comprehensive spatial management system for the JSH Ethereal Engine. It handles zone creation, entity positioning, spatial partitioning, and spatial queries. This system allows entities to exist in 3D space, be organized into logical zones, and efficiently located through spatial queries.

## File Information
- **File Path:** `/code/spatial/JSHSpatialManager.gd`
- **Lines of Code:** ~600
- **Class Name:** JSHSpatialManager
- **Extends:** Node

## Dependencies
- JSHEntityManager - For entity management
- JSHDatabaseManager - For data persistence
- JSHSpatialGrid - For grid-based spatial partitioning
- JSHOctree - For tree-based spatial partitioning

## Core Properties

### System References
| Property | Type | Description |
|----------|------|-------------|
| entity_manager | JSHEntityManager | Reference to the entity management system |
| database_manager | JSHDatabaseManager | Reference to the database system |

### Zone Management
| Property | Type | Description |
|----------|------|-------------|
| zones | Dictionary | Contains all zone definitions |
| zone_hierarchy | Dictionary | Tracks parent-child relationships between zones |
| zone_entities | Dictionary | Maps zones to the entities they contain |
| zone_transitions | Dictionary | Defines transition points between zones |

### Entity Position Management
| Property | Type | Description |
|----------|------|-------------|
| entity_positions | Dictionary | Maps entity IDs to their 3D positions |
| entities_by_position | Dictionary | Spatial hash for finding entities by position |

### Spatial Partitioning
| Property | Type | Description |
|----------|------|-------------|
| spatial_grid | JSHSpatialGrid | Grid-based spatial partitioning for entities |
| spatial_tree | JSHOctree | Tree-based spatial partitioning for zones |

### Zone Visibility and Loading
| Property | Type | Description |
|----------|------|-------------|
| active_zone | String | Currently active zone ID |
| visible_zones | Array | List of currently visible zones |
| culling_enabled | bool | Whether to cull entities outside view distance |
| culling_distance | float | Maximum distance for entity visibility |
| auto_load_zones | bool | Whether to automatically load zones within range |
| zone_load_distance | float | Distance at which zones automatically load |
| load_in_progress | bool | Whether a zone load is currently in progress |
| pending_zone_loads | Array | Queue of zones waiting to be loaded |

### Statistics
| Property | Type | Description |
|----------|------|-------------|
| stats | Dictionary | Performance and usage statistics |

## Signals
| Signal | Parameters | Description |
|--------|------------|-------------|
| zone_created | zone_id, zone_data | Emitted when a new zone is created |
| zone_updated | zone_id, zone_data | Emitted when a zone is updated |
| zone_deleted | zone_id | Emitted when a zone is deleted |
| zone_loaded | zone_id | Emitted when a zone is loaded |
| zone_unloaded | zone_id | Emitted when a zone is unloaded |
| entity_moved | entity_id, old_position, new_position | Emitted when an entity moves |
| entity_added_to_zone | entity_id, zone_id | Emitted when an entity is added to a zone |
| entity_removed_from_zone | entity_id, zone_id | Emitted when an entity is removed from a zone |
| entity_transitioned | entity_id, source_zone, target_zone | Emitted when an entity moves between zones |
| active_zone_changed | old_zone, new_zone | Emitted when the active zone changes |

## Core Methods

### Singleton Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| get_instance | | JSHSpatialManager | Returns the singleton instance, creating it if needed |
| _init | | void | Initializes the singleton instance |
| _ready | | void | Sets up spatial partitioning and connections |

### Zone Operations
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| create_zone | zone_id, zone_data | bool | Creates a new zone with the specified data |
| delete_zone | zone_id | bool | Deletes a zone and handles its entities |
| update_zone | zone_id, zone_data | bool | Updates an existing zone's data |
| zone_exists | zone_id | bool | Checks if a zone exists |
| get_zone | zone_id | Dictionary | Gets a zone's data |
| get_all_zones | | Array | Gets a list of all zone IDs |

### Zone Queries
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| get_zones_in_radius | position, radius | Array | Gets zones within a radius |
| get_zones_in_box | min_bounds, max_bounds | Array | Gets zones within a bounding box |
| zone_contains_point | zone_id, position, buffer | bool | Checks if a point is within a zone |
| get_zones_containing_point | position | Array | Gets all zones containing a point |

### Entity Zone Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| add_entity_to_zone | entity_id, zone_id | bool | Adds an entity to a zone |
| remove_entity_from_zone | entity_id, zone_id | bool | Removes an entity from a zone |
| get_entity_zones | entity_id | Array | Gets all zones an entity is in |
| get_entities_in_zone | zone_id | Array | Gets all entities in a zone |

### Entity Position Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| set_entity_position | entity_id, position | bool | Sets an entity's position |
| get_entity_position | entity_id | Vector3 | Gets an entity's position |
| move_entity | entity_id, new_position | bool | Moves an entity and handles zone transitions |

### Spatial Queries
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| get_entities_in_radius | position, radius, filter | Array | Gets entities within a radius |
| get_entities_in_box | min_bounds, max_bounds, filter | Array | Gets entities within a bounding box |
| get_nearest_entity | position, max_distance, filter | Object | Gets the nearest entity to a position |
| get_nearest_entities | position, count, max_distance, filter | Array | Gets multiple nearest entities |

### Zone Loading and Visibility
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| set_active_zone | zone_id | bool | Sets the active zone |
| load_zone | zone_id | bool | Loads a zone and its entities |
| unload_zone | zone_id | bool | Unloads a zone and its entities |
| set_zone_visibility | zone_id, visible | bool | Sets whether a zone is visible |

## Zone System

The JSHSpatialManager implements a hierarchical zone system that allows organizing the game world into logical areas:

### Zone Structure
Each zone has the following key properties:
- **Bounds**: 3D bounding box defining the zone's dimensions
- **Level**: Hierarchical depth (0 for root zones)
- **Parent Zone**: Optional parent zone in the hierarchy
- **Is Root**: Flag indicating if this is a root-level zone
- **Autoload**: Whether the zone should load automatically when nearby
- **Properties**: Custom properties for gameplay logic

### Zone Hierarchy
Zones are organized in a parent-child hierarchy:
```
default (root)
├── forest
│   ├── forest_clearing
│   └── forest_cave
└── mountains
    ├── mountain_peak
    └── mountain_cave
```

This hierarchy allows for:
- Efficient spatial organization
- Logical grouping of related areas
- Level-of-detail management
- Progressive loading/unloading

### Zone Creation Example
```gdscript
var zone_data = {
    "name": "Forest Cave",
    "bounds": {
        "min_x": -50, "max_x": 50,
        "min_y": -20, "max_y": 20,
        "min_z": -50, "max_z": 50
    },
    "parent_zone": "forest",
    "level": 2,
    "autoload": true,
    "properties": {
        "light_level": "dark",
        "humidity": "high",
        "temperature": "cool"
    }
}

spatial_manager.create_zone("forest_cave", zone_data)
```

## Spatial Partitioning

The system uses two complementary approaches for spatial partitioning:

### 1. Grid-Based Partitioning (JSHSpatialGrid)
Used primarily for entity positioning and fast entity queries. Divides the world into uniform grid cells for O(1) lookups.

### 2. Tree-Based Partitioning (JSHOctree)
Used primarily for zone management and hierarchical spatial queries. Recursively subdivides space for efficient range queries.

These systems allow for fast spatial queries like:
- Finding entities within a radius
- Getting all entities in a bounding box
- Finding the nearest entity to a position
- Determining which zones contain a point

## Entity Position System

The manager tracks entity positions and handles zone transitions:

1. When an entity's position is set via `set_entity_position`:
   - The position is stored in `entity_positions`
   - The spatial grid is updated
   - The position is stored in the entity's metadata

2. When an entity moves via `move_entity`:
   - The position is updated
   - The system checks for zone transitions
   - If the entity enters new zones, it's added to them
   - Signals are emitted for position change and zone transitions

## Usage Examples

### Creating and Managing Zones
```gdscript
# Get the spatial manager
var spatial_manager = JSHSpatialManager.get_instance()

# Create a new zone
var zone_data = {
    "name": "Forest",
    "bounds": {
        "min_x": -1000, "max_x": 1000,
        "min_y": 0, "max_y": 500,
        "min_z": -1000, "max_z": 1000
    },
    "is_root": true
}
spatial_manager.create_zone("forest", zone_data)

# Update a zone
spatial_manager.update_zone("forest", {"properties": {"weather": "rainy"}})

# Delete a zone
spatial_manager.delete_zone("forest")
```

### Entity Positioning
```gdscript
# Position an entity
var entity_id = entity.get_id()
var position = Vector3(100, 0, 200)
spatial_manager.set_entity_position(entity_id, position)

# Move an entity (handles zone transitions)
spatial_manager.move_entity(entity_id, Vector3(150, 0, 250))

# Get entity position
var current_pos = spatial_manager.get_entity_position(entity_id)
```

### Spatial Queries
```gdscript
# Find entities within a radius
var nearby = spatial_manager.get_entities_in_radius(position, 50)

# Find entities with filtering
var filter = {"type": "water", "tag": "drinkable"}
var water_sources = spatial_manager.get_entities_in_radius(position, 100, filter)

# Get zones containing a point
var zones_here = spatial_manager.get_zones_containing_point(position)

# Find the nearest entity
var nearest = spatial_manager.get_nearest_entity(position, 100)
```

### Zone Management
```gdscript
# Add an entity to a zone
spatial_manager.add_entity_to_zone(entity_id, "forest")

# Set the active zone (affects visibility and loading)
spatial_manager.set_active_zone("forest")

# Get entities in a zone
var forest_entities = spatial_manager.get_entities_in_zone("forest")
```

## Integration Points

The JSHSpatialManager integrates with several other systems:

- **JSHEntityManager**: Gets entity references and notifies about spatial events
- **JSHDatabaseManager**: Persists zone data and entity positions
- **JSHSpatialGrid**: Handles grid-based entity partitioning
- **JSHOctree**: Handles tree-based zone partitioning
- **JSHUniversalEntity**: Entities are positioned and tracked in zones

## Notes and Considerations

1. **Performance**: Spatial queries are optimized through partitioning, but can still be expensive with many entities.

2. **Zone Limits**: Create zones thoughtfully as each adds overhead.

3. **Dynamic Loading**: The autoloading system can improve performance by only loading nearby zones.

4. **Storage**: Entity positions are cached in both the spatial manager and entity metadata for redundancy.

5. **Zones vs. Entities**: Zones are for logical and spatial organization, while entities are the interactive elements within zones.

## Related Documentation

- [JSHSpatialGrid](JSHSpatialGrid.md) - Grid-based spatial partitioning
- [JSHOctree](JSHOctree.md) - Tree-based spatial partitioning
- [JSHSpatialCommands](JSHSpatialCommands.md) - Console commands for spatial operations
- [JSHEntityManager](../entity/JSHEntityManager.md) - Entity management system