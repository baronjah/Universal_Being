# Biomechanical Walker System

## Overview
Advanced bipedal walking system with anatomically correct feet and realistic gait cycle simulation.

## Features

### Anatomical Foot Structure
Each foot consists of three segments:
- **Heel** (calcaneus) - First contact point
- **Main Foot** (metatarsals) - Weight bearing
- **Toes** (phalanges) - Push-off power

### Realistic Joint System
- **Hip Joint**: Ball joint with realistic flexion/extension limits
- **Knee Joint**: Hinge joint that only bends backward (0-135°)
- **Ankle Joint**: Complex joint allowing dorsiflexion/plantarflexion (-30° to +20°)
- **Midfoot Joint**: Slight flexibility for natural foot roll
- **Toe Joint**: Flexion for push-off phase (-45° to +30°)

### 8-Phase Gait Cycle

#### Stance Phase (60% of cycle)
1. **Heel Strike** - Initial ground contact
2. **Foot Flat** - Loading response, shock absorption
3. **Midstance** - Full weight bearing
4. **Heel Off** - Heel lifts, weight shifts forward
5. **Toe Off** - Final push-off

#### Swing Phase (40% of cycle)
6. **Initial Swing** - Foot leaves ground, knee flexes
7. **Mid Swing** - Leg swings forward
8. **Terminal Swing** - Preparation for next heel strike

### Visual Debug System
- **Phase Labels**: Floating text showing current gait phase
- **Contact Points**: Green/red indicators for ground contact
- **Force Vectors**: Visualize forces during each phase
- **Gait Timeline**: Progress bars showing cycle completion

## Console Commands

### Basic Commands
```
spawn_biowalker [x] [y] [z]    # Spawn walker at position
walker_speed [value]           # Set walking speed
walker_phase                   # Show current gait phases
walker_freeze [on/off]         # Freeze physics
walker_teleport [x] [y] [z]    # Move walker
```

### Debug Visualization
```
walker_debug labels            # Toggle phase labels
walker_debug contacts          # Toggle contact points
walker_debug forces            # Toggle force vectors
walker_debug timeline          # Toggle gait timeline
walker_debug all on            # Enable all visualization
```

### Parameter Tuning
```
walker_params step_length [value]    # Distance per step
walker_params step_height [value]    # Foot lift height
walker_params stance_time [value]    # Stance phase duration
walker_params swing_time [value]     # Swing phase duration
```

## Integration with Layer Reality System

The walker integrates with our layer system:
- **Layer 0 (Text)**: Shows gait phase in console
- **Layer 1 (2D Map)**: Top-down footprint tracking
- **Layer 2 (Debug)**: Full biomechanical visualization
- **Layer 3 (Full 3D)**: Realistic character model

## Usage Example

1. Start the game
2. Press Tab to open console
3. Type: `spawn_biowalker`
4. Type: `walker_debug all on`
5. Press F3 to show debug layer
6. Watch the realistic walking cycle!

## Technical Details

### Physics Configuration
- Each body part has appropriate mass distribution
- Continuous collision detection enabled
- Custom damping for stability
- Contact monitoring for ground detection

### Force Application
Forces are applied based on gait phase:
- **Heel Strike**: Shock absorption forces
- **Midstance**: Vertical support forces
- **Toe Off**: Forward propulsion forces
- **Swing Phase**: Hip flexion and knee clearance

### Balance System
- Tracks center of mass
- Applies corrective torques to pelvis
- Maintains stability during walking

## Future Enhancements

1. **Terrain Adaptation**: Adjust gait for slopes/stairs
2. **Speed Variations**: Run, jog, sprint gaits
3. **Turn Mechanics**: Realistic turning with lean
4. **Pathological Gaits**: Limp, shuffle, etc.
5. **Energy Efficiency**: Optimize for minimal effort
6. **Footstep Sounds**: Audio based on surface type

## Code Structure

```
scripts/ragdoll/
├── biomechanical_walker.gd         # Core walker physics
├── gait_phase_visualizer.gd        # Debug visualization
└── patches/
    └── biomechanical_walker_commands.gd  # Console commands
```

---
*"Walking is just controlled falling with style"*