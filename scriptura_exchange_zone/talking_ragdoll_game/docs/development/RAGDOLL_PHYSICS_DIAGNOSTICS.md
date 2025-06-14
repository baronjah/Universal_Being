# Ragdoll Physics Diagnostics

## Current Issues & Solutions

### Issue 1: Ragdoll Sliding and Spinning
**Symptoms**: When using `ragdoll_come` command, the ragdoll moves but slides on the ground and spins

**Root Causes Identified**:
1. Low gravity scale (0.1) making ragdoll too floaty
2. No rotation constraints on body parts
3. Movement forces applied without proper balance control
4. Joints might be too loose

**Applied Fixes**:
1. Created `SimpleRagdollWalker` with rotation locking
2. Added high damping values (linear: 10.0, angular: 20.0)
3. Implemented upright position maintenance
4. Added continuous collision detection

### Issue 2: Physics State Not Syncing
**Symptoms**: `set_gravity 0.5` command doesn't affect ragdoll behavior

**Root Cause**: No connection between ProjectSettings physics and individual RigidBody3D instances

**Solution Needed**:
```gdscript
# PhysicsStateManager singleton
func _ready():
    # Monitor physics changes
    ProjectSettings.settings_changed.connect(_on_settings_changed)

func _on_settings_changed():
    var new_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
    for body in get_tree().get_nodes_in_group("rigid_bodies"):
        body.gravity_scale = new_gravity / 9.8  # Normalize
```

### Issue 3: Ragdoll Structure Complexity
**Current State**: Multiple overlapping ragdoll implementations
- `talking_ragdoll.gd` - Original basic ragdoll
- `ragdoll_controller.gd` - Command handler
- `seven_part_ragdoll_integration.gd` - Advanced 7-part system
- `simple_ragdoll_walker.gd` - Movement controller

**Recommended Architecture**:
```
BaseRagdoll (abstract)
├── TalkingRagdoll (simple version)
└── SevenPartRagdoll (advanced version)
    └── SimpleWalker (movement component)
```

## Physics Properties Analysis

### Current Settings (from code inspection):

| Property | Current Value | Recommended | Notes |
|----------|--------------|-------------|--------|
| gravity_scale | 0.1 | 0.5-0.8 | Too low causes floating |
| linear_damp | 2.0-10.0 | 5.0 | Varies by implementation |
| angular_damp | 5.0-20.0 | 10.0 | High values prevent spinning |
| mass | 1.0 | 5.0-10.0 | More mass = more stability |
| lock_rotation | false→true | true | Essential for upright walking |
| continuous_cd | false→true | true | Prevents tunneling |

### Joint Configuration Issues:

1. **Generic6DOFJoint3D** - Very flexible, might be too loose
2. **HingeJoint3D** - Used for knees/elbows, good choice
3. Missing joint limits configuration

## Testing Commands & Expected Results

### Movement Tests:
```
spawn_ragdoll
# Expected: Ragdoll spawns standing upright

ragdoll_come
# Expected: Walks smoothly without falling
# Actual: Slides and spins

ragdoll_stop
# Expected: Stops and remains standing
# Actual: Unknown (not tested due to sliding issue)
```

### Physics Tests:
```
set_gravity 0.5
# Expected: Ragdoll becomes lighter, jumps higher
# Actual: No visible change

status
# Expected: Shows current gravity value
# Actual: Shows default gravity
```

## Debug Information Needed

To properly diagnose, we need:
1. Real-time physics body state display
2. Joint stress visualization
3. Force vector display
4. Center of mass indicator

## Immediate Action Items

1. **Fix Walker Integration** ✓
   - Updated to use metadata for body parts
   - Properly finds nested RigidBody3D nodes

2. **Adjust Physics Properties**
   - Increase gravity_scale to 0.5-0.8
   - Set proper mass (5-10 kg)
   - Configure joint limits

3. **Create Debug Overlay**
   - Show active forces
   - Display body part states
   - Monitor joint angles

## Code Snippets for Testing

### Quick Physics Test:
```gdscript
# Add to ragdoll_controller.gd
func debug_physics():
    var ragdoll = get_tree().get_first_node_in_group("ragdoll")
    if ragdoll and ragdoll.has_node("pelvis"):
        var pelvis = ragdoll.get_node("pelvis")
        print("Pelvis state:")
        print("  Position: ", pelvis.global_position)
        print("  Rotation: ", pelvis.rotation_degrees)
        print("  Linear vel: ", pelvis.linear_velocity)
        print("  Angular vel: ", pelvis.angular_velocity)
        print("  Gravity scale: ", pelvis.gravity_scale)
```

### Force Visualization:
```gdscript
# Add to SimpleRagdollWalker
func _draw():
    if pelvis:
        # Draw upward force
        draw_line(Vector3.ZERO, Vector3.UP * upright_force * 0.1, Color.GREEN, 2.0)
        # Draw movement force
        draw_line(Vector3.ZERO, move_direction * 2.0, Color.BLUE, 2.0)
```

---

*Last Updated: 2025-05-25*
*Next: Test with updated walker integration*