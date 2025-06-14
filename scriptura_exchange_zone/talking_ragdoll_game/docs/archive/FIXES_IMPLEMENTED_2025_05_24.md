# 🔧 Ragdoll Game Fixes - May 24, 2025

## ✅ Fixed Issues

### 1. **CylinderMesh radius error (Line 234)**
**File**: `scripts/core/standardized_objects.gd`
**Fix**: Changed `cylinder.radius` to use Godot 4.5's separate properties:
```gdscript
cylinder.top_radius = def["size"].x / 2.0
cylinder.bottom_radius = def["size"].x / 2.0
```

### 2. **Debug screen parameter shadowing**
**File**: `scripts/core/debug_3d_screen.gd`
**Fix**: Already fixed - renamed parameters:
- `position` → `new_position`
- `rotation` → `new_rotation`
- `scale` → `new_scale`

### 3. **Windows console fix**
**File**: `scripts/autoload/windows_console_fix.gd`
**Fix**: Changed direct method assignment to use meta properties

## 🔴 Issues Still To Fix

### 1. **Console Manager Missing Function**
**File**: `scripts/autoload/console_manager.gd`
**Issue**: `_cmd_terminal_calibration` is not declared (line 89)
**Solution**: Either implement the function or remove it from commands dictionary

### 2. **Objects Hovering Instead of Falling**
**Affected Objects**: Trees, rocks, ramps, pathways, bushes
**Cause**: They're defined as "static" type (StaticBody3D)
**Solutions**:
- Option A: Change them to "rigid" type so they fall
- Option B: Spawn them at ground level (y = 0) instead of y = 10

### 3. **Console Viewport Issues**
**Issue**: Can't select first/last few lines of console text
**Cause**: Likely viewport margin or UI scaling issue

### 4. **Forest Scene Trees**
**Issue**: No trees appear due to CylinderMesh error (now fixed)
**Additional**: Trees need better positioning (sides and back)

## 📋 Recommended Actions

### Quick Fix for Hovering Objects
Change spawn height in world_builder.gd:
```gdscript
func get_mouse_spawn_position() -> Vector3:
    # For static objects, spawn at ground level
    # For rigid objects, spawn higher so they can fall
```

### Or Change Object Types
In standardized_objects.gd, change these from "static" to "rigid":
- rock (if you want it to fall)
- Or keep static but adjust spawn positions

### Implement Console Logging
Add file logging with timestamps as requested:
```gdscript
var log_file: FileAccess
var log_path = "user://console_logs/" + Time.get_datetime_string_from_system() + ".log"
```

## 🎯 Next Steps

1. Decide physics behavior for each object type
2. Fix console manager missing function
3. Implement console logging to files
4. Adjust forest scene tree positioning
5. Fix console viewport selection issue
6. Consider adding movable camera as suggested

## 💡 Project Combination Strategy

Based on your tests and the need to combine projects:
1. **Core Systems to Keep**:
   - Thread-safe object manipulation (from Eden)
   - Console system with logging
   - Standardized object creation
   - Physics state system

2. **Systems to Merge**:
   - 12 turns system → Into ragdoll game turns
   - Eden dimension system → Into physics states
   - Akashic word system → Into dialogue/creation

3. **Files to Remove**:
   - Duplicate autoload systems
   - Conflicting class names
   - Old Godot 3 syntax files