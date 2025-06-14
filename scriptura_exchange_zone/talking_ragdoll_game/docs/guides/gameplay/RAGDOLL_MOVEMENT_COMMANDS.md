# Ragdoll Movement Commands Guide

## Setup Commands
```bash
setup_systems    # Initialize all systems
spawn_ragdoll    # Spawn the ragdoll
```

## Movement Commands

### Basic Movement
```bash
ragdoll_move forward    # Walk forward
ragdoll_move backward   # Walk backward
ragdoll_move left       # Strafe left
ragdoll_move right      # Strafe right
ragdoll_move stop       # Stop moving
```

### Speed Control
```bash
ragdoll_speed slow      # Slow walk mode
ragdoll_speed normal    # Normal walk mode (default)
ragdoll_speed fast      # Fast walk mode
```

### Advanced Movement
```bash
ragdoll_run             # Toggle running
ragdoll_crouch          # Toggle crouch
ragdoll_jump            # Jump
ragdoll_rotate left     # Rotate in place left
ragdoll_rotate right    # Rotate in place right
```

### State Commands
```bash
ragdoll_stand           # Stand up from any position
ragdoll_state           # Show current movement state
```

### Debug Commands
```bash
ragdoll_debug on        # Enable debug visualization
ragdoll_debug off       # Disable debug visualization
Tab                     # Show physics debug info
```

## Movement States

The ragdoll can be in these states:
- **IDLE** - Standing still
- **WALKING** - Normal walking
- **RUNNING** - Fast movement
- **CROUCHING** - Low stance
- **CROUCH_WALKING** - Moving while crouched
- **STRAFING** - Sideways movement
- **ROTATING** - Turning in place
- **JUMPING** - In the air (jump)
- **FALLING** - In the air (falling)
- **LANDING** - Just hit ground

## Examples

### Make ragdoll walk to you:
```bash
ragdoll_come
```

### Complex movement sequence:
```bash
ragdoll_speed fast
ragdoll_move forward
ragdoll_jump
ragdoll_crouch
ragdoll_move left
```

### Debug physics:
```bash
Tab                    # Quick physics info
ragdoll_debug on all   # Full debug visualization
```