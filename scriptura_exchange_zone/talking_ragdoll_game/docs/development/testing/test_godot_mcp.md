# Godot MCP Test Commands

## Quick Test Sequence

Once you start the new Claude Code session in this directory, ask Claude:

1. **"Get the Godot version"**
   - Should return your installed Godot version

2. **"Launch the Godot editor for this project"**
   - Should open the Godot editor with this project

3. **"Run the project and show me the console output"**
   - Should run the game and capture all console messages

4. **"List all Godot projects in the parent directory"**
   - Should find other Godot projects nearby

5. **"Get detailed project info"**
   - Should show project structure, autoloads, scenes

## Expected Console Output

When the project runs, look for:

✅ Universal Entity messages:
```
[UNIVERSAL] Entity spawned! I am everything and nothing.
[UNIVERSAL] Current satisfaction: 100%
```

✅ Console initialization:
```
[CONSOLE] Initializing with 50+ commands
[FILTER] Spam filter initialized
[FLOODGATE] System ready
```

✅ No red errors (all should be fixed)

## Console Commands to Test

Once the game is running:
- `universal` - Check entity status
- `perfect` - Make everything perfect  
- `health` - System performance
- `filter_stats` - Spam filter info
- `create rock` - Test object creation
- `help` - List all commands

## Advanced MCP Commands

Claude can also:
- Create new scenes
- Add nodes to scenes
- Export mesh libraries
- Manage UIDs (Godot 4.4+)
- Stop running projects

Ready to see the Universal Entity in action with direct Godot control! 🚀