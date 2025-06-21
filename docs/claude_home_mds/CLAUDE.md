# 🐧 WSL Ubuntu Sacred Ground - Universal Rules
## The Linux Sanctuary for the Dream Game

> *Connected to the main game realm and knowledge temple*

---

## 🗺️ **Navigation Between Sacred Places**

### Quick Jump Commands:
```bash
# To Main Game (The Active Dream)
cd "/mnt/c/Users/Percision 15/talking_ragdoll_game"

# To Knowledge Temple (Memory Palace)  
cd "/mnt/c/Users/Percision 15/Desktop/claude_desktop"

# To D: Drive Universe (The Archive)
cd "/mnt/d/"

# Back to Linux Home (Here)
cd ~
```

---

## 🎮 **Linux Development Rules**

### When Working in WSL:
1. **Git operations** - Safest here, no Windows filesystem issues
2. **Package installations** - npm, pip, apt packages
3. **Script testing** - Bash scripts and automation
4. **Config management** - .bashrc, .profile modifications

### Linux-Specific Commands:
```bash
# Quick game startup
alias ragdoll='cd "/mnt/c/Users/Percision 15/talking_ragdoll_game" && godot --path .'

# Architecture check
alias harmony='cd "/mnt/c/Users/Percision 15/talking_ragdoll_game" && echo "Current project status:"'

# Navigate to desktop knowledge
alias knowledge='cd "/mnt/c/Users/Percision 15/Desktop/claude_desktop"'
```

---

## ⚡ **Universal Rules (Apply Everywhere)**

### 🎯 Perfect Delta Process Rule
- NO `_process()` or `_physics_process()` in any script
- Register with `PerfectDeltaProcess.register_process()`
- Physics remain accurate with accumulated delta

### 🎭 Architecture Harmony
- ONE implementation per feature type
- biowalker = best ragdoll
- Check `arch_status` before creating new

### 🌟 Scribble → UFO Evolution
- Start rough, evolve to perfection
- Every feature follows transformation path
- User creates, system perfects

---

## 📁 **Project Structure Awareness**

### Main Game Structure:
```
/mnt/c/Users/Percision 15/talking_ragdoll_game/
├── scripts/core/           # Core systems
├── scripts/autoload/       # Global systems  
├── scripts/ui/            # Interface systems
├── scripts/ragdoll/       # Character physics
├── scenes/                # Game scenes
└── PROJECT_RULES.md       # The sacred document
```

### Desktop Knowledge:
```
/mnt/c/Users/Percision 15/Desktop/claude_desktop/
├── ethereal_navigation_hub/  # Project navigation
├── eden_explanations/        # Eden project docs
├── godot_classes/           # Complete API reference
└── [200+ documentation files]
```

---

## 🔧 **Linux-Specific Helpers**

### Development Shortcuts:
```bash
# Monitor game performance from Linux
function game_status() {
    echo "🎮 Game Status Check:"
    echo "Current directory: $(pwd)"
    echo "Git status:"
    git status --porcelain 2>/dev/null || echo "Not a git repo"
    echo "Recent files:"
    ls -lat | head -5
}

# Quick file search across all sacred places
function find_dream() {
    find "/mnt/c/Users/Percision 15/talking_ragdoll_game" -name "*$1*" 2>/dev/null
    find "/mnt/c/Users/Percision 15/Desktop/claude_desktop" -name "*$1*" 2>/dev/null
    find "/mnt/d" -name "*$1*" 2>/dev/null
}
```

---

## 🌐 **Connection Points**

### To Main Game:
- All development happens there
- PerfectDeltaProcess manages everything
- Console commands control the dream

### To Desktop Knowledge:
- Documentation and navigation
- Historical context and evolution
- Breakthrough records and guides

### To D: Drive:
- Extended archives and large projects
- Future expansion space
- ADDONS, BECOME, Creations folders

---

*From the Linux sanctuary, we connect all realms of the dream*
*Last updated: May 28, 2025 - Sacred places unified*