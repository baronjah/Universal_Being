# Sprite3D Universal Being Design - 2D/3D Hybrid System
*Created: May 28, 2025*

## 🎯 Vision: Everything as Universal Being

**Core Concept:** Every entity (objects, UI, interfaces) is a Universal Being that can manifest in both 2D and 3D space using Sprite3D.

## 📐 Architecture Design

### **Universal Being Display Modes**

```gdscript
extends Node3D
class_name UniversalBeing

enum DisplayMode {
    PURE_3D,        # Traditional 3D mesh
    PURE_2D,        # Sprite3D billboard
    HYBRID,         # Both 3D and 2D elements
    INTERFACE       # UI elements in 3D space
}

var display_mode: DisplayMode = DisplayMode.PURE_3D
var sprite_3d: Sprite3D = null
var mesh_instance: MeshInstance3D = null
var ui_viewport: SubViewport = null
var ui_control: Control = null
```

### **2D Interface Integration**

```gdscript
func become_interface(interface_type: String, properties: Dictionary = {}):
    """Transform into any UI interface using Sprite3D"""
    display_mode = DisplayMode.INTERFACE
    form = "interface_" + interface_type
    
    match interface_type:
        "console":
            _create_console_interface(properties)
        "grid":
            _create_grid_interface(properties)
        "debug":
            _create_debug_interface(properties)
        "inventory":
            _create_inventory_interface(properties)
        "property_editor":
            _create_property_editor(properties)
        _:
            _create_custom_interface(interface_type, properties)

func _create_console_interface(props: Dictionary):
    # Create SubViewport for UI rendering
    ui_viewport = SubViewport.new()
    ui_viewport.size = Vector2i(800, 600)
    ui_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    add_child(ui_viewport)
    
    # Create console UI
    ui_control = _build_console_ui()
    ui_viewport.add_child(ui_control)
    
    # Create Sprite3D to display the UI
    sprite_3d = Sprite3D.new()
    sprite_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    sprite_3d.texture = ui_viewport.get_texture()
    sprite_3d.pixel_size = 0.001  # Adjust size
    add_child(sprite_3d)
    
    # Make interactive
    _setup_3d_ui_interaction()

func _build_console_ui() -> Control:
    var panel = PanelContainer.new()
    panel.size = Vector2(800, 600)
    
    var vbox = VBoxContainer.new()
    panel.add_child(vbox)
    
    # Title
    var title = Label.new()
    title.text = "Universal Console Interface"
    title.add_theme_font_size_override("font_size", 24)
    vbox.add_child(title)
    
    # Output area
    var output = RichTextLabel.new()
    output.fit_content = true
    output.custom_minimum_size = Vector2(0, 400)
    vbox.add_child(output)
    
    # Input area
    var input = LineEdit.new()
    input.placeholder_text = "Enter command..."
    vbox.add_child(input)
    
    # Store references in essence
    set_essence("ui_output", output)
    set_essence("ui_input", input)
    
    return panel
```

### **Grid Viewer as Universal Being**

```gdscript
func _create_grid_interface(props: Dictionary):
    ui_viewport = SubViewport.new()
    ui_viewport.size = Vector2i(1200, 800)
    add_child(ui_viewport)
    
    var grid_ui = _build_grid_ui()
    ui_viewport.add_child(grid_ui)
    
    sprite_3d = Sprite3D.new()
    sprite_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    sprite_3d.texture = ui_viewport.get_texture()
    sprite_3d.pixel_size = 0.0008
    add_child(sprite_3d)
    
    # Auto-update grid data
    _setup_grid_auto_update()

func _build_grid_ui() -> Control:
    var panel = PanelContainer.new()
    panel.size = Vector2(1200, 800)
    
    var vbox = VBoxContainer.new()
    panel.add_child(vbox)
    
    # Title with controls
    var title_bar = HBoxContainer.new()
    vbox.add_child(title_bar)
    
    var title = Label.new()
    title.text = "Universal Beings Database"
    title_bar.add_child(title)
    
    var refresh_btn = Button.new()
    refresh_btn.text = "Refresh"
    refresh_btn.pressed.connect(_refresh_grid_data)
    title_bar.add_child(refresh_btn)
    
    # Grid/Table
    var grid = ItemList.new()
    grid.custom_minimum_size = Vector2(0, 700)
    vbox.add_child(grid)
    
    set_essence("ui_grid", grid)
    _populate_grid_data()
    
    return panel

func _populate_grid_data():
    var grid = get_essence("ui_grid")
    if not grid:
        return
    
    grid.clear()
    
    # Get all Universal Beings
    var beings = get_tree().get_nodes_in_group("universal_beings")
    
    for being in beings:
        if being == self:  # Skip self
            continue
            
        var state = being.get_full_state()
        var display_text = "%s | %s | %s | %.1f" % [
            state.get("uuid", "unknown"),
            state.get("form", "void"),
            str(state.get("position", Vector3.ZERO)),
            state.get("satisfaction", 0.0)
        ]
        grid.add_item(display_text)
```

### **3D UI Interaction System**

```gdscript
func _setup_3d_ui_interaction():
    # Create CollisionShape3D for mouse interaction
    var area = Area3D.new()
    var collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    
    # Size based on Sprite3D
    shape.size = Vector3(
        sprite_3d.texture.get_width() * sprite_3d.pixel_size,
        sprite_3d.texture.get_height() * sprite_3d.pixel_size,
        0.1
    )
    
    collision.shape = shape
    area.add_child(collision)
    add_child(area)
    
    # Connect mouse events
    area.input_event.connect(_on_ui_input_event)
    area.mouse_entered.connect(_on_ui_mouse_entered)
    area.mouse_exited.connect(_on_ui_mouse_exited)

func _on_ui_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
    if event is InputEventMouseButton and event.pressed:
        # Convert 3D click to 2D UI coordinates
        var local_pos = to_local(event_position)
        var ui_pos = _convert_3d_to_ui_coords(local_pos)
        
        # Send click to UI
        _send_click_to_ui(ui_pos, event.button_index)

func _convert_3d_to_ui_coords(local_3d_pos: Vector3) -> Vector2:
    # Convert 3D position to UI coordinates
    var ui_size = ui_viewport.size
    var sprite_size = Vector2(
        sprite_3d.texture.get_width() * sprite_3d.pixel_size,
        sprite_3d.texture.get_height() * sprite_3d.pixel_size
    )
    
    # Normalize to 0-1 range
    var normalized = Vector2(
        (local_3d_pos.x / sprite_size.x) + 0.5,
        -(local_3d_pos.y / sprite_size.y) + 0.5
    )
    
    # Convert to UI pixel coordinates
    return Vector2(
        normalized.x * ui_size.x,
        normalized.y * ui_size.y
    )

func _send_click_to_ui(ui_pos: Vector2, button_index: int):
    # Find which UI element was clicked
    var clicked_control = _find_control_at_position(ui_control, ui_pos)
    
    if clicked_control:
        if clicked_control.has_method("_gui_input"):
            var mock_event = InputEventMouseButton.new()
            mock_event.position = ui_pos
            mock_event.button_index = button_index
            mock_event.pressed = true
            clicked_control._gui_input(mock_event)
```

### **Asset Integration with UI**

```gdscript
# Enhanced asset loading for UI beings
func load_ui_asset(asset_type: String) -> UniversalBeing:
    var ui_being = UniversalBeing.new()
    
    # Load UI definition from TXT
    var txt_path = "res://assets/ui_definitions/" + asset_type + ".txt"
    var ui_definition = _parse_ui_definition(txt_path)
    
    # Apply definition
    ui_being.become_interface(asset_type, ui_definition)
    
    return ui_being

func _parse_ui_definition(path: String) -> Dictionary:
    var definition = {}
    var file = FileAccess.open(path, FileAccess.READ)
    
    if file:
        while not file.eof_reached():
            var line = file.get_line().strip_edges()
            if line.begins_with("#") or line.is_empty():
                continue
                
            var parts = line.split(":")
            if parts.size() == 2:
                var key = parts[0].strip_edges()
                var value = parts[1].strip_edges()
                definition[key] = value
        file.close()
    
    return definition
```

### **Console Commands for UI Management**

```gdscript
# In console_manager.gd - new commands
func _cmd_ui_create(args: Array):
    if args.size() < 1:
        _print_to_console("Usage: ui create <type> [position]")
        return
    
    var ui_type = args[0]
    var position = Vector3.ZERO
    
    if args.size() >= 4:
        position = Vector3(
            args[1].to_float(),
            args[2].to_float(), 
            args[3].to_float()
        )
    
    # Create UI as Universal Being
    var ui_being = UniversalBeing.new()
    ui_being.position = position
    ui_being.become_interface(ui_type)
    
    # Add to scene through floodgate
    var floodgate = get_node("/root/FloodgateController")
    floodgate.second_dimensional_magic(0, ui_type + "_ui", ui_being)
    
    _print_to_console("Created %s UI at %s" % [ui_type, position])

func _cmd_grid_show(args: Array):
    # Create or toggle grid viewer
    var existing_grid = get_tree().get_first_node_in_group("grid_interfaces")
    
    if existing_grid:
        existing_grid.visible = not existing_grid.visible
    else:
        var grid_being = UniversalBeing.new()
        grid_being.position = Vector3(5, 2, 0)  # Position in front of player
        grid_being.become_interface("grid")
        grid_being.add_to_group("grid_interfaces")
        
        var floodgate = get_node("/root/FloodgateController")
        floodgate.second_dimensional_magic(0, "grid_viewer", grid_being)

func _cmd_being_edit(args: Array):
    if args.size() < 3:
        _print_to_console("Usage: being edit <id> <property> <value>")
        return
        
    var being_id = args[0]
    var property = args[1]
    var value = args[2]
    
    # Find being by ID
    var beings = get_tree().get_nodes_in_group("universal_beings")
    for being in beings:
        if being.name.ends_with(being_id) or being.uuid == being_id:
            # Edit property through floodgate
            var floodgate = get_node("/root/FloodgateController")
            floodgate.first_dimensional_magic("update_property", being, {property: value})
            _print_to_console("Updated %s.%s = %s" % [being_id, property, value])
            return
    
    _print_to_console("Being not found: " + being_id)
```

## 🎮 Usage Examples

### **Creating UI Interfaces:**
```bash
ui create console 0 2 0          # Console interface at position
ui create grid 5 2 0             # Grid database viewer  
ui create debug -2 2 0           # Debug panel
ui create inventory 0 0 -3       # Inventory as 3D interface
```

### **Grid Database Operations:**
```bash
grid show                        # Show/hide grid interface
grid filter type=nature          # Filter displayed beings
grid edit Tree_1 health 500      # Edit properties live
grid connect Tree_1 Ragdoll_1     # Create visual connection
```

### **Being Management:**
```bash
being create tree                # Creates Tree_1 as Universal Being
being transform Tree_1 console   # Transform tree into console interface
being edit Tree_1 health 800     # Edit any property
being connect Tree_1 Rock_1      # Connect two beings
```

## 🔧 Technical Benefits

### **Everything is Unified:**
- Objects, UI, debug panels all use same Universal Being base
- Consistent interaction model (click, inspect, edit)
- Same console commands work on everything

### **2D + 3D Seamless:**
- UI elements exist in 3D space but display 2D content
- Can walk around and interact with floating interfaces
- Maintains performance with SubViewport rendering

### **Fully Interactive:**
- Click 3D UI elements in world space
- Grid viewer shows live data
- Real-time property editing

### **Asset-Driven:**
- UI layouts defined in TXT files
- Easy to modify and version control
- Consistent with object asset system

---

*"Your UI becomes part of the world, not separate from it. Everything is a Universal Being!"*