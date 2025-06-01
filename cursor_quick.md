# 🎨 Cursor - Quick Integration

## Create This File:
`systems/consciousness_effect_manager.gd`
```gdscript
extends Node
class_name ConsciousnessEffectManager

const EFFECTS = {
    0: preload("res://effects/dormant_gray.tscn"),
    1: preload("res://effects/awakening_white.tscn"),
    # ... etc
}

static func switch_effect(being: Node, level: int):
    # Remove old
    for child in being.get_children():
        if child.has_meta("is_effect"):
            child.queue_free()
    
    # Add new
    var effect = EFFECTS[level].instantiate()
    effect.set_meta("is_effect", true)
    being.add_child(effect)
```

## Test It:
In any being:
```gdscript
func _ready():
    ConsciousnessEffectManager.switch_effect(self, consciousness_level)
```

Icons can wait - let's see particles working!

Path: C:\Users\Percision 15\Universal_Being\cursor_quick.md