# Unified Interface System - Grid = List = Console

## 🎯 Core Concept
**Everything is a command** - whether you click a grid cell, select from a list, or type in console!

## 📐 The 999 System

### Page Structure
- **999 items per page** maximum
- **Grid View**: 33×30 cells (990 items)
- **List View**: Scrollable with 50 visible
- **Console View**: Direct command access

### Why 999?
- Human-readable indexing
- Easy mental math (page 2 = items 1000-1998)
- Fits well in grids (30×33 ≈ 999)
- Leaves room for special items (000 = header)

## 🔄 Three-Layer State System

From your main.gd pattern:

```
ACTIVE   → Currently visible/in use
PENDING  → Loading or transitioning  
CACHED   → Ready for quick access
ARCHIVED → Long-term storage
```

### State Transitions
```
User requests item 2547:
1. Calculate: Page 2, Item 549
2. Check ACTIVE (not there)
3. Check CACHED (found!)
4. Move Page 2 from CACHED→ACTIVE
5. Display item at grid position (16,16)
```

## 🎮 Input Unification

### Visual Actions = Commands
| UI Action | Generated Command | Result |
|-----------|------------------|---------|
| Click cell (5,7) | `select grid:5,7` | Select item |
| Double-click | `execute grid:5,7` | Run item |
| Drag to (10,12) | `move grid:5,7 to grid:10,12` | Move item |
| Press Delete | `delete grid:5,7` | Remove item |
| Type "tree" | `create tree at cursor` | Spawn tree |

### Navigation Methods
1. **Mouse**: Click cells directly
2. **Keyboard**: Arrow keys or WASD
3. **Tab**: Cycle through items
4. **Console**: Type exact commands

## 🚦 Floodgate States

Your state management concept:
```gdscript
player_states = {
    "can_move_camera": true,    # Camera control
    "can_move_player": true,    # Player movement
    "menu_active": false,       # UI has focus
    "console_active": false,    # Console open
    "ui_active": false         # Any UI element
}
```

### State Logic
- **Menu Open** → Disable camera/player movement
- **Console Active** → Capture all keyboard input
- **UI Active** → Route input to UI elements

## 📊 Grid Calculations

### For 16:9 Screens
```
1920×1080: 
- Cell size: 58×36 pixels
- Grid: 33×30 cells
- Total: 990 cells per page

1280×720:
- Cell size: 38×24 pixels  
- Grid: 33×30 cells
- Total: 990 cells per page
```

### For Other Ratios
```
4:3 (iPad):
- Adjust to 32×31 grid (992 cells)
- Slightly larger cells

21:9 (Ultrawide):
- Extend to 42×23 grid (966 cells)
- Wider but shorter grid
```

## 🔗 Integration Examples

### Example 1: Spawn Entity
```
Visual: Click "Tree" in grid → Drag to world
Console: `create tree at 10,5,0`
Result: Same TreeController.spawn() call
```

### Example 2: Page Navigation
```
Visual: Click "Next Page" button
Keyboard: Press PageDown
Console: `page 3`
Result: Load page 3 from cache/pending
```

### Example 3: Multi-Select
```
Visual: Ctrl+Click multiple cells
Console: `select grid:1,1 grid:2,2 grid:3,3`
Result: Add items to selection array
```

## 💾 Implementation Status

### ✅ Created Systems
1. **UnifiedGridInterface** - Base 10×10 grid with adaptive borders
2. **UnifiedGridListSystem** - 999-item pages with three views
3. **MultiLayerRecordSystem** - Active/pending/cached/archived states
4. **GridListConsoleBridge** - Visual↔Command translation

### 🔧 Integration Points
```gdscript
# In project.godot, add autoloads:
MultiLayerRecords="*res://scripts/core/multi_layer_record_system.gd"
GridListBridge="*res://scripts/ui/grid_list_console_bridge.gd"
```

### 📝 Console Commands
```bash
# Navigation
page 2              # Go to page 2
next               # Next page
prev               # Previous page

# Selection  
select grid:5,10   # Select grid cell
select list:45     # Select list item
select ragdoll_1   # Select by ID

# Actions
create tree        # Spawn at cursor
move item_5 to 10,10  # Move item
delete selection   # Delete selected

# Modes
mode grid          # Switch to grid view
mode list          # Switch to list view
mode console       # Console only
```

## 🚀 Next Steps

1. **Wire up to existing console** - Add new commands
2. **Create example grid content** - Populate with ragdoll game items
3. **Test state transitions** - Verify active/pending/cached flow
4. **Add visual polish** - Smooth animations between states

## 🎨 Your Vision Realized

Your sketch showed:
- **Red zones** = Primary actions (always visible)
- **Yellow zones** = Context actions (mode-dependent)  
- **Green zones** = Content areas (scrollable)
- **White center** = Main 999-item grid/list

This system delivers exactly that - with the added power that every visual element is also a console command!

---
*"In the unity of interface, we find the freedom of expression"*