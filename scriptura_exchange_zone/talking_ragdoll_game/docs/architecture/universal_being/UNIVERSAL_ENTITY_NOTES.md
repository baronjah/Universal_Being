# Universal Entity System - Development Notes

## Date: May 27, 2025

### Core Components Created:

1. **UniversalLoader** (`scripts/core/universal/universal_loader.gd`)
   - Manages loading of nodes with performance monitoring
   - Integrates with FloodgateController
   - Tracks loaded resources and their impact

2. **UniversalUnloader** (`scripts/core/universal/universal_unloader.gd`)
   - Handles unloading of nodes to maintain performance
   - Automatic unloading based on distance/importance
   - Memory management and cleanup

3. **UniversalFreezer** (`scripts/core/universal/universal_freezer.gd`)
   - Monitors script performance impact
   - Can disable/enable scripts dynamically
   - Maintains target framerate

4. **GlobalVarsInspector** (`scripts/core/universal/global_vars_inspector.gd`)
   - Tracks all global variables
   - Provides UI for inspecting/modifying values
   - Records variable history

5. **UniversalEntity** (`scripts/core/universal/universal_entity.gd`)
   - The core "universal being" that manages everything
   - Self-regulating system for game stability
   - Connects all components together

### Integration Points:

- All components added to autoload in project.godot
- Integration with existing systems:
  - FloodgateController
  - ConsoleManager
  - JSHSceneTree
  - AkashicRecords

### Next Steps:

1. **Lists Viewer System**
   - Create txt-based rule system
   - Allow programming via text files
   - Dynamic rule loading

2. **Performance Dashboard**
   - Real-time monitoring UI
   - Script impact visualization
   - Memory usage graphs

3. **Advanced Object Inspector**
   - Enhanced UI for object manipulation
   - Batch operations
   - Template system

4. **Console Commands**
   - Add commands for all universal systems
   - Help system
   - Command history

5. **Testing & Refinement**
   - Test freezing/unfreezing scripts
   - Verify loader/unloader balance
   - Optimize performance thresholds

### Current State:
- Core foundation established
- Autoloads configured
- Ready for testing and UI implementation

### Vision Progress:
The "universal entity" dream is taking shape - we now have a self-regulating system that can:
- Monitor and maintain performance
- Load/unload content dynamically
- Inspect and modify any game state
- Freeze problematic scripts
- Track all global variables

This creates the stable, "sane" game environment you envisioned.
