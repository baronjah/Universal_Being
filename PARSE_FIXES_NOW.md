# 🔧 URGENT: Parse Error Fixes for Claude Code

## Fix These Errors NOW:

### 1. button_universal_being.gd
**Error**: "scene_instance" not declared
**Fix**: Add at class level:
```gdscript
var scene_instance: Node = null
```

### 2. claude_desktop_mcp_universal_being.gd
**Error**: Tab/space mixing
**Fix**: Convert ALL tabs to spaces (use Find & Replace: \t → "    ")

### 3. pentagon_network_visualizer.gd
**Error**: get_viewport_rect() not found
**Fix**: Change to:
```gdscript
get_viewport().get_visible_rect()
```

### 4. universal_being_generator.gd
**Error**: Expected variable name
**Fix**: Find the line with just "var" and complete it or remove it

### 5. consciousness_aura_enhanced.gd
**Error**: EMISSION_RING doesn't exist
**Fix**: Change to:
```gdscript
emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
```

### 6. advanced_visualization_optimizer.gd
**Error**: Missing functions
**Fix**: Add these stub functions:
```gdscript
func find_consensus_clusters() -> Array:
    return []

func identify_behavioral_outliers() -> Array:
    return []
```

### 7. Test files (run_tests.gd, test_framework.gd, test_visual_integration.gd)
**Error**: String * int
**Fix**: Find lines like:
```gdscript
print("-" * 50)  # WRONG
```
Change to:
```gdscript
print("-".repeat(50))  # CORRECT
```

## DO THIS NOW:
1. Fix each file above
2. Save all
3. Reload Godot
4. Report back

We're SO CLOSE!