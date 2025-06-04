# Debug System Architecture

## Why Autoloads?

The debug system uses autoloads (singletons) for two critical components:

### 1. **LogicConnector** (Singleton)
- **Purpose**: Central registry for ALL debuggable objects in the game
- **Why Autoload**: Needs to be globally accessible from any script
- **What it does**:
  - Maintains registry of debuggable objects
  - Provides raypicking to find objects under cursor
  - Must exist before any debuggable objects are created

### 2. **DebugOverlay** (UI Scene Singleton)
- **Purpose**: The debug panel UI that appears when pressing F4
- **Why Autoload**: 
  - Needs to render on top of everything
  - Must be accessible from anywhere
  - Should persist across scene changes
- **What it does**:
  - Shows property tree for selected object
  - Handles live editing
  - Provides action buttons

## The Flow:

1. **Game Starts** → Autoloads are created first
2. **Chunk Created** → Registers with LogicConnector in `pentagon_ready()`
3. **Player Presses F4** → DebugOverlay asks LogicConnector what's under cursor
4. **Object Found** → DebugOverlay shows its debug payload
5. **Edit/Action** → Changes applied directly to the object

## Important: Pentagon Architecture + Autoloads

ChunkUniversalBeing IS a UniversalBeing at its core! The debug system just adds a layer on top:

```
UniversalBeing (base)
    ↓
ChunkUniversalBeing (extends)
    ↓
Implements Debuggable methods
    ↓
Registers with LogicConnector (autoload)
    ↓
Can be inspected by DebugOverlay (autoload)
```

The autoloads don't replace Pentagon architecture - they complement it by providing global services that any being can use.
