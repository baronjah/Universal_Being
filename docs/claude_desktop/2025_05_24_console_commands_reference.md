# 🎮 Console Commands Quick Reference - Ragdoll Garden

## 🚀 Quick Start Commands

### Essential Commands to Try First:
```bash
help                # Show all available commands
tree                # Create a tree at mouse position
ragdoll_come        # Make ragdoll come to you
ragdoll_pickup      # Ragdoll picks up nearest object
beings_harmony      # Activate astral beings harmony mode
```

## 📦 Object Creation Commands

| Command | Description | Example |
|---------|-------------|---------|
| `tree` | Spawn a tree | `tree` |
| `rock` | Spawn a rock | `rock` |
| `box` | Spawn a box | `box` |
| `ball` | Spawn a ball | `ball` |
| `ramp` | Spawn a ramp | `ramp` |
| `bush` | Spawn a bush | `bush` |
| `fruit` | Spawn a fruit | `fruit` |
| `sun` | Spawn a light source | `sun` |
| `astral` | Spawn an astral being | `astral` |
| `pathway` | Spawn a pathway | `pathway` |

### Batch Creation:
```bash
forest              # Create multiple trees at once
spawn 5 tree        # Spawn 5 trees
spawn 3 rock        # Spawn 3 rocks
```

## 🤖 Ragdoll Control Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `ragdoll_come` | Ragdoll comes to your position | Direct command |
| `ragdoll_pickup` | Pick up nearest object | Ragdoll must be near object |
| `ragdoll_drop` | Drop currently held object | Must be holding object |
| `ragdoll_organize` | Organize nearby objects | Automatic arrangement |
| `ragdoll_patrol` | Start patrol route | Follows preset path |
| `walk` | Toggle ragdoll walking | On/off toggle |
| `ragdoll reset` | Reset ragdoll position | Returns to origin |
| `say <text>` | Make ragdoll speak | `say Hello world!` |

### Ragdoll Movement Examples:
```bash
ragdoll_come        # Come to player
ragdoll_pickup      # Pick up nearest object
ragdoll_organize    # Start organizing scene
```

## ✨ Astral Beings Commands

| Command | Description | Effect |
|---------|-------------|--------|
| `beings_status` | Show astral beings info | Displays count and energy |
| `beings_help` | Help ragdoll mode | Beings assist ragdoll |
| `beings_organize` | Organization mode | Beings arrange objects |
| `beings_harmony` | Harmony mode | Environmental balance |

### Astral Beings Workflow:
```bash
beings_status       # Check beings status
beings_help         # Activate ragdoll assistance
beings_harmony      # Create environmental harmony
```

## 🛠️ System & Debug Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `help` | Show all commands | Basic help |
| `clear` | Clear console/objects | `clear` or `clear objects` |
| `list` | List all spawned objects | Shows IDs and positions |
| `delete <id>` | Delete specific object | `delete tree_1` |
| `system_status` | Check all systems | Health check |
| `floodgate_status` | Floodgate system info | Queue sizes |
| `debug` | Toggle debug screen | 3D visualization |
| `select <name>` | Select object | `select tree_1` |
| `move <x> <y> <z>` | Move selected object | `move 5 0 -3` |
| `rotate <x> <y> <z>` | Rotate selected object | `rotate 0 45 0` |
| `scale_obj <value>` | Scale selected object | `scale_obj 2` |

## 🎯 Advanced Commands

### Physics Control:
```bash
gravity 9.8         # Set gravity (default: 9.8)
physics awaken      # Wake up physics objects
state idle          # Change physics state
```

### Scene Management:
```bash
save my_garden      # Save current scene
load my_garden      # Load saved scene
scene list          # List available scenes
```

### Console Settings:
```bash
console center      # Center console position
console top         # Move console to top
console bottom      # Move console to bottom
scale 1.5          # Scale UI (0.5-2.0)
```

## 🌟 Creative Workflows

### Building a Garden:
```bash
# 1. Create base objects
tree
tree
bush
rock
box

# 2. Summon ragdoll helper
ragdoll_come
ragdoll_organize

# 3. Add harmony
beings_harmony

# 4. Continue building
fruit
pathway
ragdoll_pickup
```

### Object Organization:
```bash
# 1. Create mess
spawn 10 box
spawn 5 rock

# 2. Organize with ragdoll
ragdoll_organize
ragdoll_patrol

# 3. Add astral assistance
beings_organize
```

### Interactive Play:
```bash
# 1. Create playground
ramp
ball
box

# 2. Interact
ragdoll_come
ragdoll_pickup
ragdoll_drop

# 3. Add effects
beings_help
say "This is fun!"
```

## 💡 Tips & Tricks

1. **Mouse Position**: Objects spawn at mouse cursor position
2. **Tab Key**: Press Tab to open/close console
3. **Up/Down Arrows**: Navigate command history
4. **Multiple Commands**: Chain commands for complex actions
5. **Object Groups**: All objects automatically grouped for management

## 🎨 Color Codes in Console

- 🟢 **Green**: Success messages
- 🔴 **Red**: Error messages
- 🔵 **Cyan**: System information
- 🟡 **Yellow**: Command syntax
- 🟣 **Purple**: Special effects

## 🚧 Troubleshooting

| Issue | Command | Solution |
|-------|---------|----------|
| Ragdoll stuck | `ragdoll reset` | Resets position |
| Too many objects | `clear` | Removes all objects |
| Can't see ragdoll | `ragdoll_come` | Brings to camera |
| Console hidden | Press `Tab` | Toggle console |
| Objects not spawning | Check mouse position | Must be over ground |

---

**Quick Start**: Press `Tab` → Type `help` → Start with `tree` → Try `ragdoll_come`!