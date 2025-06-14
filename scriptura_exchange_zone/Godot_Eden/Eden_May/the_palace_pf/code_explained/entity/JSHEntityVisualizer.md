# JSHEntityVisualizer

The `JSHEntityVisualizer` provides a dynamic, interactive visual representation of entities within the JSH Ethereal Engine. It allows users to see entities, their relationships, and properties through different visualization modes.

## Overview

The Entity Visualizer transforms abstract entity data into an interactive graphical interface. It displays entities as nodes with properties such as type, complexity, and evolution stage visually encoded. Relationships between entities are shown as directed connections, and users can interact with the visualization to explore the system.

## Core Concepts

### Visualization Modes

The visualizer supports three distinct ways to view entities:

1. **Graph Mode**: A force-directed graph layout that positions entities based on their relationships. Connected entities are pulled together, while unconnected entities repel each other.

2. **Spatial Mode**: Entities are positioned according to their actual coordinates in 3D space, projected onto a 2D plane. This provides a view of the spatial distribution of entities.

3. **Hierarchy Mode**: Entities are arranged in a hierarchical structure based on their evolution stages. More evolved entities appear lower in the visualization.

### Entity Representation

Entities are visually represented with several key features:

- **Node**: Each entity is displayed as a circular node.
- **Color**: Node colors indicate entity type (fire, water, earth, etc.).
- **Size**: Node size correlates with entity complexity.
- **Evolution Indicators**: White dots around the node perimeter show the evolution stage.
- **Labels**: Nodes can display entity IDs and types.
- **Properties**: Detailed property information can be shown for selected entities.

### Connection Types

Relationships between entities are visualized as directed lines with different colors:

- **Parent-Child**: Green lines indicate parent relationships.
- **Child-Parent**: Red lines indicate child relationships.
- **Fusion**: Orange lines show fusion relationships.
- **Split**: Blue lines show splitting relationships.
- **Creation**: Purple lines indicate entity creation relationships.
- **Default**: Gray lines represent other relationship types.

## Key Features

### Interactive Navigation

- **Pan**: Middle-click and drag to move around the visualization.
- **Zoom**: Mouse wheel to zoom in and out.
- **Selection**: Left-click to select an entity and view its details.
- **Details**: Right-click on a selected entity to request detailed information.

### Display Options

- **Labels**: Toggle entity labels on/off.
- **Types**: Show or hide entity type information.
- **Properties**: Display entity properties for selected entities.
- **Connections**: Show or hide relationship lines between entities.

### Focus Control

- **Entity Focus**: Center the view on a specific entity.
- **Zone Focus**: Highlight all entities within a particular spatial zone.

### Real-time Updates

The visualizer automatically updates when:
- New entities are created
- Entities are destroyed
- Entity properties change
- Relationships between entities change

## Implementation Details

### Node Graphics

Each entity node contains the following information:
- **ID**: Unique identifier for the entity
- **Type**: Entity type (fire, water, etc.)
- **Position**: Current position in the visualization
- **Size**: Node diameter
- **Color**: Visual color based on entity type
- **Label**: Short ID shown as text label
- **Evolution Stage**: Current evolution level
- **Complexity**: Entity complexity value
- **Properties**: Entity property dictionary
- **References**: Relationship references to other entities
- **Tags**: Entity tags
- **Zones**: Spatial zones the entity belongs to
- **Selected**: Whether the node is currently selected
- **Hovered**: Whether the node is being hovered over

### Layout Algorithms

The visualizer implements three layout algorithms:

1. **Force-Directed Layout**: Uses a physics simulation where:
   - Entities repel each other with an inverse-square force
   - Connected entities attract each other with a spring-like force
   - A gentle gravitational pull keeps entities centered
   - Position updates are damped to prevent oscillation

2. **Spatial Layout**: Projects 3D spatial coordinates onto the 2D visualization plane.

3. **Hierarchical Layout**: Arranges entities in horizontal rows based on evolution stage.

### Drawing System

The visualization is rendered using Godot's 2D drawing functions:
- `draw_circle()` for entity nodes
- `draw_arc()` for node borders
- `draw_line()` for connections
- `draw_triangle()` for direction arrows
- `draw_string()` for labels and properties

### Signal System

The visualizer emits several signals to interact with other components:
- `entity_selected`: When a user selects an entity
- `entity_hovered`: When the mouse hovers over an entity
- `entity_details_requested`: When a user requests detailed information
- `zoom_changed`: When the zoom level changes

## Practical Use

### Accessing the Visualizer

```gdscript
# Get the visualizer instance (typically from a scene)
var visualizer = $EntityVisualizer  # or however you've set up your scene

# Set the display mode
visualizer.set_mode("graph")  # Options: "graph", "spatial", "hierarchy"

# Focus on a specific entity
visualizer.set_focus_entity("entity_12345")

# Focus on entities in a zone
visualizer.set_focus_zone("zone_central")
```

### Customizing the Display

```gdscript
# Configure display options
visualizer.show_labels = true
visualizer.show_types = true
visualizer.show_properties = false
visualizer.show_connections = true

# Set zoom level manually
visualizer.zoom_level = 1.5
visualizer.queue_redraw()
```

### Connecting to Visualizer Signals

```gdscript
# Connect to entity selection events
visualizer.connect("entity_selected", Callable(self, "_on_entity_selected"))

# Handle selection events
func _on_entity_selected(entity_id):
    print("Selected entity: " + entity_id)
    # Maybe update a details panel with entity info
    var entity = JSHEntityManager.get_instance().get_entity(entity_id)
    if entity:
        $DetailsPanel.display_entity(entity)
```

### Custom Visualization Enhancements

```gdscript
# Add a custom entity type color
visualizer.type_colors["crystal"] = Color(0.7, 0.9, 1.0)

# Refresh visualization after configuration changes
visualizer._initialize_visualization()
```

## Integration with Other Systems

The Entity Visualizer integrates directly with:

- **JSHEntityManager**: Retrieves entity data and listens for entity events
- **JSHSpatialManager**: Gets spatial positions for entities in spatial mode
- **UI Systems**: Provides interactive visualization for the user interface
- **Selection Systems**: Enables entity selection for commands or details

## Technical Considerations

### Performance

The force-directed graph layout is computationally intensive. For large numbers of entities:
- The algorithm runs a fixed number of iterations (100) per layout
- Consider limiting visible entities through filtering or pagination
- Use zone focus to restrict visualization to relevant spatial areas

### Visual Clarity

As the number of entities increases, the visualization can become cluttered:
- Use filtering and focus mechanisms to limit visible entities
- Adjust the zoom level for different density views
- Consider implementing node clustering for dense areas

### Extending the Visualizer

To add custom visualization features:
- Add new entity type colors in the `type_colors` dictionary
- Extend the `_draw()` method to add custom graphical elements
- Create new layout algorithms by implementing additional layout methods
- Add custom entity property visualizations for specific entity types