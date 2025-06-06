# Godot MCP Technical Spec

## Core Components

### 1. MCP Server (Node.js)
- Path: `/godot-mcp/build/index.js`
- Protocol: JSON-RPC over stdio
- Operations: 15+ Godot commands

### 2. Operations Script
- File: `godot_operations.gd`
- Type: Bundled GDScript
- Input: JSON parameters
- Output: JSON results

### 3. Available Tools

| Tool | Purpose | Example |
|------|---------|---------|
| `launch_editor` | Open Godot | `launch_editor(project_path)` |
| `run_project` | Debug mode | `run_project(project_path, scene?)` |
| `get_debug_output` | Console logs | Returns array of output lines |
| `create_scene` | New .tscn | `create_scene(name, root_type)` |
| `add_node` | Add to scene | `add_node(parent, type, props)` |
| `stop_project` | Kill process | `stop_project()` |

### 4. Environment Variables
- `GODOT_PATH`: Override auto-detection
- `DEBUG`: Enable verbose logging

### 5. Auto-Approved Operations
All operations are pre-approved for seamless workflow.

---

**Integration**: MCP server starts automatically when AI needs Godot access.