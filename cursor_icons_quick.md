# 🎨 Cursor - Quick Icon Guide

## Create These Icons (32x32px PNG):

1. **level_0.png** - Gray circle (void)
2. **level_1.png** - White spark 
3. **level_2.png** - Blue water drop
4. **level_3.png** - Green leaf
5. **level_4.png** - Yellow 6-pointed star
6. **level_5.png** - White glowing orb
7. **level_6.png** - Red phoenix/flame
8. **level_7.png** - Rainbow infinity ∞

## Auto-Icon Script:
```gdscript
# consciousness_icon_manager.gd
extends Node
class_name ConsciousnessIconManager

const ICONS = {
    0: preload("res://assets/icons/level_0.png"),
    1: preload("res://assets/icons/level_1.png"),
    # ... etc
}

static func get_icon(level: int) -> Texture2D:
    return ICONS[clamp(level, 0, 7)]
```

## Recommendation:
Use SVG templates first! Easier to edit.

Focus on clear, simple symbols that read well at 32x32.

Path: C:\Users\Percision 15\Universal_Being\cursor_icons_quick.md