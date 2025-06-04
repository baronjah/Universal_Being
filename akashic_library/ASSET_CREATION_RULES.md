# 🎨 Universal Being Asset Creation Rules

## 📋 **CORE PRINCIPLES**

Every asset in Universal Being follows these sacred rules:

### 1. **PENTAGON ARCHITECTURE COMPLIANCE**
- All beings MUST use Pentagon functions: `pentagon_init/ready/process/input/sewers`
- NO Godot functions (`_ready`, `_process`, `_input`) in Universal Being files
- Core systems only may use Godot functions

### 2. **CONSCIOUSNESS LEVELS**
Every asset has consciousness (0-5):
```
0: Gray (Dormant) 
1: Pale (Awakening)
2: Blue (Aware)
3: Green (Connected) 
4: Gold (Enlightened)
5: White (Transcendent)
```

### 3. **ZIP PACKAGE FORMAT**
All assets are packaged as `.ub.zip` files containing:
```
asset_name.ub.zip/
├── manifest.json          # Required metadata
├── scripts/               # GDScript files
│   └── main_script.gd    # Primary asset script
├── scenes/               # Optional .tscn files
├── resources/            # Textures, materials, etc.
└── documentation.md      # Asset documentation
```

## 📄 **MANIFEST.JSON STRUCTURE**

```json
{
  "name": "Asset Name",
  "version": "1.0.0",
  "type": "being|component|scene|material",
  "consciousness_level": 1,
  "description": "What this asset does",
  "author": "JSH + Claude",
  "created": "2025-01-07",
  "dependencies": ["other_asset.ub.zip"],
  "pentagon_functions": ["pentagon_ready", "pentagon_process"],
  "export_properties": {
    "size": "Vector3",
    "color": "Color",
    "enabled": "bool"
  },
  "signals": ["interaction_started", "evolution_complete"],
  "evolution_targets": ["advanced_version.ub.zip"],
  "consciousness_traits": {
    "creativity": 0.8,
    "harmony": 0.6,
    "evolution_rate": 0.4
  }
}
```

## 🔧 **CREATION WORKFLOW**

1. **Design Phase**: Define consciousness level and behavior
2. **Structure Phase**: Create folder with proper manifest.json  
3. **Code Phase**: Write Pentagon-compliant scripts
4. **Package Phase**: ZIP into .ub.zip format
5. **Validate Phase**: Run asset checker
6. **Deploy Phase**: Place in appropriate assets/ folder

## 🎯 **VALIDATION CHECKLIST**

✅ **manifest.json present and valid**
✅ **Pentagon Architecture compliance**  
✅ **Consciousness level defined (0-5)**
✅ **No Godot lifecycle functions in beings**
✅ **Proper export properties**
✅ **Documentation included**
✅ **Dependencies listed**
✅ **Evolution targets defined**

## 📁 **ASSET CATEGORIES**

### **beings/**: Conscious entities
- Must extend UniversalBeing
- Use Pentagon functions only
- Have consciousness_level property
- Can evolve into other beings

### **components/**: Modular functionality  
- Extend Component class
- Attach to any Universal Being
- Follow Pentagon lifecycle
- Reusable across multiple beings

### **scenes/**: Complete environments
- .tscn files with metadata
- Can be loaded by beings
- Include spawn points
- Environment settings

### **materials/**: Visual components
- Shaders, textures, materials
- Consciousness-responsive
- Pentagon-controlled animations
- Dynamic property changes

## 🚀 **EXAMPLE ASSET: Simple Crystal Being**

```gdscript
# crystal_being.gd
extends UniversalBeing
class_name CrystalBeing

func pentagon_init() -> void:
    super.pentagon_init()
    being_name = "Crystal Being"
    being_type = "crystal" 
    consciousness_level = 2

func pentagon_ready() -> void:
    super.pentagon_ready()
    create_crystal_geometry()
    
func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    rotate_crystal(delta)
```

## ⚠️ **VIOLATIONS TO AVOID**

❌ Using `func _ready()` in Universal Being scripts
❌ Missing manifest.json file
❌ Undefined consciousness level
❌ No Pentagon functions
❌ Missing documentation
❌ Circular dependencies
❌ Invalid ZIP structure

Follow these rules and every asset will integrate perfectly with the Universal Being consciousness ecosystem! ✨