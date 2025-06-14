# TALKING RAGDOLL GAME - PROJECT SUMMARY

## Current State (What We Have)

### Core Systems:
1. **Console System** (Tab key)
   - Commands: spawn objects, load/save scenes, control physics
   - UI scaling and positioning
   
2. **Object Spawning System**
   - Current objects: tree, rock, box, ball, ramp, ragdoll
   - Objects spawn at mouse position or specified coordinates
   - WorldBuilder handles creation

3. **Scene Loading System**
   - Loads from text files (user://scenes/*.scene.txt)
   - Format: `object_type x y z [properties]`
   - Example scenes: playground, forest, physics_test

4. **Ragdoll Evolution** (May 26 Update)
   - Seven-part physics ragdoll (working)
   - Skeleton-based hybrid system (prototype)
   - Advanced being system design (planned)
   - Multiple evolution paths identified

5. **Dialogue System**
   - Shows floating text that fades out
   - Ragdoll talks based on context

### Issues Discovered:
- Ragdoll implementation changed multiple times (talking_ragdoll -> ragdoll_with_legs -> stable_ragdoll -> complete_ragdoll -> simple_walking_ragdoll)
- Ragdoll spawning is inconsistent (sometimes in scene, sometimes needs command)
- Physics too wild initially, now maybe too stiff
- Special treatment of ragdoll vs other objects

## What We Need (Standardization)

### 1. Unified Object System
All objects should work the same way:
```
- tree
- rock  
- box
- ball
- ramp
- ragdoll (character)
- sun (light source)
- astral_being (moving light point)
- pathway
- bush
- fruit
```

### 2. Object Properties
Each object can have:
- Position (x, y, z)
- Rotation
- Scale
- Actions (walk, glow, follow, patrol, etc.)
- Dialogue (for talking objects)

### 3. Scene Layers (from yesterday's project)
1. Ground/Terrain layer
2. Static objects layer (trees, rocks)
3. Interactive objects layer (boxes, balls)
4. Characters layer (ragdolls, beings)
5. Effects layer (lights, particles)

### 4. Actions System
Objects can have behaviors:
- ragdoll: walk, talk, fall
- astral_being: float, follow, illuminate
- sun: rise, set, change_color
- fruit: grow, fall, respawn

## Next Steps:
1. Consolidate all ragdoll implementations into one standard object
2. Add new object types (sun, astral_being, etc.)
3. Implement action system for scene files
4. Create zone/area system for organizing larger worlds
5. Database for tracking all objects and their properties