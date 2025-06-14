# Akashic Notepad 3D Test Project

This is a test integration of the Akashic Records and Notepad3D systems from the 12_turns_system project.

## Overview

This project integrates several key components with **full Eden Pitopia Integration support**:

1. **SpatialWorldStorage** - Manages 3D notebooks and akashic records
2. **Notepad3DVisualizer** - Handles 3D visualization of words, connections, and dimensional transitions
3. **SpatialNotepadIntegration** - Connects storage with visualization
4. **AkashicNotepadController** - Coordinates the entire system
5. **WordManifestationSystem** - Handles word physics and manifestation
6. **🔗 EdenPitopiaBridge** - **NEW!** Connects to the full Eden Pitopia Integration system

## 🌟 Eden Integration Features

When the Eden integration is detected, you get access to:
- ✅ **6 Reality Types** (Physical, Digital, Astral, Quantum, Memory, Dream)
- ✅ **12 Dimensions** with Greek symbols (α-μ)
- ✅ **8 Moon Phases** affecting gate stability and word power
- ✅ **Cyber Gates** for reality transitions
- ✅ **Data Sewers** for efficient storage
- ✅ **Advanced Command System** with 15+ commands
- ✅ **Reality-specific Effects** and visualizations

## How to Test

### In Godot Editor:
1. Open the project in Godot 4.x
2. Run the main scene (`scenes/main_test_scene.tscn`)
3. Click the "Run Test" button to execute integration tests
4. Use keyboard controls to navigate the 3D space

### Keyboard Controls:
- **WASD** - Move camera
- **Q/E** - Move up/down
- **Right-click + drag** - Rotate camera  
- **Mouse wheel** - Zoom
- **R** - Reset camera
- **T** - Run tests
- **C** - Clear all data
- **V** - Toggle visualization mode
- **E** - Show Eden integration status

### Test Sequence:
1. **Create Akashic Entries** - Creates sample akashic records with different dimensions and tags
2. **Create Notepad** - Creates a test notepad with sample cells
3. **Visualize Akashic Records** - Displays akashic entries in 3D space
4. **Create Connections** - Links related akashic entries
5. **Notepad Integration** - Displays notepad cells in 3D

## Features Tested

### Akashic Records:
- Creating entries with position, dimension, and tags
- Finding entries by dimension and tags
- Creating connections between entries
- Spatial synergy detection
- 3D visualization of entries

### Notepad3D:
- Creating notebooks with cells
- Positioning cells in 3D space
- Visualizing notebooks in 3D
- Converting akashic entries to notebook cells

### Integration:
- Bridge between storage and visualization
- Real-time updates of 3D representations
- Interactive 3D interface
- Multi-dimensional coordinate system

## System Architecture

```
AkashicNotepadController
├── SpatialWorldStorage (data management)
├── SpatialNotepadIntegration (bridge)
├── 🔗 EdenPitopiaBridge (Eden connection)
│   ├── Reality System (6 types)
│   ├── Dimension System (12 dimensions)
│   ├── Moon Phase System (8 phases)
│   ├── Cyber Gates (reality transitions)
│   └── Data Sewers (storage management)
└── Notepad3DVisualizer (3D rendering)
    ├── WordManifestationSystem (physics)
    └── Camera/Lighting/Environment
```

## 🚀 Eden Commands (when connected)

- `/reality [type]` - Switch between reality types
- `/gate [target]` - Create cyber gate to another reality
- `/sewer` - Create data sewer for storage
- `/moon [phase]` - Set moon phase (affects stability)
- `/eden-status` - Show Eden integration status
- `/word-power [word]` - Calculate divine word power
- `/note [text]` - Manifest word in 3D space
- `/memory [tier] [text]` - Store memory in tier system
- `/connect [word1] to [word2]` - Connect manifested words

## File Structure

- `scripts/spatial_world_storage.gd` - Core data storage system
- `scripts/notepad3d_visualizer.gd` - 3D visualization engine
- `scripts/spatial_notepad_integration.gd` - Integration bridge
- `scripts/akashic_notepad_controller.gd` - Main controller
- `scripts/word_manifestation_system.gd` - Word physics system
- `scripts/akashic_test_main.gd` - Test orchestration
- `scripts/eden_pitopia_bridge.gd` - **NEW!** Eden integration bridge
- `scenes/main_test_scene.tscn` - Main test scene

## Expected Results

When tests run successfully, you should see:
- Console output showing test progress
- 3D words and connections appearing in the viewport
- Status updates showing record/cell counts
- Interactive 3D navigation working

## Notes

This is a simplified test version focusing on core integration. The full system includes:
- File persistence
- Multi-dimensional physics
- Advanced word evolution
- Reality transitions
- Turn-based cosmic cycles

To integrate into your main project, copy the working components and adapt the initialization sequence to match your project structure.

## Troubleshooting

If tests fail:
1. Check console output for error messages
2. Verify all script files are properly loaded
3. Ensure scene node structure matches script expectations
4. Try running individual test steps manually

For the full system experience, see the original files in the `12_turns_system` directory.