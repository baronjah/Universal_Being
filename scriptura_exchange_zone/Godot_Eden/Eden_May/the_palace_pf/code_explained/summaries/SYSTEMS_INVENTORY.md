# Eden Project - Systems Inventory

This document catalogs the major systems in the Eden project, their purpose, current state, and how they connect to other systems.

## Core Systems

### Akashic Records System
- **Location**: `/code/gdscript/scripts/core/akashic_records_manager.gd`
- **Purpose**: Manages the dictionary of all words/concepts/elements in the world
- **Key Functionality**: 
  - Word creation and retrieval
  - Properties management
  - Word interactions
  - Evolution of definitions
- **Status**: Recently integrated and standardized
- **Connected To**: Thing Creator, Universal Bridge, Zone Manager
- **Original Paths**:
  - `/code/gdscript/scripts/akashic_records/akashic_records_manager.gd`
  - `/code/gdscript/scripts/akashic_records/JSH_Akashic_Records.gd`

### Thing Creator System
- **Location**: `/code/gdscript/scripts/core/thing_creator.gd`
- **Purpose**: Instantiates entities in the 3D world from dictionary definitions
- **Key Functionality**:
  - Creating 3D representations of words
  - Managing entity properties
  - Handling entity interactions
  - Entity lifecycle management
- **Status**: Recently integrated and standardized
- **Connected To**: Akashic Records, Universal Bridge, 3D World
- **Original Paths**:
  - `/code/gdscript/scripts/akashic_records/thing_creator.gd`
  - `/code/gdscript/scripts/kamisama_home/thing_creator_standalone.gd`

### Universal Bridge System
- **Location**: `/code/gdscript/scripts/core/universal_bridge.gd`
- **Purpose**: Central hub connecting all major systems
- **Key Functionality**:
  - System discovery and initialization
  - Cross-system communication
  - API standardization
  - Signal management
- **Status**: Recently integrated and standardized
- **Connected To**: All major systems
- **Original Paths**:
  - `/code/gdscript/scripts/UniversalBridge.gd`

### Console System
- **Location**: `/code/gdscript/scripts/Menu_Keyboard_Console/JSH_console.gd`
- **Purpose**: Provides command-line interface for debugging and interaction
- **Key Functionality**:
  - Command registration and execution
  - Text output
  - Command history
  - UI for interaction
- **Status**: Needs integration with standardized systems
- **Connected To**: Many systems for command registration
- **Notes**: Part of a larger Menu/Keyboard/Console system with multiple components

## Domain Systems

### Space System
- **Location**: `/code/gdscript/scripts/Galaxy_Star_Planet/`
- **Purpose**: Generates and manages celestial bodies and space
- **Key Components**:
  - `Galaxies.gd`: Galaxy generation and management
  - `Star.gd`: Star simulation
  - `CelestialPlanet.gd`: Planet generation and properties
  - `GalaxyCloseUp.gd`: Detailed visualization
- **Status**: Needs integration with standardized systems
- **Connected To**: Camera system, Element system
- **Notes**: Uses shader-based generation for many celestial bodies

### World Grid System
- **Location**: `/code/gdscript/scripts/Domino_Grid_Chunks/`
- **Purpose**: Manages the world map, zones, and entity placement
- **Key Components**:
  - `world_grid.gd`: Main grid management
  - `world_database.gd`: Storage for world data
  - `entity.gd`: Entity base class
  - `ripple_system.gd`: Effect propagation
- **Status**: Needs integration with standardized systems
- **Connected To**: Entity system, Zone management
- **Notes**: Uses a domino-effect system for propagating changes

### Element System
- **Location**: `/code/gdscript/scripts/elements_shapes_projection/`
- **Purpose**: Handles the combining of elements and shape generation
- **Key Components**: (Need detailed exploration)
- **Status**: Needs integration with standardized systems
- **Connected To**: Thing Creator, Akashic Records
- **Notes**: Focuses on combining points to generate shapes

### Dungeons System
- **Location**: `/code/gdscript/scripts/Dungeons/`
- **Purpose**: Generates dungeons, puzzles, and encounters
- **Key Components**:
  - `dungeons.gd`: Main dungeon generator
  - `path_finder.gd`: Pathfinding for dungeon layout
  - `evolution_zone.gd`: Dynamic dungeon evolution
- **Status**: Needs integration with standardized systems
- **Connected To**: World Grid, Thing Creator
- **Notes**: Also contains some file storage and website connection functionality

## Integration Systems

### Thread Pool System
- **Location**: `/code/gdscript/scripts/Menu_Keyboard_Console/jsh_thread_pool_manager.gd`
- **Purpose**: Manages threads for concurrent operations
- **Key Functionality**: 
  - Thread creation and management
  - Task distribution
  - Result collection
  - Error handling
- **Status**: Needs integration with standardized systems
- **Connected To**: Various performance-critical systems
- **Notes**: Critical for performance optimization

### Database System
- **Location**: `/code/gdscript/scripts/Menu_Keyboard_Console/jsh_database_system.gd`
- **Purpose**: Provides database functionality for various systems
- **Key Functionality**:
  - Data storage and retrieval
  - Query handling
  - Data transformation
  - Persistence management
- **Status**: Needs integration with standardized systems
- **Connected To**: Akashic Records, World Database
- **Notes**: May overlap with some Akashic Records functionality

### Task Manager
- **Location**: `/code/gdscript/scripts/Menu_Keyboard_Console/jsh_task_manager.gd`
- **Purpose**: Manages scheduled tasks and operations
- **Key Functionality**:
  - Task scheduling
  - Priority management
  - Task execution
  - Dependency handling
- **Status**: Needs integration with standardized systems
- **Connected To**: Thread Pool, Various systems needing task scheduling
- **Notes**: Important for coordinating complex operations

## UI Systems

### Menu System
- **Location**: `/code/gdscript/scripts/Menu_Keyboard_Console/`
- **Purpose**: Provides user interface for game interaction
- **Key Components**: (Multiple files, need detailed exploration)
- **Status**: Needs integration with standardized systems
- **Connected To**: Console, various UI components
- **Notes**: Contains various UI elements for different game aspects

### Thing Creator UI
- **Location**: `/code/gdscript/scripts/ui/thing_creator_ui.gd`
- **Purpose**: UI for creating and managing things
- **Key Functionality**:
  - Word selection
  - Property editing
  - Entity visualization
  - Creation controls
- **Status**: Recently integrated and standardized
- **Connected To**: Thing Creator, Akashic Records
- **Original Paths**:
  - `/code/gdscript/scripts/akashic_records/thing_creator_ui.gd`

### Akashic Records UI
- **Location**: `/code/gdscript/scripts/ui/akashic_records_ui.gd`
- **Purpose**: UI for viewing and editing the dictionary
- **Key Functionality**:
  - Word browsing
  - Property editing
  - Interaction testing
  - Word creation
- **Status**: Recently integrated and standardized
- **Connected To**: Akashic Records
- **Original Paths**:
  - `/code/gdscript/scripts/akashic_records/akashic_records_ui.gd`

## Other Systems

### Archive System
- **Location**: `/code/gdscript/scripts/Archive_Past_Text/`
- **Purpose**: Archive of past states and historical data
- **Key Components**:
  - `archive_of_past.gd`: Main archive management
- **Status**: Needs exploration and possibly integration
- **Connected To**: Various systems for archival
- **Notes**: Contains "ancient knowledge" not currently used

### Camera System
- **Location**: Multiple locations
- **Purpose**: Camera management and movement
- **Key Components**:
  - `/code/gdscript/scripts/Archive_Past_Text/camera_move.gd`
  - `/addons/goutte.camera.trackball/trackball_camera.gd`
- **Status**: Needs standardization and integration
- **Connected To**: Various visualization systems
- **Notes**: Multiple camera implementations for different purposes

### VR System
- **Location**: `/code/gdscript/scripts/vr_system/`
- **Purpose**: Virtual reality support
- **Key Components**: (Need detailed exploration)
- **Status**: New system, needs integration
- **Connected To**: Camera, Input systems
- **Notes**: For future VR support

## Integration Notes

1. **Duplicate Functionality**: Several systems appear to overlap in functionality:
   - Multiple database implementations
   - Multiple camera controllers
   - Multiple entity management systems

2. **Naming Inconsistencies**: 
   - Some use "JSH_" prefix, others don't
   - Inconsistent naming for similar concepts
   - Need to standardize on convention

3. **Directory Structure**:
   - Some systems grouped by function
   - Others grouped by domain
   - Need to decide on consistent organization

4. **Scene Structure**:
   - Multiple scenes with different node structures
   - Need to standardize scene composition
   - Decide on scene hierarchy

5. **Legacy Components**:
   - Some components may be outdated or experimental
   - Need to evaluate which to maintain vs. replace

## Next Steps

1. **Core System Connections**: 
   - Connect JSH_console to Universal Bridge
   - Update scene tree references to use new paths
   - Standardize API patterns across core systems

2. **Main Scene Structure**:
   - Update main scene to use integrated components
   - Connect existing nodes to new scripts
   - Ensure backward compatibility

3. **Integration Tests**:
   - Create tests for key system connections
   - Verify functionality after each integration
   - Document integration points

4. **Documentation**:
   - Update documentation for each integrated system
   - Create usage examples
   - Document API changes