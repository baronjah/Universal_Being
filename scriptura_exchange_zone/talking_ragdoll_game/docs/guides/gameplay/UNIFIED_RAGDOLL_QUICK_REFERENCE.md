# 🎯 Unified Ragdoll Quick Reference

> Everything you need to know about the consolidated ragdoll system

## 🚀 Quick Start

### Test the System
```bash
# In console (Tab or F1)
interactive_tutorial    # Button-based testing
test_ragdolls          # Alternative command
```

### Basic Commands
```bash
spawn                  # Create ragdoll at origin
spawn_at_camera       # Create in front of view
walker                # Create walking ragdoll
clear                 # Remove all ragdolls
```

## 📁 Active Files (The Ones That Matter)

### Core System
- `scripts/core/seven_part_ragdoll_integration.gd` - Main controller
- `scripts/core/simple_ragdoll_walker.gd` - Movement system
- `scripts/core/ragdoll_controller.gd` - High-level behavior

### UI & Testing
- `scripts/ui/interactive_tutorial_system.gd` - Button-based testing
- `scripts/autoload/console_manager.gd` - Console commands

### Scenes
- `scenes/ragdolls/seven_part_ragdoll.tscn` - Main ragdoll scene

## 🔧 Floodgate Understanding

The floodgate system controls creation flow:

```
User Input → Console Command → Floodgate Queue → Ragdoll Creation
     ↓              ↓                ↓                  ↓
   "spawn"    Parse & Route    Queue Action      Instantiate
```

### Floodgate Queues
- **creation_queue**: New ragdoll requests
- **movement_queue**: Movement commands
- **interaction_queue**: Dialogue/actions
- **deletion_queue**: Cleanup requests

## 🎮 Console Command Flow

### How Commands Work
1. User types command in console
2. ConsoleManager routes to function
3. Function interacts with floodgate
4. Floodgate processes in next frame
5. Ragdoll appears/acts in scene

### Command Categories
- **Creation**: spawn, walker, puppet
- **Control**: select_ragdoll, walker_speed
- **Interaction**: say, wave, dance
- **Management**: list_ragdolls, clear

## 🏗️ Architecture Summary

```
ConsoleManager (UI Layer)
      ↓
FloodgateController (Queue Management)
      ↓
SevenPartRagdollIntegration (Main Logic)
      ↓
SimpleRagdollWalker (Movement Physics)
```

## ⚡ Performance Notes

### What's Running
- Only spawned ragdolls have active _process()
- Background process manager limits per-frame updates
- Debug visualization off by default

### Optimization Tips
- Spawn only needed ragdolls
- Use `clear` to remove unused ones
- Toggle debug only when needed

## 🐛 Common Issues & Fixes

### Ragdoll Won't Spawn
- Check console for errors
- Verify ground exists: `restore_ground`
- Try `setup_systems` first

### Ragdoll Falls Through Ground
- Collision layers may be wrong
- Ground might be hidden
- Try spawning higher: `spawn 0 5 0`

### Console Commands Not Working
- Press Tab or F1 to open console
- Check command spelling
- Some commands need parameters

## 📊 Testing Workflow

1. **Start Interactive Tutorial**
   ```
   interactive_tutorial
   ```

2. **Test Each Feature**
   - Click command buttons
   - Click ✅ if it worked
   - Click ❌ if it failed

3. **Results Saved Automatically**
   - Check `user://tutorial_results_*.json`
   - Summary shown in UI

## 🔮 Future Unified System

### Planned Consolidation
```gdscript
# One ragdoll class to rule them all
class_name UnifiedRagdoll extends SevenPartRagdoll

# Modular features
@export var enable_bio_feet: bool = false
@export var enable_speed_modes: bool = false  
@export var enable_dimensional: bool = false
```

### Unified Commands
```
spawn --bio      # Biomechanical feet
spawn --fast     # Speed mode enabled
spawn --all      # Everything enabled
```

---

*"One system, properly documented, infinitely extensible"*
*Last Updated: 2025-05-27*