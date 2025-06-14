# Godot Class to Script Mapping - Talking Ragdoll Game

## 🗂️ Complete Class Usage Analysis

### RigidBody3D Class Usage

**Scripts that extend RigidBody3D:**
- `scripts/characters/talking_ragdoll.gd:8` - `extends RigidBody3D`

**Scripts that create RigidBody3D instances:**
- `scripts/core/seven_part_ragdoll_integration.gd:123` - `var part = RigidBody3D.new()`
- `scripts/autoload/console_manager.gd:1456` - Creates RigidBody3D for spawned objects

**Key RigidBody3D properties used:**
- `gravity_scale` - Line references:
  - `talking_ragdoll.gd:25` - `gravity_scale = 0.1`
  - `simple_ragdoll_walker.gd:65` - `body.gravity_scale = 0.1`
- `linear_damp` - Line references:
  - `talking_ragdoll.gd:26` - `linear_damp = 2.0`
  - `simple_ragdoll_walker.gd:68` - `body.linear_damp = 10.0`
- `angular_damp` - Line references:
  - `talking_ragdoll.gd:27` - `angular_damp = 5.0`
  - `simple_ragdoll_walker.gd:69` - `body.angular_damp = 20.0`
- `mass` - Line references:
  - `seven_part_ragdoll_integration.gd:140` - `part.mass = 1.0`

**Key RigidBody3D methods used:**
- `apply_central_force()` - Line references:
  - `simple_ragdoll_walker.gd:97` - `pelvis.apply_central_force(Vector3.UP * height_error * upright_force)`
  - `simple_ragdoll_walker.gd:111` - `body.apply_central_force(pull_direction * 50.0)`
  - `simple_ragdoll_walker.gd:122` - `pelvis.apply_central_force(horizontal_force)`

### CharacterBody3D Class Usage

**Scripts that extend CharacterBody3D:**
- `scripts/core/seven_part_ragdoll_integration.gd:8` - `extends CharacterBody3D`

**Key CharacterBody3D properties used:**
- `velocity` - Line references:
  - `seven_part_ragdoll_integration.gd:300` - `velocity = direction * walk_speed`
  - `seven_part_ragdoll_integration.gd:328` - `velocity = Vector3.ZERO`
  - `simple_ragdoll_walker.gd:116` - `ragdoll_root.velocity = move_direction * move_speed`

**Key CharacterBody3D methods used:**
- `move_and_slide()` - Line references:
  - `seven_part_ragdoll_integration.gd:301` - `move_and_slide()`
  - `seven_part_ragdoll_integration.gd:312` - `move_and_slide()`
  - `simple_ragdoll_walker.gd:117` - `ragdoll_root.move_and_slide()`

### Node3D Class Usage

**Scripts that extend Node3D:**
- `scripts/core/simple_ragdoll_walker.gd:8` - `extends Node3D`
- `scripts/systems/standardized_objects.gd:1` - `extends Node3D`

**Scripts that create Node3D instances:**
- `scripts/autoload/console_manager.gd:2227` - `var container = Node3D.new()`
- `scripts/core/seven_part_ragdoll_integration.gd:112` - `var walker = Node3D.new()`

**Key Node3D properties used:**
- `global_position` - Line references:
  - `simple_ragdoll_walker.gd:92` - `var current_height = pelvis.global_position.y`
  - `seven_part_ragdoll_integration.gd:304` - `global_position.distance_to(target_position)`
  - `seven_part_ragdoll_integration.gd:346` - `var distance = global_position.distance_to(body.global_position)`
- `position` - Line references:
  - `seven_part_ragdoll_integration.gd:84` - `part.position = part_info.pos`

### Control Class Usage

**Scripts that use Control hierarchy:**
- `scripts/autoload/console_manager.gd` - Extensive UI system

**Control subclasses used:**
- `PanelContainer` - Line references:
  - `console_manager.gd:13` - `var console_panel: PanelContainer`
  - `console_manager.gd:388` - `console_panel = PanelContainer.new()`
- `LineEdit` - Line references:
  - `console_manager.gd:19` - `var input_field: LineEdit`
  - `console_manager.gd:407` - `input_field = LineEdit.new()`
- `RichTextLabel` - Line references:
  - `console_manager.gd:17` - `var output_display: RichTextLabel`
  - `console_manager.gd:398` - `output_display = RichTextLabel.new()`

### Timer Class Usage

**Scripts that use Timer:**
- `scripts/core/seven_part_ragdoll_integration.gd:261` - `var timer = Timer.new()`

**Timer properties/methods used:**
- `wait_time` - Line 262: `timer.wait_time = randf_range(8.0, 15.0)`
- `timeout.connect()` - Line 263: `timer.timeout.connect(_speak_random_phrase)`
- `autostart` - Line 264: `timer.autostart = true`

### Signal Usage Patterns

**Custom signals defined:**
- `seven_part_ragdoll_integration.gd:32-34`:
  ```gdscript
  signal ragdoll_state_changed(new_state: String)
  signal ragdoll_position_updated(position: Vector3)
  signal ragdoll_dialogue_started(text: String)
  ```

**Built-in signal connections:**
- `console_manager.gd:414` - `input_field.text_submitted.connect(_on_command_submitted)`
- `console_manager.gd:430` - `submit_button.pressed.connect(func(): _on_command_submitted(input_field.text))`

### Physics Classes Usage

**Joint3D subclasses:**
- `Generic6DOFJoint3D` - `seven_part_ragdoll_integration.gd:184`
- `HingeJoint3D` - `seven_part_ragdoll_integration.gd:190, 196, 202, 209, 215`

**CollisionShape3D usage:**
- `seven_part_ragdoll_integration.gd:125` - `var collision = CollisionShape3D.new()`
- `seven_part_ragdoll_integration.gd:126` - `var shape = CapsuleShape3D.new()`

### Resource and File Classes

**FileAccess usage:**
- Not currently used (potential improvement area)

**Resource loading:**
- `console_manager.gd:2335` - `var physics_test_script = load("res://scripts/debug/ragdoll_physics_test.gd")`
- `seven_part_ragdoll_integration.gd:107` - `var walker_script = load("res://scripts/core/simple_ragdoll_walker.gd")`

## 📊 Class Usage Statistics by Script

### High Class Density Scripts:
1. **console_manager.gd** - 15+ Godot classes
   - Control, PanelContainer, LineEdit, RichTextLabel, VBoxContainer, HBoxContainer, ScrollContainer, Button, CenterContainer, CanvasLayer, StyleBoxFlat, Theme, Tween, Timer, Node

2. **seven_part_ragdoll_integration.gd** - 10+ Godot classes
   - CharacterBody3D, RigidBody3D, CollisionShape3D, CapsuleShape3D, Generic6DOFJoint3D, HingeJoint3D, Timer, Node3D, Vector3, Time

3. **simple_ragdoll_walker.gd** - 8+ Godot classes
   - Node3D, RigidBody3D, CharacterBody3D, Vector3, PhysicsBody3D properties

### Medium Class Density Scripts:
4. **talking_ragdoll.gd** - 5+ Godot classes
   - RigidBody3D, CollisionShape3D, CapsuleShape3D, MeshInstance3D, CapsuleMesh

5. **standardized_objects.gd** - 4+ Godot classes
   - Node3D, RigidBody3D, StaticBody3D, MeshInstance3D

## 🔍 Critical Integration Points

### Physics System Integration:
- **Primary Controller**: `CharacterBody3D` in `seven_part_ragdoll_integration.gd:8`
- **Physics Bodies**: `RigidBody3D` instances created in `seven_part_ragdoll_integration.gd:123`
- **Movement Control**: `simple_ragdoll_walker.gd` manages physics properties

### UI System Integration:
- **Main Console**: `console_manager.gd` - Complete Control hierarchy
- **Autoload Pattern**: Registered in project.godot autoloads
- **Signal Communication**: `text_submitted` and `pressed` signals

### Scene Tree Management:
- **Node Hierarchy**: Proper parent-child relationships
- **Group Management**: `add_to_group("ragdoll")` in `seven_part_ragdoll_integration.gd:40`
- **Node References**: Using `get_node_or_null()` for safe access

## 🎯 Optimization Opportunities

### Missing Godot Features:
1. **NavigationAgent3D** - Not used (could improve ragdoll pathfinding)
2. **Area3D** - Minimal usage (could add interaction zones)
3. **PhysicsServer3D** - Not used (could optimize physics queries)
4. **Resource classes** - Not used (could store configurations)

### Performance Improvements:
1. **Object Pooling** - Use PackedScene.instantiate() instead of .new()
2. **Node Caching** - Store node references instead of repeated get_node()
3. **Signal Optimization** - Use one-shot connections where appropriate

## 📋 Script-to-Class Quick Reference

```
talking_ragdoll.gd → RigidBody3D, CollisionShape3D, MeshInstance3D
seven_part_ragdoll_integration.gd → CharacterBody3D, RigidBody3D, Joint3D variants
simple_ragdoll_walker.gd → Node3D, physics properties management
console_manager.gd → Control hierarchy, UI classes
standardized_objects.gd → Node3D, StaticBody3D, MeshInstance3D
```

---

*This mapping provides direct navigation from Godot classes to implementation locations*
*Use line numbers to quickly jump to specific usage examples*