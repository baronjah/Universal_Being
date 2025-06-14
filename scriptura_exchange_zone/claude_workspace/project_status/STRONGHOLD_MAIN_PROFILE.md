# 🏰 Main Profile Stronghold Guide

> Your primary development fortress - where all projects unite

## 🚨 Quick Cleanup Actions

### Move Documentation Files
```bash
# Create docs folder if needed
mkdir -p documentation/navigation documentation/guides documentation/status

# Move navigation files
mv MASTER_PROJECT_NAVIGATION.md QUICK_ACCESS_*.md documentation/navigation/
mv *_GUIDE.md documentation/guides/
mv *_STATUS_*.md *_SUMMARY_*.md documentation/status/
```

### Organize Godot Projects
```bash
# Create organized structure
mkdir -p godot_projects/active godot_projects/experimental

# Move active projects
mv talking_ragdoll_game godot_projects/active/
mv akashic_notepad3d_game godot_projects/active/
mv Eden_OS godot_projects/active/
```

## 📁 Current Project Map

### 🎮 Active Game Projects
| Project | Path | Purpose | Status |
|---------|------|---------|--------|
| **Talking Ragdoll** | `talking_ragdoll_game/` | Console creation game | 🟢 Active Development |
| **Akashic Notepad3D** | `akashic_notepad3d_game/` | 3D spatial text editor | 🟢 95% Complete |
| **Eden OS** | `Eden_OS/` | Dimensional consciousness | 🟡 Integration Phase |
| **12 Turns System** | `12_turns_system/` | Turn-based mechanics | 🔴 Needs Cleanup |

### 📚 Documentation Hub
- `CLAUDE.md` - Your personal Claude instructions
- `documentation/navigation/` - All navigation guides
- `documentation/guides/` - Project guides
- `documentation/status/` - Daily summaries

### 🛠️ Shared Resources
- `shared_components/` - Reusable Godot components
- `addons/` - Godot addons
- `backups/` - Project backups

## 🎯 Quick Commands

### Jump to Active Projects
```bash
# Ragdoll game (today's focus)
cd /mnt/c/Users/Percision\ 15/talking_ragdoll_game

# Notepad3D 
cd /mnt/c/Users/Percision\ 15/akashic_notepad3d_game

# Eden OS
cd /mnt/c/Users/Percision\ 15/Eden_OS
```

### Find Project Files
```bash
# List all Godot projects
find . -name "project.godot" -type f 2>/dev/null | grep -v ".local"

# Find all scene files
find . -name "*.tscn" -type f | wc -l

# Locate specific scripts
find . -name "*ragdoll*.gd" -type f
```

### Clean Up Duplicates
```bash
# Find duplicate GD files
find . -name "*.gd" -type f -exec basename {} \; | sort | uniq -d

# Locate backup files
find . -name "*.bak" -o -name "*backup*" -type f
```

## 🧹 12_turns_system Cleanup Plan

The `12_turns_system/` folder needs major organization:

### Current Issues:
- 300+ files in root directory
- Mixed file types (.gd, .sh, .html, .js, .py)
- Multiple systems tangled together

### Suggested Structure:
```
12_turns_system/
├── core/              # Core game mechanics
├── ui/                # UI components
├── terminal/          # Terminal interfaces
├── connectors/        # System connectors
├── visualization/     # HTML/JS visualizers
├── scripts/           # Shell scripts
├── docs/              # Documentation
└── archive/           # Old implementations
```

## 🔗 Stronghold Connections

### To Claude Desktop
```bash
cd Desktop/claude_desktop/
# or
cd /mnt/c/Users/Percision\ 15/Desktop/claude_desktop/
```

### To D: Drive Systems
```bash
# Eden Memory System
cd /mnt/d/Eden/

# Luminus Word Database
cd /mnt/d/Luminus/
```

## 💡 Learning from Past Solutions

### Common Patterns Found:
1. **Console Integration** - Most projects use console commands
2. **Autoload Conflicts** - Watch for duplicate autoloads
3. **Signal Architecture** - Projects communicate via signals
4. **Process Optimization** - Limit _process() functions

### Reusable Solutions:
- Background process manager pattern
- Safe input checking functions
- Console command registration
- Scene management systems

## 📊 Project Statistics

```bash
# Count all GDScript files
find . -name "*.gd" -type f | wc -l
# Result: 500+ files

# Total project size
du -sh talking_ragdoll_game Eden_OS akashic_notepad3d_game
# Significant codebases

# Documentation files
find . -name "*.md" -type f | wc -l
# Result: 50+ docs
```

## 🚀 Tomorrow's Quick Start

1. **Open Ragdoll Game**
   ```bash
   cd talking_ragdoll_game
   godot --path . scenes/main_game.tscn
   ```

2. **Check Documentation**
   ```bash
   cat docs/TOMORROW_QUICK_START.md
   ```

3. **Review Recent Changes**
   ```bash
   find . -type f -mtime -1 | grep -E "\.(gd|md)$"
   ```

---

*Last Updated: May 25, 2025*
*"In the main stronghold, all projects converge"*