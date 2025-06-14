# Test Commands - Quick Reference

## After Reloading the Game

### Look for these messages in Godot output:
```
🔌 [MainGameController] Console command extension loaded
[CommandExtension] Extending console commands...
[CommandExtension] Found LineEdit!
[CommandExtension] Hooked into text input processing
```

### Test sequence:
1. Press **F1** to open console
2. Type: `test` (should show "Extension test successful!")
3. Type: `spawn_biowalker`
4. Press **F3** to see debug layer

## If Commands Still Don't Work

The console might be using a different structure. Try these debug steps:

1. Check if LayerRealitySystem is in autoloads:
   - Look in Project Settings > Autoload
   - Should see "LayerRealitySystem"

2. Try the existing spawn commands first:
   ```
   spawn_ragdoll
   tree
   rock
   ```

3. Check console output for any error messages

## Alternative Approach

If the extension doesn't work, we can modify the console_manager.gd directly to add our commands to the commands dictionary. Would you like me to do that?

## What We're Trying to Add

1. **spawn_biowalker** - Creates walker with anatomical feet
2. **walker_debug** - Controls visualization
3. **layers** - Shows layer system status
4. **layer** - Controls individual layers

The biomechanical walker has:
- Heel, foot, and toe segments
- 8-phase gait cycle
- Ground contact detection
- Force visualization

---
Let me know what happens when you reload!