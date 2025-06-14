# Grid Interface Testing Guide

## 🎮 Testing Ragdoll with Grid System

### Quick Test Flow
1. **Launch the game**
2. **Open Grid UI** (if not already visible)
3. **Select Ragdoll** from entity browser (top row)
4. **Click grid cell** to place ragdoll
5. **Test movement** with console commands

### Console + Grid Workflow
```bash
# F1 for console
# After placing ragdoll via grid:
ragdoll_move forward
ragdoll_move backward
ragdoll_jump
ragdoll_state
```

### Grid Features to Test
- **Entity Selection**: Click different entities in top row
- **Visual Feedback**: Look for color changes (Green/Blue)
- **Grid Placement**: Click cells 0-199 to place entities
- **Multiple Entities**: Place ragdoll, then trees, rocks, etc.

### Expected Behavior
- Ragdoll should spawn at clicked grid position
- Should maintain physics when placed
- Movement commands should work regardless of placement method
- Grid should show visual feedback on hover/click

### Testing Different Entities
1. **Ragdoll** - Full physics, movement commands
2. **Tree** - Static placement
3. **Fire** - Visual effect at position
4. **Bird** - AI behavior
5. **Rock/Cube** - Physics objects

### Advanced Tests
- Place multiple ragdolls (see if old one is removed)
- Place objects near ragdoll for interaction
- Test grid on screen edges
- Try placing while ragdoll is moving

### Debug Info
```bash
# Console commands to verify placement
list              # Show all spawned objects
tree              # Traditional spawn (compare with grid)
Tab               # Physics debug info
ragdoll_debug on  # Visual debug mode
```

## 🐛 Potential Issues & Solutions

### If Ragdoll Doesn't Appear:
1. Check if ragdoll was already spawned
2. Try `setup_systems` first
3. Click a different grid cell
4. Check console for errors

### If Grid Not Visible:
- Look for UI toggle button
- Check if it's behind console
- Try windowed mode vs fullscreen

### If Movement Doesn't Work:
- Ensure ragdoll is selected/spawned
- Try `ragdoll_stand` first
- Check if physics is paused

## 🎯 Grid Interface Goals

### Current Implementation (Working):
✅ 20×10 grid (200 cells)
✅ 12 entity types
✅ Visual selection feedback
✅ Click-to-place system

### Next Enhancements:
- Visual thumbnails for entities
- Ghost preview on hover
- Properties panel for tweaking
- Multi-cell entity support

## 💡 Testing Combinations

### Ragdoll + Environment:
```bash
# Place via grid:
# 1. Ragdoll at cell 100
# 2. Trees at cells 80, 120
# 3. Rocks at cells 90, 110
# Then:
ragdoll_move forward  # Navigate obstacles
```

### Physics Testing:
```bash
# Place via grid:
# 1. Ragdoll at cell 50
# 2. Cube at cell 70
# 3. Ball at cell 90
# Then:
ragdoll_move forward  # Push objects
ragdoll_jump         # Land on objects
```

This grid interface is a game-changer for the project - it makes entity placement intuitive and visual, just like Bryce!