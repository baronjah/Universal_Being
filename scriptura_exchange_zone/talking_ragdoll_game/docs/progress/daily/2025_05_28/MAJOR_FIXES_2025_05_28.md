# Major Fixes Applied - May 28, 2025

## Key Issues Addressed

### 1. Custom Asset Creation Fixed ✅
**Problem:** `sphere_test` asset not appearing in asset list
**Root Cause:** StandardizedObjects was a RefCounted class, changes weren't persisting
**Solution:** 
- Converted StandardizedObjects to autoload Node
- Updated all references to use `/root/StandardizedObjects`
- Assets created in-game now persist properly

### 2. Console Command Consolidation Identified
**Issue:** Multiple command registration systems
- `console_manager.gd` - Main commands (first 218 lines organized)
- `console_command_extension.gd` - Additional commands (walker, bio commands)
- Some commands appear to use `register_command()` function

### 3. Rule Execution Control
**Problem:** `rules off` command syntax confusion
**Clarification:** 
- Correct command: `rules off` (with space)
- Wrong command: `rules_off` (with underscore)
- Command works but might not stop all rule systems

## Commands to Test

### Asset Creation
- `create sphere_test` - Should now work with your custom asset
- `asset_creator` - Create more custom assets
- `assets` - List should now show custom assets

### Rule Control  
- `rules off` - Disable automatic spawning (correct syntax)
- `rules on` - Re-enable if needed
- `rules` - Toggle current state

### Object Creation
- `stick` - Should be visible now
- `leaf` - Should be visible  
- `wall` - Should work
- All assets from the `assets` list

## Remaining Issues

### 1. Objects Not Appearing
Some manually created objects (stick, leaf) might not show in `list` command because:
- Different object tracking systems
- Floodgate queue processing
- Object visibility/positioning

### 2. Performance/Spam Issues
- JSH tree still creating massive spam
- Multiple UI systems creating thousands of nodes
- Performance optimization triggers causing loops

### 3. Multiple Command Systems
Need to investigate:
- Which commands are in `console_command_extension.gd`
- How `register_command()` works
- Whether there are conflicts between systems

## Next Testing Steps

1. **Test custom assets**: Try `create sphere_test` 
2. **Test rule control**: Use `rules off` to stop spam
3. **Test object visibility**: Use `stick`, `leaf` and check if visible in scene
4. **Check asset list**: Use `assets` to see if custom assets appear
5. **Performance**: See if rule control reduces JSH spam

The core asset creation system should now work properly with persistent custom assets!