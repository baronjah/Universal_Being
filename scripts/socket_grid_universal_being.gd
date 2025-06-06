# ==================================================
# UNIVERSAL BEING: Socket Grid
# TYPE: socket_grid
# PURPOSE: Manages a grid of socket cells for Universal Consciousness Terminal
# COMPONENTS: socket_grid.ub.zip
# SCENES: socket_grid_scene.tscn
# ==================================================

extends UniversalBeing
class_name SocketGridUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var grid_size: Vector2i = Vector2i(8, 6)
@export var cells: Array = [] # Array of SocketCellUniversalBeing references

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()  # 🌱 ALWAYS CALL SUPER FIRST
    being_type = "socket_grid"
    being_name = "Socket Grid"
    consciousness_level = 2
    metadata.ai_accessible = true
    metadata.gemma_can_modify = true
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()  # 🔄 ALWAYS CALL SUPER FIRST
    add_component("res://components/socket_grid.ub.zip")
    load_scene("res://scenes/socket_grid_scene.tscn")
    initialize_grid()
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)  # ⚡ ALWAYS CALL SUPER FIRST
    # Update grid or propagate process to cells if needed
    for cell in cells:
        if cell and cell.has_method("pentagon_process"):
            cell.pentagon_process(delta)

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)  # 👂 ALWAYS CALL SUPER FIRST
    # Propagate input to all cells
    for cell in cells:
        if cell and cell.has_method("pentagon_input"):
            cell.pentagon_input(event)

func pentagon_sewers() -> void:
    print("🌟 %s: Pentagon Sewers Starting" % being_name)
    # Cleanup cells
    for cell in cells:
        if cell and cell.has_method("pentagon_sewers"):
            cell.pentagon_sewers()
    super.pentagon_sewers()  # 💀 ALWAYS CALL SUPER LAST

# ===== BEING-SPECIFIC METHODS =====

func initialize_grid() -> void:
    """Create and register all socket cell beings for the grid."""
    cells.clear()
    for y in range(grid_size.y):
        for x in range(grid_size.x):
            var cell = preload("res://scripts_backup/socket_cell_universal_being.gd").new()
            cell.position = Vector2i(x, y)
            cells.append(cell)
            # Optionally add to scene or register with FloodGate if needed

func get_cell(x: int, y: int) -> Variant:
    var idx = y * grid_size.x + x
    if idx >= 0 and idx < cells.size():
        return cells[idx]
    return null

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    var base_interface = super.ai_interface()
    base_interface.custom_commands = ["get_cell", "update_grid_size"]
    base_interface.custom_properties = {
        "grid_size": grid_size,
        "cell_count": cells.size()
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    match method_name:
        "get_cell":
            if args.size() == 2:
                return get_cell(args[0], args[1])
            return null
        "update_grid_size":
            if args.size() == 2:
                grid_size = Vector2i(args[0], args[1])
                initialize_grid()
                return true
            return false
        _:
            return super.ai_invoke_method(method_name, args) 