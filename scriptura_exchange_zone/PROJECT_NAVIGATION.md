# Project Navigation Guide

## 🎮 Main Godot Project - Universal Being
**Location:** `C:\Users\Percision 15\Universal_Being`

### Project Structure:
- **Main Scene:** `res://main.tscn`
- **Main Node:** "Main"
- **Main Script:** `res://main.gd`

### Autoloads:
- **SystemBootstrap:** `res://autoloads/SystemBootstrap.gd`
- **GemmaAI:** `res://autoloads/GemmaAI.gd`

---

## 📚 Knowledge Stronghold - Claude Desktop
**Location:** `C:\Users\Percision 15\Desktop\claude_desktop`

### Important Subdirectories:
- **Universal Being Origin:** `C:\Users\Percision 15\Desktop\claude_desktop\kamisama_messages\New_Month_New_Game`
  - Contains the original conversation that created the Universal Being project

- **Godot Classes Reference:** `C:\Users\Percision 15\Desktop\claude_desktop\godot_classes`
  - Offline documentation for Godot classes

---

## 🚀 Quick Access Commands

### Open Universal Being Project:
```bash
cd "C:\Users\Percision 15\Universal_Being"
```

### Open Claude Desktop:
```bash
cd "C:\Users\Percision 15\Desktop\claude_desktop"
```

### Open Original Conversation:
```bash
cd "C:\Users\Percision 15\Desktop\claude_desktop\kamisama_messages\New_Month_New_Game"
```

### Open Godot Classes Reference:
```bash
cd "C:\Users\Percision 15\Desktop\claude_desktop\godot_classes"
```

---

## 🔗 Core System Dependencies

### SystemBootstrap → Core Systems:
```
SystemBootstrap
├── UniversalBeing (core class)
├── FloodGates (system instance)
└── AkashicRecords (system instance)
```

### Main → SystemBootstrap:
```
Main
├── Waits for SystemBootstrap.ready
├── Creates demo beings through SystemBootstrap
└── Uses SystemBootstrap for being creation
```

### Main → GemmaAI:
```
Main
├── Connects to GemmaAI.ai_message
├── Uses GemmaAI for being inspection
└── Notifies GemmaAI of being creation
```

### GemmaAI → SystemBootstrap:
```
GemmaAI
├── Waits for SystemBootstrap
├── Uses SystemBootstrap for being operations
└── Accesses FloodGates through SystemBootstrap
```

---

*Last Updated: February 6, 2025*