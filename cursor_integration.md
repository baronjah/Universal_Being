# 🎨 Cursor - Integration Scripts Needed

## Priority 1: Effect Manager
Create `systems/consciousness_effect_manager.gd`:
```gdscript
extends Node
class_name ConsciousnessEffectManager

const EFFECTS = {
    0: preload("res://effects/dormant_gray.tscn"),
    1: preload("res://effects/awakening_white.tscn"),
    2: preload("res://effects/aware_blue.tscn"),
    3: preload("res://effects/conscious_green.tscn"),
    4: preload("res://effects/enlightened_gold.tscn"),
    5: preload("res://effects/transcendent_glow.tscn"),
    6: preload("res://effects/beyond_red.tscn")
}

static func switch_effect(being: Node, level: int):
    # Remove old effects
    for child in being.get_children():
        if child.has_meta("is_effect"):
            child.queue_free()
    
    # Add new effect
    var effect = EFFECTS[level].instantiate()
    effect.set_meta("is_effect", true)
    being.add_child(effect)
```

## Priority 2: Test Integration
```gdscript
# In any being's pentagon_ready():
ConsciousnessEffectManager.switch_effect(self, consciousness_level)

# On level change:
func set_consciousness_level(level: int):
    consciousness_level = level
    ConsciousnessEffectManager.switch_effect(self, level)
```

## Priority 3: Evolution Animation
```gdscript
func evolve_with_effect():
    var burst = preload("res://effects/evolution_flash.tscn").instantiate()
    add_child(burst)
    await get_tree().create_timer(1.0).timeout
    burst.queue_free()
```

Skip icons for now - let's see effects working first!

Path: C:\Users\Percision 15\Universal_Being\cursor_integration.md