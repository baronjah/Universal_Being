# Universal Interface System Navigation
**For All AI Working on Universal Being Project**

## 🎯 **The Universal Law: All Interfaces Must Follow Standards**

### **CRITICAL RULE**: Never Create Raw Windows

❌ **WRONG**:
```gdscript
var window = Window.new()  # Raw window - breaks standards
```

✅ **CORRECT**:
```gdscript
var config = {
    "id": "my_interface",
    "title": "My Interface",
    "theme": "default",
    "layer": "game_ui",
    "esc_closes": true,
    "moveable": true
}
var window = UniversalInterfaceManager.create_universal_window(config)
```

## 🏗️ **Universal Interface Manager**

**Location**: `systems/universal_interface_manager.gd`

**Purpose**: Normalize ALL interfaces with consistent behaviors that humans expect from day one.

### **The Obvious Basics** (Finally Implemented):
- ✅ **ESC Key Closes Windows** - Every window responds to ESC
- ✅ **Click and Drag to Move** - All windows are moveable 
- ✅ **Click to Focus** - Clicking brings window to front
- ✅ **Proper Layering** - Cursor always on top, logical z-order
- ✅ **Theme Consistency** - Unified visual appearance
- ✅ **Input Handling** - Copy, paste, select all work everywhere

## 🎨 **Interface Hierarchy & Themes**

### **Layer System** (Respect This Order):
```
Layer 110: Modal Dialogs    # Critical system messages only
Layer 105: Cursor          # Always visible and interactive
Layer 100: Inspector       # Debug/analysis popups  
Layer 95:  Console         # AI conversation interface
Layer 50:  Game UI         # Regular game interface elements
Layer 0:   Background      # World/scene background
```

### **Available Themes**:
- **"default"**: Standard interface (blue accent)
- **"console"**: AI conversation (green accent)  
- **"inspector"**: Debug/analysis (orange accent)

## 🔧 **How to Use in Your Code**

### **1. Creating a New Interface**:
```gdscript
# In your Universal Being or system
func create_my_interface():
    var interface_config = {
        "id": "my_unique_interface",
        "title": "My Interface Name",
        "size": Vector2(600, 400),
        "position": Vector2(200, 100),
        "theme": "default",        # or "console", "inspector"
        "layer": "game_ui",        # See layer system above
        "esc_closes": true,        # Can be closed with ESC
        "moveable": true           # Can be dragged around
    }
    
    var my_window = UniversalInterfaceManager.create_universal_window(interface_config)
    
    # Add your content to the window
    var my_content = VBoxContainer.new()
    my_window.add_child(my_content)
    
    # Show the window
    get_tree().root.add_child(my_window)
    my_window.visible = true
```

### **2. Registering Existing Windows**:
```gdscript
# If you already have a window, register it for standards
var existing_window = Window.new()  # Your existing window
var config = {
    "esc_closes": true,
    "moveable": true,
    "layer": "game_ui"
}

UniversalInterfaceManager.get_instance().register_existing_window(
    existing_window, 
    "my_window_id", 
    config
)
```

### **3. Getting Window Status**:
```gdscript
# Check all interface status
var status = UniversalInterfaceManager.get_instance().get_interface_status()
print("Current interfaces: ", status)

# Get specific window by ID
var my_window = UniversalInterfaceManager.get_instance().get_registered_window("my_window_id")
```

## 🚨 **Critical Implementation Notes**

### **For Console/Chat Interfaces**:
- Use `"theme": "console"` and `"layer": "console"`
- Always preserve existing AI conversation functionality
- ESC closes, but doesn't interrupt ongoing AI responses

### **For Inspector/Debug Windows**:
- Use `"theme": "inspector"` and `"layer": "inspector"`  
- Higher priority than console but below cursor
- Quick access via keyboard shortcuts

### **For Game UI Elements**:
- Use `"theme": "default"` and `"layer": "game_ui"`
- Standard game interface elements
- Consistent with overall game aesthetic

## 🎯 **Examples from Existing Code**

### **Console Window** (Updated):
```gdscript
# In conversational_console_being.gd
var config = {
    "id": "ai_console",
    "title": "Universal Being - AI Conversation",
    "theme": "console",
    "layer": "console", 
    "esc_closes": true,
    "moveable": true
}
console_window = interface_manager.create_normalized_window(config)
```

### **Inspector Popup** (To Be Updated):
```gdscript
# Future update for debug/universal_script_inspector.gd
var config = {
    "id": "being_inspector",
    "title": "Universal Being Inspector",
    "theme": "inspector",
    "layer": "inspector",
    "esc_closes": true,
    "moveable": true  
}
inspector_window = UniversalInterfaceManager.create_universal_window(config)
```

## 💡 **For AI Developers**

### **When Adding New Features**:
1. **Always check**: Does this create a window/interface?
2. **If yes**: Use UniversalInterfaceManager
3. **Choose appropriate**: Theme and layer
4. **Test**: ESC closing, dragging, focusing
5. **Document**: Add to this navigation file

### **When Fixing Existing Code**:
1. **Identify**: Raw Window.new() usage
2. **Replace**: With normalized creation
3. **Update**: To use standard behaviors
4. **Verify**: All obvious basics work

## 🌟 **The Promise to JSH**

"Every interface will have the obvious basics that should have been there from day one. No more manual positioning. No more windows that can't be moved. No more interfaces that ignore ESC key. The Universal Interface System ensures that ALL windows behave like humans expect them to."

**This is the foundation that makes the perfect game possible.**

---

## 📚 **Related Documentation**

- **Main Implementation**: `systems/universal_interface_manager.gd`
- **Console Integration**: `beings/conversational_console_being.gd`  
- **Active Work Session**: `docs/ai_context/ACTIVE_WORK_SESSION.md`
- **Architecture Guide**: `CLAUDE.md`

**Remember**: Every interface is a chance to delight the user with obvious, intuitive behavior. Make it so! 🌟