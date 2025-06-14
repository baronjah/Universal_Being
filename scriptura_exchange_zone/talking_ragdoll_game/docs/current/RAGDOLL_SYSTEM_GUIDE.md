# 🎮 Talking Ragdoll Game - System Guide
## Last Updated: May 25, 2025

### 🤖 Current Ragdoll System: Seven-Part Physics Ragdoll

#### Overview
We've evolved from a simple single-body ragdoll to a sophisticated 7-part physics-based bipedal character with realistic joints and walking capabilities.

### 📁 Project Structure

#### Active Files (Current System)
```
scripts/
├── core/
│   ├── seven_part_ragdoll_integration.gd  # Main ragdoll implementation (740+ lines)
│   ├── simple_ragdoll_walker.gd          # Walking state machine & physics
│   └── standardized_objects.gd           # Object spawning system (uses new ragdoll)
├── debug/
│   └── ragdoll_debug_visualizer.gd       # Physics visualization system
└── autoload/
    ├── console_manager.gd                 # Console commands for ragdoll control
    └── world_builder.gd                   # Spawning system
```

#### Archived Files (Old Implementations)
```
scripts/old_implementations/
├── simple_walking_ragdoll.gd     # Original simple ragdoll
├── talking_ragdoll.gd            # Basic talking version
├── stable_ragdoll.gd             # Attempted stable version
├── complete_ragdoll.gd           # Feature-complete attempt
└── ragdoll_with_legs.gd         # First leg implementation
```

### 🎯 Ragdoll Components

#### Physical Structure
1. **Pelvis** (Root) - BoxShape3D (0.4 x 0.2 x 0.2m)
2. **Left/Right Thighs** - CapsuleShape3D (radius: 0.08m, height: 0.4m)
3. **Left/Right Shins** - CapsuleShape3D (radius: 0.06m, height: 0.35m)
4. **Left/Right Feet** - BoxShape3D (0.08 x 0.05 x 0.15m)

#### Joint System
- **Hip Joints**: Generic6DOFJoint3D (pelvis → thighs)
  - Forward/back: ±45°
  - Side: ±30°
  - Twist: ±22.5°
- **Knee Joints**: HingeJoint3D (thighs → shins)
  - Range: 0° to -90° (no backward bend)
- **Ankle Joints**: HingeJoint3D (shins → feet)
  - Range: +30° to -45°

#### Physics Properties
- Mass: 2kg per body part
- Gravity Scale: 1.0
- Linear Damping: 0.5
- Angular Damping: 2.0

### 🎮 Console Commands

#### Basic Commands
```bash
spawn_ragdoll              # Create a new 7-part ragdoll
walk                       # Toggle walking on/off
say <text>                 # Make ragdoll speak
ragdoll reset             # Reset position to (0, 5, 0)
ragdoll position          # Show current position
```

#### Movement Commands
```bash
ragdoll walk <x> <y> <z>   # Walk to specific position
ragdoll stop              # Stop all movement
ragdoll come              # Come to player position
ragdoll waypoint <x> <y> <z>  # Add waypoint to path
ragdoll patrol <points...>    # Set patrol route
```

#### Debug Commands
```bash
ragdoll_debug on          # Enable physics visualization
ragdoll_debug off         # Disable visualization
ragdoll_debug toggle com  # Toggle center of mass display
ragdoll_status           # Show detailed status
```

### 🚀 Quick Test Sequence

1. **Launch Game**
   - Press Tab to open console
   - Check for errors in Godot console

2. **Spawn Ragdoll**
   ```
   spawn_ragdoll
   ```
   - Ragdoll should appear standing at clicked position
   - Should fall and land on ground

3. **Test Walking**
   ```
   walk
   ```
   - Ragdoll should attempt to stand up
   - May struggle with balance initially

4. **Test Movement**
   ```
   ragdoll walk 5 0 5
   ```
   - Should attempt to walk to position

5. **Enable Debug**
   ```
   ragdoll_debug on
   ```
   - Shows joints, forces, and balance info

### ⚠️ Known Issues

1. **Balance Tuning**: Ragdoll may fall over easily - balance parameters need adjustment
2. **Console Spam**: JSH Scene Tree system logs every node change
3. **Walking Stability**: Step cycle needs refinement for smoother movement
4. **Tab Key**: Sometimes requires multiple presses to open console

### 🔧 Common Fixes

#### If ragdoll won't spawn:
- Check Godot console for parse errors
- Ensure seven_part_ragdoll_integration.gd has no syntax errors
- Verify all body parts are creating properly

#### If walking doesn't work:
- Make sure ragdoll is in "ragdolls" group (not "ragdoll")
- Check that simple_ragdoll_walker.gd is loading
- Try `ragdoll reset` first to ensure good starting position

#### If console commands fail:
- Ensure ragdoll was spawned first
- Check exact command syntax (some use underscore, some don't)
- Look for "Ragdoll controller not found" errors

### 📊 System Architecture

```
seven_part_ragdoll_integration.gd
├── Body Creation (_setup_seven_part_body)
├── Joint System (_create_joints)
├── Walking Controller (simple_ragdoll_walker.gd)
├── Dialogue System (state-based responses)
├── Console Commands (handle_console_command)
└── Integration Points
    ├── Floodgate System
    ├── JSH Framework
    └── World Builder
```

### 🎯 Next Development Steps

1. **Balance Improvements**
   - Tune PD controller gains
   - Adjust center of mass calculations
   - Improve foot placement logic

2. **Animation System**
   - Add arm bones (currently just legs)
   - Implement grabbing/carrying
   - Create gesture system

3. **AI Integration**
   - Path planning for navigation
   - Obstacle avoidance
   - Interactive behaviors

4. **Performance**
   - Reduce console spam
   - Optimize physics calculations
   - Add LOD system for distant ragdolls

### 💡 Tips for Development

1. **Testing Physics**: Always use `ragdoll_debug on` when tuning parameters
2. **Console Usage**: Press Tab once and wait - double-tap sometimes causes issues
3. **Spawning**: Click on ground for best results - spawning in air works but less stable
4. **Multiple Ragdolls**: System supports multiple but performance may degrade

---

## Quick Reference Card

```bash
# Essential Commands
spawn_ragdoll         # Create ragdoll
walk                  # Start walking
say Hello!           # Make it talk
ragdoll_debug on     # See physics

# Testing Sequence
spawn_ragdoll
walk
ragdoll walk 3 0 3
say I'm walking!
ragdoll_debug on
```

Remember: The ragdoll is a complex physics simulation - some instability is expected and part of the charm!