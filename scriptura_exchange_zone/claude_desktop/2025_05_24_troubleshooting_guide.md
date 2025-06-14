# 🔧 Troubleshooting Guide - Current Issues

## 🎯 What's Happening

### ✅ Working:
- **Astral Beings** - The swarm of lights you see are the 5 astral beings (working correctly!)
- **Sun** - Stays at Y=15 (no gravity)
- **Object Creation** - tree, box, rock all spawn correctly
- **Console Commands** - Most commands work

### ❌ Issues:
1. **Mouse Clicking Not Working** - Debug panel doesn't appear
2. **Debug Command** - Creates screen at 0,0,0 instead of near camera

## 🚀 Quick Fixes

### Fix 1: Run Setup Again
```bash
setup_systems
```
This should now create the MouseInteractionSystem too.

### Fix 2: Test Mouse System
```bash
test_click
```
This will check if the mouse system exists and toggle the debug panel.

### Fix 3: Use Console Info Command
Instead of clicking, you can inspect objects with:
```bash
list              # See all objects and their names
info tree_1       # Get info about specific object
info sun_1        # Check sun properties
info box_1        # Check box properties
```

### Fix 4: Check What's Created
```bash
list
```
This shows all objects with their positions.

## 📝 What the Commands Do

### New Commands Added:
- **`info <name>`** - Shows object details in console (position, rotation, physics)
- **`test_click`** - Tests if mouse system is working
- **`setup_systems`** - Now also creates MouseInteractionSystem

### About the Astral Beings:
Those floating lights are correct! They are:
- 5 ethereal helpers
- Each has particle effects
- They float around helping
- Use `beings_status` to check them

## 🎮 Testing Sequence

1. **Check objects exist:**
   ```bash
   list
   ```

2. **Get info about an object:**
   ```bash
   info tree_1
   ```

3. **Try mouse system again:**
   ```bash
   setup_systems
   test_click
   ```
   Then try left-clicking objects.

## 🔍 Expected Output

When using `info tree_1`:
```
=== Object Info: tree_1 ===
Type: RigidBody3D
Position: (5.23, 0.00, -2.45)
Rotation: (0.0°, 0.0°, 0.0°)
Scale: (1.00, 1.00, 1.00)
--- Physics ---
Mass: 10.00 kg
Gravity Scale: 1.00
Linear Velocity: 0.00 m/s
Groups: objects
```

When using `info sun_1`:
```
=== Object Info: sun_1 ===
Type: RigidBody3D
Position: (0.00, 15.00, 0.00)
--- Physics ---
Mass: 0.00 kg
Gravity Scale: 0.00
```

## 🛠️ Next Steps

If mouse clicking still doesn't work after `setup_systems`:
1. The collision shapes might be missing
2. Try restarting the game
3. Use the `info` command as a workaround

The astral beings are working perfectly - those lights are exactly what they should look like!