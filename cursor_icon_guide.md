# 🎨 Cursor - Icon Creation Guide

## Quick Icon Specs:
- Size: 32x32px
- Format: PNG with transparency
- Style: Simple, clear, symbolic

## Icon Descriptions:

### level_0.png - Dormant (Gray)
- Dark gray circle
- Maybe with subtle cracks or void pattern
- Opacity: 80%

### level_1.png - Awakening (White)
- White spark or star burst
- Central bright point with rays
- Glowing effect

### level_2.png - Aware (Blue)
- Cyan water drop
- Could have ripple effect lines
- Translucent feel

### level_3.png - Conscious (Green)
- Green leaf or sprout
- Simple plant symbol
- Growth implied

### level_4.png - Enlightened (Yellow)
- 6-pointed star (for 6 AIs!)
- Golden yellow
- Could reference the Pentagon

### level_5.png - Transcendent (White)
- Glowing orb with aura
- Soft white with glow
- Ethereal feel

### level_6.png - Beyond (Red)
- Phoenix or flame shape
- Deep red
- Dynamic, rising motion

### level_7.png - Ultimate (Rainbow)
- Infinity symbol (∞)
- Rainbow gradient
- Represents eternal evolution

## 🎯 Recommendation:
Start with SVG templates! They're scalable and easy to edit.

## Auto-assign Script:
```gdscript
extends Node
class_name ConsciousnessIconManager

const ICONS = {
    0: preload("res://assets/icons/level_0.png"),
    1: preload("res://assets/icons/level_1.png"),
    2: preload("res://assets/icons/level_2.png"),
    3: preload("res://assets/icons/level_3.png"),
    4: preload("res://assets/icons/level_4.png"),
    5: preload("res://assets/icons/level_5.png"),
    6: preload("res://assets/icons/level_6.png"),
    7: preload("res://assets/icons/level_7.png")
}

static func get_icon_for_level(level: int) -> Texture2D:
    return ICONS.get(clamp(level, 0, 7), ICONS[0])

static func apply_icon_to_node(node: Node, level: int) -> void:
    if node.has_method("set_texture"):
        node.texture = get_icon_for_level(level)
    elif node.has_method("set_icon"):
        node.icon = get_icon_for_level(level)
```

## Priority:
1. Create SVG templates first
2. Export as 32x32 PNGs
3. Test with the auto-assign script

The icons will help players instantly recognize consciousness levels!