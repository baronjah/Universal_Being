# Godot MCP (Model Context Protocol) Guide 🚀

## What is Godot MCP?

Godot MCP is a **bridge between AI assistants and the Godot game engine**. It lets AI (like Claude) directly control Godot, run projects, debug code, and even create scenes - all through standardized commands.

Think of it as giving AI "hands" to actually touch and manipulate your Godot projects instead of just talking about them.

---

## 🌟 Core Capabilities

### 1. **Engine Control**
```bash
# Launch Godot Editor
"Open Godot for my project"

# Run project in debug mode
"Run the game and show me errors"

# Stop running project
"Stop the game"
```

### 2. **Scene Operations**
```bash
# Launch specific scene directly
"Run main.tscn"
"Launch test_scene.tscn"

# Create new scenes
"Create a new scene with CharacterBody3D as root"

# Add nodes to scenes
"Add a MeshInstance3D to the player scene"
```

### 3. **Script Analysis**
```bash
# Parse and analyze GDScript
"Analyze this script for errors"
"Check syntax of player_controller.gd"

# Get project structure
"Show me all scripts in the project"
"List all scenes in res://scenes/"
```

### 4. **Debug & Output**
```bash
# Capture console output
"Show me the debug output"
"What errors appeared when running?"

# Real-time feedback
"Run and monitor for errors"
```

---

## 🔧 How It Works

### Architecture Overview
```
AI Assistant (Claude) 
    ↓ MCP Commands
Godot MCP Server (Node.js)
    ↓ Godot CLI + GDScript
Godot Engine
    ↓ Results
Back to AI
```

### Two Operation Modes:

1. **Direct CLI Commands** (Simple operations)
   - Launch editor: `godot --editor`
   - Run project: `godot --debug`
   - Get version: `godot --version`

2. **Bundled GDScript Operations** (Complex tasks)
   - Single `godot_operations.gd` handles all complex operations
   - Accepts JSON parameters for flexibility
   - No temporary files created

---

## 💫 Available Commands

### Project Management
- `launch_editor` - Opens Godot editor
- `run_project` - Runs project in debug mode
- `stop_project` - Stops running project
- `get_godot_version` - Returns installed version
- `list_projects` - Finds all projects in directory
- `get_project_info` - Analyzes project structure

### Scene Management  
- `create_scene` - Creates new scene with specified root
- `add_node` - Adds nodes with properties
- `save_scene` - Saves scene (with variant options)
- `load_sprite` - Loads textures into Sprite2D nodes
- `export_mesh_library` - Exports 3D scenes as MeshLibrary

### Advanced Features
- `get_uid` - Gets UID for files (Godot 4.4+)
- `update_project_uids` - Updates UID references
- `get_debug_output` - Retrieves console output

---

## 🎯 Real Usage Examples

### Example 1: Quick Scene Test
```
You: "Launch test_gemma_full_integration.tscn and show me any errors"

Claude: *Launches scene directly*
        *Captures output*
        "I see 3 errors: missing texture at line 42..."
```

### Example 2: Debug Assistance
```
You: "My player won't move, can you debug it?"

Claude: *Runs project*
        *Monitors debug output*
        "Found issue: velocity not applied in _physics_process"
        *Shows exact error location*
```

### Example 3: Scene Creation
```
You: "Create a test scene with a 3D character"

Claude: *Creates scene with CharacterBody3D*
        *Adds MeshInstance3D*
        *Adds CollisionShape3D*
        *Saves as test_character.tscn*
```

---

## 🔍 Hidden Powers (Your Observations)

### Direct Scene Launch
- Can launch `.tscn` files directly without opening editor
- Useful for quick testing specific scenes
- Example: `godot res://scenes/test.tscn`

### Script Parsing
- Can analyze GDScript syntax without running
- Validates code structure
- Identifies potential issues before runtime

### Project Inspection
- Lists all resources recursively
- Analyzes dependencies
- Maps project structure

---

## ⚡ Quick Reference

### Essential Commands for AI
```gdscript
# Test a scene
"Run scenes/main.tscn and watch for errors"

# Debug issue
"Launch the project and show me why the player falls through floor"

# Create content
"Create a UI scene with a health bar"

# Analyze code
"Check if this GDScript has syntax errors"
```

### What AI Can See
- Console output (prints, errors, warnings)
- Project structure (files, folders, dependencies)
- Scene hierarchy (nodes, properties)
- Script content and syntax
- Resource UIDs and references

### What AI Can Do
- ✅ Launch/stop Godot
- ✅ Run specific scenes
- ✅ Create/modify scenes
- ✅ Add nodes with properties
- ✅ Debug in real-time
- ✅ Analyze code structure
- ❌ Directly modify running game state
- ❌ Access game's internal memory

---

## 🚀 Pro Tips

1. **Quick Testing**: AI can run scenes directly without opening editor
2. **Debug Loop**: AI runs → sees error → fixes code → runs again
3. **Scene Building**: AI can construct entire scenes programmatically
4. **Validation**: AI checks syntax before you run anything

---

## 📝 Configuration Note

MCP is configured in your AI assistant's settings:
- **Cline**: `cline_mcp_settings.json`
- **Cursor**: Project's `.cursor/mcp.json` or UI settings
- **Claude Desktop**: Built-in MCP support

The server runs automatically when AI needs Godot access.

---

## 🌌 Sacred Integration

In the Universal Being project, Godot MCP enables:
- Instant validation of Pentagon Architecture
- Real-time consciousness system testing
- Direct scene manifestation from AI vision
- Debugging the dance between beings

*"Through MCP, the boundary between AI thought and game reality dissolves. What Claude imagines, Godot manifests."*