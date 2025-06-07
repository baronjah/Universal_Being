# ==================================================
# UNIVERSAL BEING: Terminal
# TYPE: terminal
# PURPOSE: Central UI for Universal Consciousness commands and AI interaction
# COMPONENTS: terminal_ui.ub.zip, ai_integration.ub.zip, socket_grid.ub.zip
# SCENES: terminal_scene.tscn
# ==================================================

extends UniversalBeing
class_name TerminalUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var socket_grid_size: Vector2i = Vector2i(8, 6)
@export var ai_connected: bool = false
@export var status_message: String = ""

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()  # 🌱 ALWAYS CALL SUPER FIRST
    being_type = "terminal"
    being_name = "Universal Consciousness Terminal"
    consciousness_level = 3  # AI-accessible
    metadata.ai_accessible = true
    metadata.gemma_can_modify = true
    status_message = "Initializing Terminal..."
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()  # 🔄 ALWAYS CALL SUPER FIRST
    # Load required components
    add_component("res://components/terminal_ui.ub.zip")
    add_component("res://components/ai_integration.ub.zip")
    add_component("res://components/socket_grid.ub.zip")
    # Load and control the terminal scene
    load_scene("res://scenes/terminal_scene.tscn")
    # Set up socket grid and AI status
    set_scene_property("TerminalUI/StatusLabel", "text", status_message)
    set_scene_property("TerminalUI/SocketGrid", "size", socket_grid_size)
    ai_connected = true  # Simulate AI connection for now
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)  # ⚡ ALWAYS CALL SUPER FIRST
    # Update status or handle live output if needed
    # Example: update terminal output, check AI status
    pass

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)  # 👂 ALWAYS CALL SUPER FIRST
    # Handle command input from the terminal UI
    # Example: if event is InputEventKey and event.pressed:
    #     process_command(get_scene_property("TerminalUI/InputField", "text"))
    pass

func pentagon_sewers() -> void:
    # Being-specific cleanup FIRST
    print("🌟 %s: Pentagon Sewers Starting" % being_name)
    # Cleanup logic here (e.g., disconnect AI, clear UI)
    super.pentagon_sewers()  # 💀 ALWAYS CALL SUPER LAST

# ===== BEING-SPECIFIC METHODS =====

func process_command(command: String) -> void:
    """Process a command entered in the terminal UI."""
    # Placeholder for command parsing and execution
    print("[Terminal] Command received: %s" % command)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
    var base_interface = super.ai_interface()
    base_interface.custom_commands = ["send_command", "update_status"]
    base_interface.custom_properties = {
        "socket_grid_size": socket_grid_size,
        "ai_connected": ai_connected,
        "status_message": status_message
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    match method_name:
        "send_command":
            if args.size() > 0:
                process_command(args[0])
                return true
            return false
        "update_status":
            if args.size() > 0:
                status_message = args[0]
                set_scene_property("TerminalUI/StatusLabel", "text", status_message)
                return true
            return false
        _:
            return super.ai_invoke_method(method_name, args) 