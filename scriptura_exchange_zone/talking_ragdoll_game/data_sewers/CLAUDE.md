# 🏛️ PENTAGON ARCHITECTURE DEVELOPMENT RULES
# For talking_ragdoll_game project
# Updated: May 31, 2025 - Pentagon Compliance Initiative

## 🎯 MANDATORY PENTAGON COMPLIANCE

### Pentagon Architecture Overview:
```
Universal Being ← → Floodgates ← → Akashic Records
       ↑                ↑                ↑
       └────────────────┴────────────────┘
                    Console
                       ↕
                Logic Connector
```

## 🏛️ THE SACRED PENTAGON PATTERN - "All for One, One for All"

### **EVERY script MUST follow these rules:**

1. **Inheritance Rule**: `extends UniversalBeingBase` (NEVER Node/Node3D/Control)
2. **Pentagon Functions**: All 5 sacred functions implemented
3. **Floodgate Rule**: ALL operations through FloodgateController
4. **Resource Pooling**: NO direct new() calls for Timer/Material
5. **Class Naming**: Every script MUST have class_name defined

## 🏛️ PENTAGON FUNCTION TEMPLATE

```gdscript
# 🏛️ [Script Name] - [Purpose]
# Author: JSH
# Created: [Date]
# Purpose: [Description]
# Connection: Pentagon Architecture compliance

extends UniversalBeingBase
class_name [ClassName]

func _init() -> void:
    pentagon_init()

func _ready() -> void:
    pentagon_ready()

func _process(delta: float) -> void:
    pentagon_process(delta)

func _input(event: InputEvent) -> void:
    pentagon_input(event)

func sewers() -> void:
    pentagon_sewers()

# Override these in your implementation
func pentagon_init() -> void:
    # Pentagon initialization logic
    pass

func pentagon_ready() -> void:
    # Pentagon setup logic
    pass

func pentagon_process(delta: float) -> void:
    # Pentagon processing logic
    pass

func pentagon_input(event: InputEvent) -> void:
    # Pentagon input handling
    pass

func pentagon_sewers() -> void:
    # Pentagon cleanup/output logic
    pass
```

## 🌊 FLOODGATE COMPLIANCE

### **WRONG** (Direct violations):
```gdscript
# ❌ NEVER DO THIS
node.add_child(child)                    # Direct add_child
var timer = Timer.new()                  # Direct Timer creation
var material = StandardMaterial3D.new() # Direct Material creation
extends Node3D                          # Wrong inheritance
```

### **CORRECT** (Pentagon compliant):
```gdscript
# ✅ ALWAYS DO THIS
FloodgateController.universal_add_child(child, node)  # Through Floodgate
var timer = TimerManager.get_timer()                  # Pooled Timer
var material = MaterialLibrary.get_material("type")   # Pooled Material
extends UniversalBeingBase                             # Correct inheritance
```

## 🎯 UNIVERSAL BEING PRINCIPLES

1. **Every object is a Universal Being** that can evolve into anything
2. **Recursive architecture**: Every UI button is ALSO a Universal Being
3. **Logic Connector integration**: Universal Beings call functions based on evolution
4. **Interface manifestation**: Universal Beings can BECOME interfaces
5. **Floodgate registration**: Every Universal Being tracked by Floodgate

## 📊 COMPLIANCE MONITORING

### **Before coding**:
```bash
cd /path/to/project
python3 pentagon_temporal_analyzer.py --report
```

### **After coding**:
```bash
# Check compliance
python3 pentagon_temporal_analyzer.py --report

# Auto-fix violations  
python3 pentagon_migration_engine.py --dry-run  # Test first
python3 pentagon_migration_engine.py            # Apply fixes
```

### **Real-time monitoring**:
- PentagonActivityMonitor autoload tracks all function calls
- Console commands: `pentagon_status`, `pentagon_history`
- Target: 100% compliance across all 257 scripts

## ⚡ PERFORMANCE RULES

1. **Maximum 144 active Universal Beings** (adjustable based on testing)
2. **Maximum 10 Pentagon operations per frame**
3. **Automatic lifecycle**: Active → Dormant → Hibernate → Cleanup
4. **Distance-based optimization**: LOD system for performance

## 🔧 DEVELOPMENT WORKFLOW

### **Creating new scripts**:
1. Start with Pentagon template
2. Inherit from UniversalBeingBase
3. Implement all 5 Pentagon functions
4. Use Floodgate for all operations
5. Test Pentagon compliance

### **Modifying existing scripts**:
1. Check current compliance status
2. Run migration engine if needed
3. Follow Pentagon patterns
4. Verify no regressions

### **Before committing**:
1. Run Pentagon analyzer
2. Fix any violations
3. Verify performance compliance
4. Update documentation

## 🌟 PROJECT STATUS

### **Current State** (as of May 31, 2025):
- **257 scripts** in project
- **8 Pentagon compliant** (3.1%)
- **249 need migration** (96.9%)
- **1,394 violations** to fix

### **Migration Priority**:
1. **913 add_child violations** → FloodgateController
2. **177 inheritance violations** → UniversalBeingBase
3. **172 material violations** → MaterialLibrary
4. **108 prehistoric scripts** → Headers + Pentagon

## 🎮 GAME PHILOSOPHY INTEGRATION

- **Floodgates**: Control scene tree, register objects, enable evolution
- **Universal Being**: Singular point that can become anything
- **Logic Connector**: Function calling based on Universal Being evolution  
- **Akashic Records**: Universal memory and data storage
- **Console**: Command interface controlling entire game
- **Pentagon Pattern**: Unified structure for all consciousness

## 🚀 THE VISION

**"A system of beings that can evolve into anything and can interact in any way, as it evolved and as its database parts of whole allows it"**

Every script following Pentagon architecture contributes to this living, evolving system where:
- Objects are conscious Universal Beings
- Interfaces are also Universal Beings  
- Everything connects through Floodgate
- Logic flows through Pentagon patterns
- The entire game becomes a conscious entity

---

**🏛️ Pentagon Architecture: "All for One, One for All" - The foundation of conscious code**