# Scene Management System Guide

## Overview

The new unified scene manager handles both static scenes (like forest) and procedural worlds properly, preventing them from stacking on top of each other.

## Commands

### Scene Management
```
world [size]      # Generate procedural terrain (64-512)
load <scene>      # Load a static scene (e.g., forest)
scene_status      # Show current scene information
clear             # Clear spawned objects only
clear all         # Clear everything including terrain
clear restore     # Restore the default flat ground
```

### Examples
```
world             # Generate default 128x128 terrain
world 256         # Generate larger 256x256 terrain
load forest       # Load the forest scene
scene_status      # Check what's loaded
clear all         # Clear everything
clear restore     # Go back to default ground
```

## How It Works

### Scene Types
1. **STATIC** - Pre-made scenes like forest
2. **PROCEDURAL** - Generated terrain with heightmaps
3. **HYBRID** - Combination of both (future feature)

### Scene Containers
- **TerrainContainer** - Holds ground/terrain
- **ObjectsContainer** - Holds spawned objects
- **CreaturesContainer** - Holds birds/characters (persist across scene changes)

### Key Features
- Prevents scene stacking - clears previous scene before loading new one
- Hides default ground when loading terrain
- Birds persist across scene changes (stay in CreaturesContainer)
- Proper height detection for procedural terrain

## Best Practices

1. **Clear before switching scenes**:
   ```
   clear all
   world
   ```

2. **Spawn birds after terrain**:
   ```
   world
   bird
   bird
   bird
   ```

3. **Check scene status**:
   ```
   scene_status
   ```

4. **Return to default**:
   ```
   clear restore
   ```

## Troubleshooting

- **Multiple terrains stacking**: Use `clear all` before generating new world
- **Birds rolling on ground**: This is progress! They're using physics properly
- **Can't see objects**: Check if terrain is too high, adjust spawn height
- **Performance issues**: Use smaller terrain size (64 or 128)