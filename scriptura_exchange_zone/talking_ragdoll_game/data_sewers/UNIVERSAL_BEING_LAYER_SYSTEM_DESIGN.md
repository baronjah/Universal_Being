# Universal Being Layer System Design

## 🎨 Vision
A layer system where Universal Beings can exist on different visibility layers, ensuring that beings on important layers (like UI or player) are always visible even when other beings are physically in front of them.

## 🎯 Core Concept

### Layer Priority System
```gdscript
# Each Universal Being has a layer property
extends Node3D
class_name UniversalBeing

var layer: int = 0  # Default layer
var layer_priority: float = 0.0  # Sub-layer ordering

# Layer definitions
const LAYER_BACKGROUND = -2  # Far background elements
const LAYER_WORLD = 0       # Default world objects
const LAYER_PLAYER = 1      # Player and important NPCs
const LAYER_EFFECTS = 2     # Particles, spells
const LAYER_UI = 3          # UI elements in 3D space
const LAYER_OVERLAY = 10    # Always on top
```

## 🔧 Implementation Approaches

### 1. **Render Layer System** (Using Godot's built-in layers)
```gdscript
func set_being_layer(layer: int) -> void:
	# Set visual instance layers
	if manifestation and manifestation is VisualInstance3D:
		match layer:
			LAYER_PLAYER:
				manifestation.layers = 2  # Render on layer 2
			LAYER_UI:
				manifestation.layers = 4  # Render on layer 4
	
	# Camera needs to see all layers
	# Camera cull_mask = 0b1111 (sees layers 1,2,3,4)
```

### 2. **Z-Index in 3D** (Custom shader approach)
```gdscript
# Custom shader that offsets depth based on layer
shader_type spatial;
uniform float layer_offset = 0.0;

void vertex() {
	// Offset position towards camera based on layer
	vec4 view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	view_pos.z += layer_offset;
	POSITION = PROJECTION_MATRIX * view_pos;
}
```

### 3. **Multiple Viewports** (Most flexible)
```gdscript
# Each layer gets its own viewport
var layer_viewports: Dictionary = {}

func _ready():
	# Create viewport for each layer
	for layer in [LAYER_WORLD, LAYER_PLAYER, LAYER_UI]:
		var viewport = SubViewport.new()
		var camera = Camera3D.new()
		viewport.add_child(camera)
		layer_viewports[layer] = viewport
```

### 4. **Transparency Sorting** (Simple but effective)
```gdscript
func update_being_visibility():
	# Make beings on higher layers slightly transparent
	# but with priority rendering
	if manifestation:
		var material = manifestation.get_surface_override_material(0)
		if not material:
			material = StandardMaterial3D.new()
		
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.no_depth_test = (layer >= LAYER_PLAYER)
		material.render_priority = layer
```

## 🎮 Usage Examples

### Setting Being Layers
```gdscript
# Player is always visible
player_being.set_property("layer", LAYER_PLAYER)

# World objects on default layer
tree_being.set_property("layer", LAYER_WORLD)

# UI elements always on top
health_bar_being.set_property("layer", LAYER_UI)
```

### Console Commands
```bash
# Set layer for a being
being layer player_0 1

# List all beings by layer
being list_layers

# Toggle layer visibility
layer show 1
layer hide 0
```

## 🌟 Advanced Features

### 1. **Layer Interactions**
```gdscript
# Beings can only interact with same or adjacent layers
func can_interact_with(other_being: UniversalBeing) -> bool:
	var layer_diff = abs(layer - other_being.layer)
	return layer_diff <= 1
```

### 2. **Dynamic Layer Switching**
```gdscript
# Beings can move between layers
func transition_to_layer(new_layer: int, duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(self, "layer_blend", new_layer, duration)
```

### 3. **Layer-Based Effects**
```gdscript
# Different visual effects per layer
func apply_layer_effects():
	match layer:
		LAYER_PLAYER:
			add_outline_effect()
		LAYER_UI:
			add_glow_effect()
		LAYER_BACKGROUND:
			add_fog_effect()
```

## 🔄 Integration with Existing Systems

### With Universal Gizmo
- Gizmo always renders on LAYER_OVERLAY
- Selected objects temporarily move to LAYER_PLAYER

### With Universal Mouse
- Mouse Being exists on LAYER_OVERLAY
- Can interact across all layers

### With Scene Containers
- Each container can have a default layer
- Objects inherit container's layer unless specified

## 📊 Performance Considerations

1. **Render Layers**: Most performant, uses GPU efficiently
2. **Multiple Viewports**: More memory but ultimate flexibility
3. **Shader Approach**: Good balance of performance and features
4. **Transparency**: Simplest but may have sorting issues

## 🎯 Recommended Implementation

Start with **Render Layers + Transparency** approach:
1. Use Godot's built-in render layers for basic separation
2. Add transparency and render_priority for fine control
3. Implement no_depth_test for UI/Player layers
4. Add shader-based enhancements later if needed

This gives us a solid foundation that can be extended with more advanced features as needed!

---
*"In the layers of reality, every Universal Being finds its perfect place"*