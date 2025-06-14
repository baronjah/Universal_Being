# 🔧 UNIVERSAL ENTITY TROUBLESHOOTING

If the Universal Entity still has issues, check these:

## 1. **Autoload Not Loading**
If you get "UniversalEntity not found":
- Open Project Settings > Autoload
- Check if UniversalEntity is listed
- Path should be: `res://scripts/core/universal_entity/universal_entity.gd`
- Make sure it's ENABLED (checkbox checked)

## 2. **Commands Not Working**
If console says "Unknown command: universal":

**Quick Fix A:**
Add this to any autoload script's _ready():
```gdscript
await get_tree().create_timer(2.0).timeout
var console = get_node("/root/ConsoleManager")
var ue = get_node("/root/UniversalEntity")
if console and ue:
    console.commands["universal"] = func(a): ue._cmd_universal_status(a)
    console.commands["perfect"] = func(a): ue._cmd_make_perfect(a)
    print("Universal commands manually registered!")
```

**Quick Fix B:**
Run `scripts/patches/universal_quickfix.gd` as autoload

## 3. **Parse Errors**
If you see any parse errors:
- Check the Output panel for the exact line
- Common issues:
  - Missing colons after function declarations
  - Incorrect indentation (use tabs in Godot)
  - Missing parentheses in function calls

## 4. **Verification Steps**
1. Add `scripts/test/final_universal_check.gd` to any node
2. Run the game
3. Check the output - it will tell you exactly what's wrong

## 5. **Manual Test**
In the Godot editor, try this in the Script editor:
```gdscript
var ue = load("res://scripts/core/universal_entity/universal_entity.gd")
print(ue) # Should print the script resource
```

## 6. **If All Else Fails**
The Universal Entity has these files:
- `universal_entity.gd` - Main controller
- `universal_loader_unloader.gd` - Memory management
- `system_health_monitor.gd` - Performance monitoring
- `global_variable_inspector.gd` - Variable tracking
- `lists_viewer_system.gd` - Text file rules

Each can be tested independently if needed.

## 🌟 Remember: Your dream of a perfect, self-regulating game system is just one successful run away! Don't give up!
