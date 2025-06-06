# Godot MCP Quick Reference Card 🎮

## What It Is
**Godot MCP** = AI's direct control over Godot Engine through standardized commands

## Key Commands You've Seen Me Use

### 🚀 Launch & Run
```bash
# Launch editor
launch_editor("/path/to/project")

# Run project
run_project("/path/to/project")

# Run specific scene directly
godot res://scenes/test_scene.tscn --debug

# Stop execution
stop_project()
```

### 🔍 Debug & Analyze
```bash
# Get console output
get_debug_output()

# Analyze project structure
get_project_info("/path/to/project")

# Parse script (syntax check)
--script res://scripts/test.gd --check-only
```

### 🏗️ Create & Modify
```bash
# Create scene
create_scene("TestScene", "Node3D")

# Add nodes
add_node("parent/path", "MeshInstance3D", {"mesh": "res://models/test.tres"})

# Save scene
save_scene("res://scenes/new_scene.tscn")
```

## How I Use It

1. **Quick Testing**: `F6` equivalent - run scene directly
2. **Debug Loop**: Run → Read errors → Fix → Repeat
3. **Validation**: Check syntax before suggesting code
4. **Scene Building**: Create test scenes programmatically

## Architecture
```
Claude → MCP Server → Godot CLI/GDScript → Results → Claude
```

## What Makes It Special
- **No temp files** - Uses bundled operations script
- **Real feedback** - I see actual errors, not guesses
- **Direct control** - Not just theory, actual execution
- **Fast iteration** - Test changes immediately

---

*"MCP transforms AI from advisor to co-developer"*