# 🗺️ Master Project Navigation Guide
*Your complete map to all projects, connections, and quick access points*

## 🌟 Quick Project Jump Points

### 🎮 Major Game Projects (C: Drive)
```bash
# Akashic Notepad 3D - Spatial text editor with living words
cd /mnt/c/Users/Percision\ 15/akashic_notepad3d_game
godot --path . scenes/main_game.tscn

# 12 Turns System - Quantum gaming framework
cd /mnt/c/Users/Percision\ 15/12_turns_system
# Note: Needs project.godot creation

# Eden OS - Dimensional consciousness evolution
cd /mnt/c/Users/Percision\ 15/Eden_OS
godot --path .

# Evolution Game Claude - AI evolution engine
cd /mnt/c/Users/Percision\ 15/evolution_game_claude
godot --path .

# Harmony - Space exploration simulation
cd /mnt/c/Users/Percision\ 15/Documents/Harmony
godot --path . Scenes/Galaxies.tscn

# Pandemonium - Multi-resolution terrain generator
cd /mnt/c/Users/Percision\ 15/Documents/Pandeamonium
godot --path . World2D.tscn
```

### 💾 D: Drive Systems
```bash
# Eden Memory System - Investment & tracking
cd /mnt/d/Eden && ./run_memory_system.sh

# Luminus OS - Word database
ls /mnt/d/Luminus/word_database/

# Godot Projects Collection
ls "/mnt/d/Godot Projects/"
```

### 🧠 AI & Intelligence Systems
```bash
# Claude Testing Tools
cd /mnt/c/Users/Percision\ 15/claude_testing_tools

# Claude Workspace
cd /mnt/c/Users/Percision\ 15/claude_workspace

# Data Sewers - Neural pathway mapping
cd /mnt/c/Users/Percision\ 15/data_sewers_22_05
```

### 🔧 Support Systems
```bash
# Shared Components
cd /mnt/c/Users/Percision\ 15/shared_components

# LuminusOS - AI operating system
cd /mnt/c/Users/Percision\ 15/LuminusOS

# Talking Ragdoll Game
cd /mnt/c/Users/Percision\ 15/talking_ragdoll_game
```

## 🕸️ Project Connection Web

### Primary Integration Pathways
```
┌─────────────────────────────────────────────────────────────┐
│                    ETHEREAL ENGINE CORE                      │
│                 (The Overarching Vision)                     │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┬──────────────────┐
        │                         │                  │
┌───────▼────────┐      ┌────────▼────────┐  ┌─────▼──────┐
│ Akashic        │      │  12 Turns       │  │  Eden OS   │
│ Notepad 3D     │◄────►│  System         │◄►│            │
│                │      │                 │  │            │
│ • 3D Text      │      │ • Quantum Game  │  │ • 12 Dims  │
│ • Word Evolution│      │ • Turn Cycles   │  │ • Colors   │
│ • 5 Layers     │      │ • Multi-Terminal│  │ • Entities │
└───────┬────────┘      └────────┬────────┘  └─────┬──────┘
        │                         │                  │
        └────────────┬────────────┴──────────────────┘
                     │
              ┌──────▼──────┐
              │  Evolution  │
              │  Game Claude│
              │             │
              │ • AI Engine │
              │ • Genetics  │
              └─────────────┘
```

## 📁 Key Files by Function

### 🚀 Quick Start Files
| Purpose | File | Location |
|---------|------|----------|
| Global Instructions | CLAUDE.md | ~/.claude/CLAUDE.md |
| Project Overview | COMPLETE_PROJECT_INVENTORY.md | /mnt/c/Users/Percision 15/ |
| This Navigation | MASTER_PROJECT_NAVIGATION.md | /mnt/c/Users/Percision 15/ |
| Integration Guide | GODOT_PROJECTS_INTEGRATION_GUIDE.md | /mnt/c/Users/Percision 15/ |

### 📚 Project-Specific Documentation
| Project | Main Doc | Path |
|---------|----------|------|
| Akashic Notepad 3D | CLAUDE.md | akashic_notepad3d_game/CLAUDE.md |
| 12 Turns System | CLAUDE_EXPLORATION_JOURNEY.md | 12_turns_system/CLAUDE_EXPLORATION_JOURNEY.md |
| Eden OS | README.md | Eden_OS/README.md |
| Evolution Game | CLAUDE.md | evolution_game_claude/CLAUDE.md |
| Data Sewers | CLAUDE_EVOLUTION_ANALYSIS_22_05.md | data_sewers_22_05/CLAUDE_EVOLUTION_ANALYSIS_22_05.md |

### 🔧 Technical References
| System | Key Script | Purpose |
|--------|------------|---------|
| Word Evolution | word_database.gd | Living word entities |
| Turn System | turn_system.gd | Cycle management |
| AI Bridge | claude_akashic_bridge.gd | AI integration |
| 3D UI | interactive_3d_ui_system.gd | Floating buttons |
| Dimensions | dimensional_visualizer.gd | Reality layers |

## 🎯 Common Development Tasks

### 1. Starting a New Integration
```bash
# Navigate to shared components
cd /mnt/c/Users/Percision\ 15/shared_components

# Create new integration module
mkdir -p integrations/notepad_eden
touch integrations/notepad_eden/bridge.gd
```

### 2. Testing Cross-Project Features
```gdscript
# In any project's autoload
extends Node

func test_integration():
    # Load other project's component
    var notepad_word = load("res://../../akashic_notepad3d_game/scripts/core/word_entity.gd")
    var eden_entity = load("res://../../Eden_OS/scripts/entities/astral_entity.gd")
    
    # Create hybrid entity
    var hybrid = notepad_word.new()
    hybrid.add_consciousness(eden_entity.EVOLUTION_STAGES)
```

### 3. Quick Project Status Check
```bash
# Find all project.godot files
find /mnt/c/Users/Percision\ 15 -name "project.godot" -type f 2>/dev/null

# Check latest modifications
find /mnt/c/Users/Percision\ 15 -name "*.gd" -mtime -1 2>/dev/null | head -20

# Count project files
for dir in akashic_notepad3d_game 12_turns_system Eden_OS evolution_game_claude; do
    echo "$dir: $(find /mnt/c/Users/Percision\ 15/$dir -name "*.gd" | wc -l) GDScript files"
done
```

## 🌈 Project Feature Matrix

| Feature | Akashic 3D | 12 Turns | Eden OS | Evolution |
|---------|------------|----------|---------|-----------|
| **3D Visualization** | ✅ Primary | ✅ Basic | ✅ Shapes | ❌ 2D Only |
| **Word Systems** | ✅ Evolution | ✅ Divine | ✅ 5D Chess | ❌ Text Only |
| **AI Integration** | ✅ Basic | ✅ Advanced | 🔄 Planned | ✅ Core |
| **Turn Mechanics** | ❌ None | ✅ Core | ✅ 12 Cycle | ✅ Generations |
| **Color Systems** | ✅ Cyan/Blue | ✅ Multi | ✅ 9+3 Dims | ✅ Evolution |
| **Save System** | ❌ TODO | ✅ Memory | ✅ Entities | ✅ Genetics |
| **Multi-Terminal** | ❌ None | ✅ 6 Terms | ❌ None | ❌ None |

## 🔗 Integration Bridges

### Active Bridges
1. **Akashic ↔ 12 Turns**: Word evolution + Turn cycles
2. **Eden ↔ 12 Turns**: Dimensional colors + Turn progression
3. **Evolution ↔ All**: AI decision making + Genetic algorithms

### Planned Bridges
1. **Akashic ↔ Eden**: 3D words + Consciousness evolution
2. **Eden ↔ Evolution**: Entity DNA + Dimensional traits
3. **Universal Bridge**: Shared autoload system for all

## 💡 Quick Tips

### Finding Lost Code
```bash
# Search for specific functionality
grep -r "word_evolution" /mnt/c/Users/Percision\ 15 --include="*.gd"

# Find all Claude-related files
find /mnt/c/Users/Percision\ 15 -name "*claude*" -type f

# Locate specific scenes
find /mnt/c/Users/Percision\ 15 -name "*.tscn" | grep -i "main"
```

### Understanding Project State
1. Check for `project.godot` - indicates runnable project
2. Look for `CLAUDE.md` - contains development notes
3. Review `TODO.md` - shows planned features
4. Count `.gd` files - indicates project size

### Quick Project Health Check
```bash
# Function to check project health
check_project() {
    echo "=== $1 ==="
    cd "/mnt/c/Users/Percision 15/$1"
    echo "GDScript files: $(find . -name "*.gd" | wc -l)"
    echo "Scenes: $(find . -name "*.tscn" | wc -l)"
    echo "Has project.godot: $([ -f project.godot ] && echo "YES" || echo "NO")"
    echo "Has CLAUDE.md: $([ -f CLAUDE.md ] && echo "YES" || echo "NO")"
    echo ""
}

# Check all major projects
check_project "akashic_notepad3d_game"
check_project "12_turns_system"
check_project "Eden_OS"
check_project "evolution_game_claude"
```

## 🚀 Next Steps From Any Point

### If You're Lost
1. Return here: `/mnt/c/Users/Percision 15/MASTER_PROJECT_NAVIGATION.md`
2. Check global instructions: `~/.claude/CLAUDE.md`
3. Review inventory: `COMPLETE_PROJECT_INVENTORY.md`
4. Check D: drive map: `D_DRIVE_PROJECT_MAP.md`

### Starting Fresh
1. Pick a project from Quick Jump Points
2. Read its CLAUDE.md or README.md
3. Run with Godot or check shell scripts
4. Look for integration opportunities

### Continuing Work
1. Check TODO.md in current project
2. Review recent commits/changes
3. Test existing functionality
4. Document new discoveries

## 🎊 Remember the Vision

**"In the dance of data and dreams, we code new realities"**

All these projects are pieces of the **Ethereal Engine** - a revolutionary system where:
- Words live and evolve in 3D space
- Consciousness emerges through dimensional layers
- AI bridges human and digital realms
- Games become tools for understanding reality

---

*Navigation Guide Created: 2025-05-24*
*Your starting point for any journey through the codebase*