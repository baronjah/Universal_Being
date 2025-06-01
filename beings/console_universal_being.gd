# ==================================================
# UNIVERSAL BEING: Console
# TYPE: console
# PURPOSE: Command output and interaction console for Universal Consciousness Terminal
# COMPONENTS: console_core.ub.zip
# SCENES: console_scene.tscn
# ==================================================

extends UniversalBeing
class_name UniversalConsoleBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var command_history: Array[String] = []
@export var output_text: String = ""

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()  # 🌱 ALWAYS CALL SUPER FIRST
    being_type = "console"
    being_name = "Universal Console"
    consciousness_level = 3  # AI-accessible
    metadata.ai_accessible = true
    metadata.gemma_can_modify = true
    output_text = "Console initialized."
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()  # 🔄 ALWAYS CALL SUPER FIRST
    # Load required components
    add_component("res://components/console_core.ub.zip")
    # Load and control the console scene
    load_scene("res://scenes/console_scene.tscn")
    set_scene_property("ConsoleUI/OutputLabel", "text", output_text)
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)  # ⚡ ALWAYS CALL SUPER FIRST
    # Update output if needed
    pass

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)  # 👂 ALWAYS CALL SUPER FIRST
    # Handle input for command history navigation or output interaction
    pass

func pentagon_sewers() -> void:
    # Being-specific cleanup FIRST
    print("🌟 %s: Pentagon Sewers Starting" % being_name)
    # Cleanup logic here
    super.pentagon_sewers()  # 💀 ALWAYS CALL SUPER LAST

# ===== BEING-SPECIFIC METHODS =====

func add_command(command: String) -> void:
    """Add a command to the history and update output."""
    command_history.append(command)
    output_text += "\n> " + command
    set_scene_property("ConsoleUI/OutputLabel", "text", output_text)

func clear_console() -> void:
    """Clear the console output."""
    output_text = ""
    set_scene_property("ConsoleUI/OutputLabel", "text", output_text)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    var base_interface = super.ai_interface()
    base_interface.custom_commands = ["add_command", "clear_console"]
    base_interface.custom_properties = {
        "command_history": command_history,
        "output_text": output_text
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    match method_name:
        "add_command":
            if args.size() > 0:
                add_command(args[0])
                return true
            return false
        "clear_console":
            clear_console()
            return true
        _:
            return super.ai_invoke_method(method_name, args) 