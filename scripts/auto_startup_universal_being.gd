# ==================================================
# UNIVERSAL BEING: AutoStartup
# TYPE: auto_startup
# PURPOSE: Automatically execute F4 camera + F7 cursor combo at startup
# COMPONENTS: None needed - direct scene automation
# SCENES: None - controls main scene startup sequence
# ==================================================

extends UniversalBeing
class_name AutoStartupUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var auto_camera: bool = true
@export var auto_cursor: bool = true
@export var startup_delay: float = 1.0
@export var camera_delay: float = 0.5
@export var cursor_delay: float = 1.0

var startup_executed: bool = false
var main_controller: Node = null

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()  # 🌱 ALWAYS CALL SUPER FIRST
    
    being_type = "auto_startup"
    being_name = "Auto Startup Sequence"
    consciousness_level = 2  # Medium consciousness for automation
    metadata.ai_accessible = true
    metadata.gemma_can_modify = true
    
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()  # 🔄 ALWAYS CALL SUPER FIRST
    
    # Find main controller
    main_controller = find_main_controller()
    
    # Start automated sequence after delay
    if main_controller:
        print("🚀 %s: Found main controller, starting automation..." % being_name)
        call_deferred("_start_automation_sequence")
    else:
        print("⚠️ %s: Main controller not found, retrying..." % being_name)
        # Retry after a short delay
        await get_tree().create_timer(0.5).timeout
        pentagon_ready()
    
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)  # ⚡ ALWAYS CALL SUPER FIRST
    
    # Monitor main controller status
    if not startup_executed and main_controller:
        # Check if we should trigger automation
        if main_controller.has_method("get_status_info"):
            var status = main_controller.get_status_info()
            if status.systems_ready:
                _start_automation_sequence()

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)  # 👂 ALWAYS CALL SUPER FIRST
    
    # Handle manual override inputs
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F10:  # Manual trigger
                _start_automation_sequence()
            KEY_F11:  # Reset automation
                reset_automation()

func pentagon_sewers() -> void:
    print("🌟 %s: Pentagon Sewers Starting" % being_name)
    startup_executed = false
    main_controller = null
    super.pentagon_sewers()  # 💀 ALWAYS CALL SUPER LAST

# ===== AUTOMATION SEQUENCE METHODS =====

func find_main_controller() -> Node:
    """Find the main controller node"""
    # Look for main node in scene tree
    var root = get_tree().current_scene
    if root and root.name == "Main":
        return root
    
    # Search for node with main controller methods
    return find_node_with_method("create_camera_universal_being")

func find_node_with_method(method_name: String) -> Node:
    """Recursively find node with specific method"""
    var root = get_tree().current_scene
    return _search_node_recursive(root, method_name)

func _search_node_recursive(node: Node, method_name: String) -> Node:
    """Recursive helper for finding nodes"""
    if node.has_method(method_name):
        return node
    
    for child in node.get_children():
        var result = _search_node_recursive(child, method_name)
        if result:
            return result
    
    return null

func _start_automation_sequence() -> void:
    """Execute the F4 + F7 startup sequence"""
    if startup_executed:
        return
    
    startup_executed = true
    print("🚀 %s: Executing automated F4 + F7 sequence!" % being_name)
    
    # Wait for initial delay
    await get_tree().create_timer(startup_delay).timeout
    
    # Execute F4 - Camera Universal Being
    if auto_camera:
        _execute_f4_camera()
        await get_tree().create_timer(camera_delay).timeout
    
    # Execute F7 - Cursor Universal Being  
    if auto_cursor:
        _execute_f7_cursor()
        await get_tree().create_timer(cursor_delay).timeout
    
    print("✅ %s: Startup sequence completed!" % being_name)
    
    # Notify AI if available
    if GemmaAI and GemmaAI.has_method("ai_message"):
        GemmaAI.ai_message.emit("🚀 Auto-startup completed: Camera + Cursor beings are now active!")

func _execute_f4_camera() -> void:
    """Execute F4 camera automation"""
    if not main_controller or not main_controller.has_method("create_camera_universal_being"):
        push_error("🎥 Cannot create camera - main controller not available")
        return
    
    print("🎥 %s: Auto-executing F4 - Camera Universal Being..." % being_name)
    var camera_being = main_controller.create_camera_universal_being()
    
    if camera_being:
        print("✅ %s: Camera Universal Being created automatically!" % being_name)
    else:
        push_error("❌ %s: Failed to create Camera Universal Being" % being_name)

func _execute_f7_cursor() -> void:
    """Execute F7 cursor automation"""
    if not main_controller or not main_controller.has_method("create_cursor_universal_being"):
        push_error("🎯 Cannot create cursor - main controller not available")
        return
    
    print("🎯 %s: Auto-executing F7 - Cursor Universal Being..." % being_name)
    var cursor_being = main_controller.create_cursor_universal_being()
    
    if cursor_being:
        print("✅ %s: Cursor Universal Being created automatically!" % being_name)
    else:
        push_error("❌ %s: Failed to create Cursor Universal Being" % being_name)

func reset_automation() -> void:
    """Reset automation state for manual re-trigger"""
    startup_executed = false
    print("🔄 %s: Automation reset - can trigger again" % being_name)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for startup automation"""
    var base_interface = super.ai_interface()
    base_interface.custom_commands = [
        "start_sequence",
        "reset_automation", 
        "toggle_camera",
        "toggle_cursor",
        "set_delays"
    ]
    base_interface.automation_status = {
        "executed": startup_executed,
        "auto_camera": auto_camera,
        "auto_cursor": auto_cursor,
        "startup_delay": startup_delay
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """Allow AI to control startup automation"""
    match method_name:
        "start_sequence":
            _start_automation_sequence()
            return "Automation sequence started"
        "reset_automation":
            reset_automation()
            return "Automation reset"
        "toggle_camera":
            auto_camera = not auto_camera
            return "Auto camera: " + str(auto_camera)
        "toggle_cursor":
            auto_cursor = not auto_cursor
            return "Auto cursor: " + str(auto_cursor)
        "set_delays":
            if args.size() >= 3:
                startup_delay = float(args[0])
                camera_delay = float(args[1])
                cursor_delay = float(args[2])
                return "Delays set: startup=%s, camera=%s, cursor=%s" % [startup_delay, camera_delay, cursor_delay]
            return "Need 3 delay values: startup, camera, cursor"
        _:
            return super.ai_invoke_method(method_name, args)

# ===== DEBUG METHODS =====

func get_automation_status() -> Dictionary:
    """Get current automation status"""
    return {
        "executed": startup_executed,
        "auto_camera": auto_camera,
        "auto_cursor": auto_cursor,
        "main_controller_found": main_controller != null,
        "delays": {
            "startup": startup_delay,
            "camera": camera_delay,
            "cursor": cursor_delay
        }
    }

func _to_string() -> String:
    return "AutoStartupUniversalBeing<%s> [Camera:%s, Cursor:%s, Executed:%s]" % [being_name, auto_camera, auto_cursor, startup_executed]