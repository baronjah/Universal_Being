# Command Quick Reference - Talking Ragdoll Game

## 🟢 Working Commands

### Object Creation
```
tree          - Spawn a tree with fruits
rock          - Spawn a rock  
box           - Spawn a physics box
ball          - Spawn a physics ball
bush          - Spawn a bush with fruits
fruit         - Spawn a fruit
pathway/path  - Spawn a pathway
astral        - Spawn flying astral being
bird          - Spawn triangular bird
sun           - Spawn light source
spawn_ragdoll - Spawn ragdoll character
```

### World & Scenes  
```
world         - Generate terrain with trees/bushes/water
scene list    - Show available scenes
load <scene>  - Load a scene (default/forest/physics_test/playground)
save [name]   - Save current scene
clear         - Remove spawned objects (not terrain)
```

### Object Management
```
list          - List all spawned objects
delete <id>   - Delete specific object
select <id>   - Select object for manipulation
move x y z    - Move selected object
rotate x y z  - Rotate selected object (degrees)
scale_obj n   - Scale selected object
```

### UI & Display
```
console <pos> - Set console position (center/top/bottom/left/right)
scale <0.5-2> - Set UI scale
debug [off]   - Toggle 3D debug screen
```

### Physics & States
```
gravity <val> - Set gravity (default 9.8, try 1 for floating)
physics       - Show physics state info
state <id> <state> - Change object state
awaken <id>   - Awaken static object
```

### System
```
setup_systems - Initialize ragdoll and mouse systems
system_status - Check all systems status
help          - Show all commands
```

## 🔴 Being Fixed (After Update)

### Ragdoll Commands
```
ragdoll_come     - Ragdoll walks to you
ragdoll_pickup   - Pick up nearest object
ragdoll_drop     - Drop held object
ragdoll_organize - Organize nearby objects  
ragdoll_patrol   - Start patrol route
walk             - Toggle walking
say <text>       - Make ragdoll speak
```

### Astral Being Commands
```
beings_status    - Show astral beings info
beings_help      - Astral beings help ragdoll
beings_organize  - Organize scene
beings_harmony   - Create environmental harmony
```

## 💡 Tips from Testing

1. **Gravity 1** - Makes ragdoll float, legs visible
2. **Multiple worlds** - Stack on each other
3. **Console remembers** - Position saved between sessions
4. **Objects track IDs** - tree_1, rock_1, etc.
5. **Floodgate queues** - Prevents crashes from spam

## 🎮 Quick Test Sequence

```bash
# Basic spawn test
tree
rock
ball
astral
list

# World generation
world
bird
list  # Should now show world objects!

# Manipulation
select tree_1
move 10 0 10
rotate 0 45 0
scale_obj 2

# Ragdoll test (after fixes)
setup_systems
spawn_ragdoll
ragdoll_come
ragdoll_pickup
```

## 🔧 Debug Info

- **Memory cleanup**: Every 5 seconds
- **Floodgate tracking**: [TRACK] messages in console
- **Object IDs**: Increment per type (tree_1, tree_2...)
- **JSH Tree**: Connected to main controller
- **Seven-part ragdoll**: Now integrated

---
*Quick tip: Press Tab to toggle console visibility*