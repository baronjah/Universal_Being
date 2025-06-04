# ==================================================
# UNIVERSAL BEING: Game Launcher
# TYPE: game_launcher
# PURPOSE: Loads and manages all core Universal Beings, provides main playable scene, handles input and status
# COMPONENTS: game_launcher.ub.zip
# SCENES: main_scene.tscn
# ==================================================

extends UniversalBeing
class_name GameLauncherUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
var terminal
var console
var socket_grid
@export var beings: Array = []
@export var status_message: String = ""

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()  # 🌱 ALWAYS CALL SUPER FIRST
    being_type = "game_launcher"
    being_name = "Game Launcher"
    consciousness_level = 2
    metadata.ai_accessible = true
    metadata.gemma_can_modify = true
    status_message = "Initializing Game Launcher..."
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()  # 🔄 ALWAYS CALL SUPER FIRST
    add_component("res://components/game_launcher.ub.zip")
    load_scene("res://scenes/main_scene.tscn")
    # Instantiate and register core beings
    terminal = preload("res://beings/terminal_universal_being.gd").new()
    console = preload("res://beings/console_universal_being.gd").new()
    socket_grid = preload("res://beings/socket_grid_universal_being.gd").new()
    beings = [terminal, console, socket_grid]
    # Optionally add to scene tree if needed
    for being in beings:
        if has_method("add_child"):
            add_child(being)
    status_message = "All core beings loaded. Ready to play!"
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)  # ⚡ ALWAYS CALL SUPER FIRST
    # Update status of all beings
    var statuses = []
    for being in beings:
        if being and being.has_method("ai_interface"):
            var iface = being.ai_interface()
            statuses.append("%s: %s" % [being.being_name, iface])
    status_message = "\n".join(statuses)
    set_scene_property("MainUI/StatusLabel", "text", status_message)

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)  # 👂 ALWAYS CALL SUPER FIRST
    # Keyboard shortcuts for spawning/controlling beings
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_T:
                spawn_terminal()
            KEY_C:
                spawn_console()
            KEY_S:
                spawn_socket_grid()
            KEY_R:
                refresh_status()
            _:
                pass

func pentagon_sewers() -> void:
    print("🌟 %s: Pentagon Sewers Starting" % being_name)
    # Cleanup all beings
    for being in beings:
        if being and being.has_method("pentagon_sewers"):
            being.pentagon_sewers()
    super.pentagon_sewers()  # 💀 ALWAYS CALL SUPER LAST

# ===== BEING-SPECIFIC METHODS =====

func spawn_terminal() -> void:
    if not terminal:
        terminal = preload("res://beings/terminal_universal_being.gd").new()
        beings.append(terminal)
        if has_method("add_child"):
            add_child(terminal)
        print("[GameLauncher] Terminal spawned.")

func spawn_console() -> void:
    if not console:
        console = preload("res://beings/console_universal_being.gd").new()
        beings.append(console)
        if has_method("add_child"):
            add_child(console)
        print("[GameLauncher] Console spawned.")

func spawn_socket_grid() -> void:
    if not socket_grid:
        socket_grid = preload("res://beings/socket_grid_universal_being.gd").new()
        beings.append(socket_grid)
        if has_method("add_child"):
            add_child(socket_grid)
        print("[GameLauncher] Socket Grid spawned.")

func refresh_status() -> void:
    print("[GameLauncher] Status refreshed.")
    pentagon_process(0.0)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    var base_interface = super.ai_interface()
    base_interface.custom_commands = ["spawn_terminal", "spawn_console", "spawn_socket_grid", "refresh_status"]
    base_interface.custom_properties = {
        "status_message": status_message,
        "beings_count": beings.size()
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    match method_name:
        "spawn_terminal":
            spawn_terminal()
            return true
        "spawn_console":
            spawn_console()
            return true
        "spawn_socket_grid":
            spawn_socket_grid()
            return true
        "refresh_status":
            refresh_status()
            return true
        _:
            return super.ai_invoke_method(method_name, args) 