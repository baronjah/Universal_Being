# 🔍 Advanced Object Inspector Guide

## Overview

The Advanced Object Inspector is a powerful in-game editing system that allows you to modify any object in your scene in real-time. It integrates with the console system and Floodgate controller for seamless scene management.

## 🚀 Quick Start

### Basic Commands

```bash
# Inspect any object
inspect ragdoll_1
inspect selected     # Inspect first selected object
inspect mouse        # Inspect object under mouse cursor

# Control the inspector
inspector show       # Show the inspector window
inspector hide       # Hide the inspector window
inspector toggle     # Toggle visibility
inspector pin        # Pin inspector (stays open)
inspector unpin      # Unpin inspector

# Quick edits
edit position 0,5,0  # Set position of selected objects
edit visible false   # Hide selected objects
edit modulate 1,0,0,1 # Make selected objects red
```

## 🎯 Object Selection

### Select Objects
```bash
# Select by name
select Player
select ragdoll_*     # Wildcard patterns

# Select by type
select type:RigidBody3D
select type:MeshInstance3D

# Select by group
select group:enemies
select group:pickups

# Select all/none
select_all
deselect

# View selection
selection            # Shows all selected objects
```

## ✏️ Property Editing

### Direct Editing
```bash
# Edit any property
edit mass 5.0
edit gravity_scale 2.0
edit albedo_color 1,0.5,0,1

# Transform shortcuts
pos 10 0 5          # Set position
rot 0 45 0          # Set rotation (degrees)
scale 2             # Uniform scale
scale 1 2 1         # Non-uniform scale
```

### Inspector Features

The inspector window provides:
- **Properties Tab**: All object properties organized by category
- **Transform Tab**: Dedicated transform editing with visual tools
- **Materials Tab**: Material and shader properties
- **Physics Tab**: Physics body settings
- **Scene Tab**: Scene tree view and hierarchy

## 🏗️ Scene Management

### Creating Objects
```bash
# Create nodes
create_node Node3D MyContainer
create_node RigidBody3D PhysicsObject

# Create meshes
create_mesh box      # Box mesh
create_mesh sphere   # Sphere mesh
create_mesh cylinder # Cylinder mesh

# Create lights
create_light omni    # Point light
create_light spot    # Spot light
create_light directional # Sun light

# Create camera
create_camera        # New camera
```

### Scene Operations
```bash
# Scene editing mode
scene_edit on        # Enable scene editing
scene_edit off       # Disable scene editing

# Save/Load scenes
save_scene my_scene.tscn
load_scene levels/test_level.tscn
scene_new            # Create new empty scene

# Export scenes
scene_export gltf my_scene.gltf
scene_export obj my_scene.obj
```

### Object Manipulation
```bash
# With selected objects
delete_selected      # Delete selection
duplicate_selected   # Duplicate selection
reset_transform      # Reset to origin

# Grid snapping
grid on              # Enable grid snap
grid_size 0.5        # Set grid size
snap_to_grid         # Snap selected to grid
```

## 🎨 Advanced Features

### Property Categories

Properties are organized into logical groups:
- **Transform**: Position, rotation, scale
- **Node**: Name, visibility, process settings
- **Physics**: Mass, gravity, damping
- **Collision**: Layers, masks, shapes
- **Material**: Colors, textures, shaders
- **Light**: Energy, color, shadows
- **Mesh**: Mesh resource, LOD settings
- **Custom**: Script-exposed properties

### Keyboard Shortcuts

When the inspector is open:
- `ESC` - Close inspector (unless pinned)
- `Ctrl+Z` - Undo last change
- `Ctrl+Y` - Redo last change

### Property Types

The inspector supports editing:
- Basic types (bool, int, float, string)
- Vectors (Vector2, Vector3)
- Colors (with color picker)
- Resources (with file browser)
- Arrays (with array editor)
- Objects (with reference picker)

## 🔧 Integration with Floodgate

All operations go through the Floodgate system for:
- Thread-safe execution
- Operation queuing
- Undo/redo support
- Performance optimization

Example flow:
1. You edit a property in the inspector
2. Change is queued in Floodgate
3. Floodgate processes it safely
4. Scene is updated
5. Inspector reflects the change

## 💡 Tips & Tricks

### Performance
- Use `select type:` to quickly select many objects
- Pin the inspector when making many edits
- Use grid snapping for precise placement
- Batch operations with selection

### Workflow
1. Enter scene edit mode: `scene_edit on`
2. Select objects: `select type:MeshInstance3D`
3. Open inspector: `inspect selected`
4. Make changes via UI or commands
5. Save scene: `save_scene my_level.tscn`

### Common Tasks

**Align objects to ground:**
```bash
select_all
edit position.y 0
```

**Make objects non-collidable:**
```bash
select type:CollisionShape3D
edit disabled true
```

**Change all light colors:**
```bash
select type:Light3D
edit light_color 1,0.9,0.8,1
```

## 🐛 Troubleshooting

### Inspector not showing?
```bash
inspector show
console_manager._create_object_inspector()
```

### Can't select objects?
- Make sure object has collision
- Check if object is in a group
- Try selecting parent first

### Changes not saving?
- Use `save_scene` command
- Check file permissions
- Ensure valid scene path

## 🚀 Advanced Usage

### Custom Property Editors

You can add custom editors for specific types:
1. Create editor script in `scripts/ui/editors/`
2. Register in `custom_editors` dictionary
3. Inspector will use it automatically

### Scene Templates

Create reusable scene setups:
```bash
# Save current setup
save_scene templates/forest_base.tscn

# Load and modify
load_scene templates/forest_base.tscn
select type:Tree
scale 1.5
save_scene levels/big_forest.tscn
```

### Batch Processing

Edit multiple scenes:
```bash
load_scene level1.tscn
select type:Light3D
edit shadow_enabled false
save_scene level1_no_shadows.tscn
```

---

*The Advanced Object Inspector brings Godot editor power directly into your game!*