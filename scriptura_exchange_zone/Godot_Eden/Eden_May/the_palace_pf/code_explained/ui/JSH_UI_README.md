# JSH User Interface System

This document outlines the JSH User Interface System, which provides console command interfaces and visualization tools for working with the Entity, Database, and Spatial systems.

## Core Components

### JSHConsoleInterface

An abstract interface defining the standard methods that all console systems should implement:

- **Command Registration**: register_command, unregister_command, execute_command, get_command_list, get_command_help
- **Console Output**: print_line, print_error, print_warning, print_success, clear
- **Console State**: is_visible, set_visible, toggle_visibility
- **History Management**: get_command_history, clear_command_history
- **Autocomplete**: get_autocomplete_suggestions
- **Variables and Context**: set_variable, get_variable, get_all_variables

### JSHConsoleManager

The core console manager that implements the console interface and provides:

- **Command Registration and Execution**: Handles command registration, parsing, and execution
- **Output Buffering**: Manages console output with formatting and color
- **History Tracking**: Keeps track of executed commands
- **Autocomplete Support**: Provides command and argument autocompletion
- **Variable Management**: Allows setting and retrieving of context variables
- **Signal System**: Emits signals for console events

### JSHConsoleUI

The visual component that renders the console interface with:

- **Input Field**: Text input field with command history navigation
- **Output Display**: Formatted text display for command output
- **Autocomplete Panel**: Interactive autocomplete suggestions
- **Keyboard Navigation**: Keyboard shortcuts for common operations
- **Theming Support**: Light and dark themes with customizable colors

### JSHEntityVisualizer

A visualization tool for entity relationships:

- **Graph View**: Force-directed graph visualization of entity relationships
- **Spatial View**: Visualization based on spatial positions
- **Hierarchy View**: Tree-based visualization of entity hierarchies
- **Interactive Controls**: Pan, zoom, selection, and detail display
- **Visual Styling**: Entity coloring based on type, size based on complexity
- **Connection Display**: Visualization of entity references and relationships

## Command Modules

### JSHEntityCommands

Commands for working with entities:

- **entity**: Main command for entity operations
  - **list**: List all entities or filter by type/tag
  - **create**: Create a new entity
  - **delete**: Delete an entity
  - **info**: Show detailed information about an entity
  - **find**: Find entities by criteria
  - **tag**: Add or remove tags from an entity
  - **stats**: Show entity system statistics
- **entities**: Shorthand for entity list

### JSHDatabaseCommands

Commands for database operations:

- **db**: Main command for database operations
  - **list**: List entities, dictionaries, or zones in the database
  - **info**: Show detailed information about database objects
  - **save**: Save entities to the database
  - **load**: Load entities from the database
  - **delete**: Delete entities from the database
  - **stats**: Show database statistics
  - **compact**: Optimize database storage
  - **backup**: Create a database backup
- **dictionary**: Commands for dictionary management
  - **list**: List available dictionaries
  - **get**: Get a dictionary's contents
  - **save**: Save a dictionary
  - **delete**: Delete a dictionary

### JSHSpatialCommands

Commands for spatial operations:

- **zone**: Main command for zone operations
  - **list**: List all zones
  - **create**: Create a new zone
  - **delete**: Delete a zone
  - **info**: Show detailed information about a zone
  - **entities**: List entities in a zone
  - **transition**: Create a transition between zones
  - **activate**: Set the active zone
  - **subdivide**: Subdivide a zone into smaller zones
- **spatial**: Spatial query commands
  - **radius**: Find entities within a radius
  - **box**: Find entities within a box
  - **nearest**: Find nearest entities to a point
  - **ray**: Cast a ray and find intersecting entities
  - **stats**: Show spatial system statistics
- **position**: Entity position commands
  - **get**: Get an entity's position
  - **set**: Set an entity's position
  - **move**: Move an entity (affecting zone membership)

### JSHConsoleCommandIntegration

The integration module that connects all command modules:

- **jsh**: Integrated commands spanning multiple systems
  - **info**: Display system information
  - **status**: Display system status
  - **reload**: Reload systems
  - **test**: Run system tests
  - **debug**: Toggle debug mode
- **create**: Unified creation command for entities and zones
- **find**: Unified search command across all systems
- **stats**: Show statistics for all systems

## Usage Examples

### Console Commands

```
# Entity creation and management
> entity create fire energy=10 intensity=3
Entity created: a1b2c3d4
Type: fire
Properties: {"energy": 10, "intensity": 3}

> entity info a1b2c3d4
Entity: a1b2c3d4
Type: fire
Creation Time: 2024-05-09 14:32:45
Complexity: 2.5
Evolution Stage: 0

Properties:
  energy: 10
  intensity: 3

Tags:
  None

Zones:
  None

References:
  None

> entity tag add a1b2c3d4 important
Added tag 'important' to entity a1b2c3d4

# Zone creation and management
> zone create forest_zone "Forest Zone" -100,0,-100,100,50,100
Zone created: forest_zone

> zone info forest_zone
Zone: forest_zone
  Name: Forest Zone
  Bounds:
    X: -100 to 100
    Y: 0 to 50
    Z: -100 to 100
  Entity Count: 0
  Entity Density: 0.000
  Hierarchy:
    Level: 0
    Root: false
    Parent: None
    Children: 0
  Properties:
    None
  Transitions:
    None

# Spatial queries
> spatial radius 0 10 0 50 type fire
Entities within 50 units of (0, 10, 0):
  a1b2c3d4: fire (d=25.0)

# Database operations
> db save entity a1b2c3d4
Entity saved: a1b2c3d4

> db stats
Database Statistics:
  Entity Count: 1
  Dictionary Count: 2
  Zone Count: 1
  Total Size: 10.5 KB

Cache:
  Entity Cache Size: 1
  Entity Cache Limit: 1000
  Pending Saves: 0

Operations:
  Reads: 0
  Writes: 1
  Deletes: 0

# Integrated commands
> find entity a1b2
Entity found: a1b2c3d4
Type: fire
Position: (25, 10, 0)
Zones: [forest_zone]

> stats
Entity System Statistics:
  Total Entities: 1
  Process Queue: 0
  Average Complexity: 2.50

Database Statistics:
  Entity Count: 1
  Dictionary Count: 2
  Zone Count: 1
  Total Size: 10.5 KB

Spatial System Statistics:
  Total Zones: 1
  Loaded Zones: 1
  Visible Entities: 1
  Active Zone: forest_zone
  Entity Positions: 1
  Spatial Queries: 1
  Zone Transitions: 0
```

### Entity Visualization

The entity visualizer provides an interactive graphical view of entity relationships:

- **Graph Mode**: Shows entities as nodes and their relationships as edges, with a force-directed layout that arranges related entities closer together.

- **Spatial Mode**: Displays entities based on their actual spatial positions in the world, giving a geographical view of entity distribution.

- **Hierarchy Mode**: Arranges entities in a tree structure based on their evolution stage and parent-child relationships.

### Visualization Interactions

```
# Focus on a specific entity
> visualize entity a1b2c3d4
Visualizing entity a1b2c3d4

# Focus on entities in a zone
> visualize zone forest_zone
Visualizing entities in zone forest_zone

# Change visualization mode
> visualize mode graph
Visualization mode set to: graph

> visualize mode spatial
Visualization mode set to: spatial

> visualize mode hierarchy
Visualization mode set to: hierarchy

# Adjust display options
> visualize options labels=true types=true connections=true
Visualization options updated
```

## Integration with Systems

### Entity System Integration

The UI components integrate with the entity system:

- **Command Interface**: Direct control over entity creation, modification, and deletion
- **Visualization**: Real-time visualization of entity relationships and properties
- **Event Handling**: Automatic updates based on entity system events

### Database System Integration

The UI provides tools for database interaction:

- **Command Interface**: Management of database storage and retrieval
- **Statistics Display**: Monitoring of database performance and usage
- **Backup and Optimization**: Tools for database maintenance

### Spatial System Integration

The UI supports spatial operations and visualization:

- **Command Interface**: Zone management and spatial queries
- **Spatial Visualization**: Visual representation of entity positions and zones
- **Navigation Tools**: Commands for moving and positioning entities

## Keyboard Shortcuts

The console UI supports keyboard shortcuts for efficient operation:

- **Tilde (~) or F1**: Toggle console visibility
- **Up/Down Arrows**: Navigate command history or autocomplete suggestions
- **Tab**: Complete command or argument
- **Escape**: Close autocomplete or hide console
- **Enter**: Execute command

## Entity Visualizer Controls

The entity visualizer provides interactive controls:

- **Left Mouse Button**: Select entity
- **Right Mouse Button**: Show entity details
- **Middle Mouse Button (drag)**: Pan view
- **Mouse Wheel**: Zoom in/out
- **Double Click**: Focus on entity

## Next Steps

1. **Mobile UI**: Adapt UI for mobile devices
2. **3D Visualization**: Add 3D visualization of the spatial system
3. **Real-Time Monitoring**: Add tools for monitoring system performance
4. **Custom Themes**: Add user-definable themes
5. **Command Scripting**: Support for command scripting and macros