# 🎮 Godot MCP Complete Workflow

## Overview
Complete workflow for using MCP tools with Godot projects - from launch to clean shutdown.

## 🚀 **Start to Finish Workflow**

### 1. **Check Godot Version**
```bash
# Verify MCP connection and Godot installation
godot --version
```

### 2. **Run Project**
```bash
# Method A: Run and capture output
# Method B: Launch editor
# Method C: Run specific scene
```

### 3. **Monitor Running Processes**
```bash
# Check what's running
pgrep -fl godot
ps aux | grep -E "godot|Godot" | grep -v grep
```

### 4. **Stop Project Cleanly**
```bash
# Step 1: Get process ID
PID=$(pgrep godot)

# Step 2: Graceful stop (preferred)
kill -TERM $PID

# Step 3: Verify stopped
ps -p $PID || echo "Process stopped successfully"

# Step 4: Force stop if needed
if pgrep godot > /dev/null; then
    kill -KILL $(pgrep godot)
    echo "Force stopped Godot processes"
fi
```

## 🎯 **MCP Commands Summary**

### Available MCP Tools:
- `get_godot_version` - Check Godot installation
- `launch_editor` - Open Godot editor
- `run_project` - Execute project with debug output
- `get_debug_output` - Capture console messages
- `stop_project` - Clean shutdown (uses the kill workflow above)
- `list_projects` - Find Godot projects in directory
- `get_project_info` - Analyze project structure

### Best Practices:
1. **Always check version first** to verify MCP connection
2. **Use debug output capture** to monitor for errors
3. **Stop cleanly every time** to prevent hanging windows
4. **Verify process stopped** before starting new sessions

## 🔧 **Troubleshooting**

### If Godot Won't Stop:
```bash
# Nuclear option - stop all Godot processes
pkill -KILL godot
# or
killall -9 Godot
```

### If MCP Can't Find Godot:
- Check `GODOT_PATH` environment variable
- Verify Godot is in system PATH
- Use absolute path in MCP configuration

### If Project Won't Launch:
- Verify `project.godot` exists in target directory
- Check project format compatibility
- Review debug output for specific errors

## 📝 **Session Template**

For every MCP session with Godot:

```bash
# 1. Verify setup
get_godot_version

# 2. Check current state
pgrep godot || echo "No Godot processes running"

# 3. Run project
run_project --path "/path/to/project"

# 4. Monitor and test
get_debug_output

# 5. Clean shutdown
stop_project
# or manual: kill -TERM $(pgrep godot)

# 6. Verify clean
pgrep godot || echo "Successfully stopped"
```

## 🎮 **Game-Specific Notes**

### For talking_ragdoll_game:
- **Location**: `/mnt/c/Users/Percision 15/talking_ragdoll_game`
- **Key Systems**: JSH Scene Tree, Universal Beings, Console Commands
- **Test Commands**: `universal`, `perfect`, `help`, `being interface asset_creator`
- **Known Issues**: Performance warnings (expected), JSH errors (FIXED)

### Expected Output:
```
✅ [UniversalEntity] Awakening after 2 years...
✅ [CONSOLE] Initializing with 50+ commands
✅ [JSHSceneTreeSystem] Scene tree monitoring setup complete
⚠️  [ArchitectureHarmony] High process usage warnings (expected)
```

## 🧠 **Learning Notes**

### What I Learned:
1. **MCP stop_project** translates to process management commands
2. **Always verify shutdown** - hanging processes cause problems
3. **Graceful vs force termination** - try gentle first, force if needed
4. **Process IDs change** - can't reuse old PIDs
5. **Multiple instances possible** - may need to stop all

### Future Improvements:
- Add timeout handling for long-running processes
- Implement automatic cleanup on session start
- Create wrapper scripts for common workflows
- Add process monitoring during development

---

*"Perfect workflow: Launch → Test → Learn → Stop → Document"*

Last Updated: 2025-05-29 - MCP stop workflow mastered