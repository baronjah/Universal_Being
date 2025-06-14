# Priority Godot Classes for Documentation Research

## 🎯 High Priority Classes (Immediate Impact)

### 1. RigidBody3D ⭐⭐⭐⭐⭐
**Why Critical**: Core of our ragdoll system, currently causing sliding/spinning
**Key Properties to Research**:
- `gravity_scale` - Currently 0.1 (too low)
- `linear_damp` - Varies 2.0-10.0 across scripts
- `angular_damp` - Varies 5.0-20.0 across scripts
- `mass` - All set to 1.0 (needs variation)
- `freeze_rotation_x/z` - Missing in main ragdoll
- `continuous_cd` - Not set everywhere

**Key Methods to Research**:
- `apply_central_force()` - Used for movement and balance
- `apply_impulse()` - Could improve responsiveness
- `set_gravity_scale()` - For dynamic physics changes

**Our Usage Issues**:
- Lines: `talking_ragdoll.gd:25-27`, `simple_ragdoll_walker.gd:60-74`
- Problem: Inconsistent physics properties causing instability

### 2. CharacterBody3D ⭐⭐⭐⭐
**Why Critical**: Conflicts with RigidBody3D in hybrid approach
**Key Properties to Research**:
- `velocity` - Used in `seven_part_ragdoll_integration.gd:300`
- `up_direction` - Default Vector3.UP might need customization
- `floor_stop_on_slope` - Could help with stability
- `floor_max_angle` - Important for terrain walking

**Key Methods to Research**:
- `move_and_slide()` - Our main movement method
- `is_on_floor()` - Not used but could improve ground detection
- `is_on_wall()` - Could add wall collision behavior
- `get_floor_normal()` - For slope adaptation

**Our Usage Issues**:
- Line: `seven_part_ragdoll_integration.gd:8`
- Problem: Fighting with RigidBody3D physics

### 3. Joint3D (Generic6DOF & Hinge) ⭐⭐⭐⭐
**Why Critical**: No joint limits = unrealistic ragdoll movement
**Key Properties to Research**:
- Joint limits (PARAM_LIMIT_UPPER/LOWER)
- Spring stiffness (PARAM_SPRING_STIFFNESS)
- Damping (PARAM_SPRING_DAMPING)
- Break force (PARAM_BREAK_FORCE)

**Our Usage Issues**:
- Lines: `seven_part_ragdoll_integration.gd:184-219`
- Problem: Joints have no constraints, causing unrealistic movement

## 🔧 Medium Priority Classes (Quality Improvements)

### 4. PhysicsServer3D ⭐⭐⭐
**Why Important**: Direct physics queries for optimization
**Research Focus**:
- `body_get_direct_state()` - For reading physics state
- `area_create()` - For interaction zones
- `space_get_direct_state()` - For collision queries

**Potential Usage**: Physics state synchronization fix

### 5. NavigationAgent3D ⭐⭐⭐
**Why Important**: Smart pathfinding for ragdoll movement
**Research Focus**:
- `set_target_position()` - For ragdoll_come command
- `get_next_path_position()` - For smooth movement
- `navigation_finished` signal - For arrival detection

**Potential Usage**: Replace direct movement with pathfinding

### 6. Area3D ⭐⭐⭐
**Why Important**: Interaction zones and triggers
**Research Focus**:
- `body_entered/exited` signals - For proximity detection
- `gravity_space_override` - For local gravity effects
- `collision_layer/mask` - For selective interactions

**Potential Usage**: Ragdoll interaction zones, ground detection

## 🎨 Low Priority Classes (Polish & Features)

### 7. AnimationTree ⭐⭐
**Research Focus**: Blending between ragdoll and animation
**Potential Usage**: Smooth transitions between states

### 8. ConfigFile ⭐⭐
**Research Focus**: Saving physics configurations
**Potential Usage**: Persistent physics settings

### 9. PackedScene ⭐⭐
**Research Focus**: Object pooling and instantiation
**Potential Usage**: Efficient object spawning

## 📋 Class Research Checklist

When researching each class, focus on:

### For Physics Classes:
- [ ] Default property values
- [ ] Valid property ranges
- [ ] Performance implications
- [ ] Common gotchas/best practices
- [ ] Integration with other physics classes

### For Movement Classes:
- [ ] Coordinate system conventions
- [ ] Delta time usage
- [ ] Collision layer interactions
- [ ] Signal patterns

### For Joint Classes:
- [ ] Constraint types and limits
- [ ] Spring/damper configuration
- [ ] Breaking thresholds
- [ ] Performance with multiple joints

## 🔍 Specific Documentation Gaps to Fill

Based on our code analysis, research these specific topics:

1. **RigidBody3D + CharacterBody3D interaction** - Can they work together?
2. **Joint3D limits** - How to set realistic human joint constraints?
3. **Physics material** - How to add friction/bounce to ragdoll parts?
4. **Gravity override** - Local vs global gravity for special effects?
5. **Collision layers** - Best practices for complex physics objects?

## 📊 Impact vs Effort Matrix

| Class | Implementation Effort | Bug Fix Impact | Feature Impact |
|-------|---------------------|----------------|----------------|
| RigidBody3D | Low (adjust properties) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Joint3D | Medium (add limits) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| CharacterBody3D | High (refactor) | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| NavigationAgent3D | Medium (add new) | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| PhysicsServer3D | High (optimize) | ⭐⭐ | ⭐⭐ |

---

*Focus your documentation research on High Priority classes first*
*These will have the most immediate impact on fixing the ragdoll issues*