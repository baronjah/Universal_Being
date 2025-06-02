# ==================================================
# UNIVERSAL BEING: CameraInfoPanel
# TYPE: UI_Element
# PURPOSE: Displays detailed camera consciousness info and state
# COMPONENTS: ui_animation.ub.zip
# SCENES: info_panel.tscn
# ==================================================

extends UniversalBeing
class_name CameraInfoPanelUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var update_interval: float = 0.5  # How often to update FPS
@export var consciousness_descriptions: Array[String] = [
    "Inert",           # Level 0
    "Awakening",       # Level 1
    "Aware",          # Level 2
    "Conscious",      # Level 3
    "Enlightened",    # Level 4
    "Transcendent",   # Level 5
    "Omniscient",     # Level 6
    "Universal"       # Level 7
]

var last_fps_update: float = 0.0
var current_fps: float = 0.0
var frame_count: int = 0

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    # Set Universal Being identity
    being_type = "ui_element"
    being_name = "Camera Info Panel"
    consciousness_level = 1
    
    # Load required components
    add_component("res://components/ui_animation.ub.zip")
    
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Initialize UI scene
    load_scene("res://scenes/ui/camera_consciousness_overlay/info_panel.tscn")
    
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Update FPS counter
    frame_count += 1
    last_fps_update += delta
    if last_fps_update >= update_interval:
        current_fps = frame_count / last_fps_update
        frame_count = 0
        last_fps_update = 0.0
        update_fps_display()

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    # No direct input handling needed

func pentagon_sewers() -> void:
    # Cleanup any resources
    super.pentagon_sewers()

# ===== BEING-SPECIFIC METHODS =====

func update_info(camera_state: Dictionary) -> void:
    """Update the info panel with current camera state"""
    if not scene_is_loaded:
        return
        
    # Update consciousness level and description
    var level = camera_state.get("consciousness_level", 0)
    var description = consciousness_descriptions[level] if level < consciousness_descriptions.size() else "Unknown"
    call_scene_method("ConsciousnessInfo", "set_text", ["Level %d: %s" % [level, description]])
    
    # Update camera mode
    var mode = camera_state.get("mode", "unknown")
    call_scene_method("CameraMode", "set_text", ["Mode: %s" % mode.capitalize()])
    
    # Update active effects
    var effects = camera_state.get("active_effects", [])
    var effects_text = "Active Effects:\n" + "\n".join(effects) if effects.size() > 0 else "No Active Effects"
    call_scene_method("EffectsList", "set_text", [effects_text])

func update_fps_display() -> void:
    """Update the FPS counter display"""
    if not scene_is_loaded:
        return
        
    call_scene_method("FPSCounter", "set_text", ["FPS: %.1f" % current_fps])

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for info panel control"""
    var base_interface = super.ai_interface()
    base_interface.custom_commands = ["update_info", "get_fps"]
    base_interface.custom_properties = {
        "current_fps": current_fps,
        "update_interval": update_interval
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """Handle AI method calls"""
    var result = null
    match method_name:
        "update_info":
            if args.size() > 0:
                update_info(args[0])
                result = true
        "get_fps":
            result = current_fps
        _:
            result = super.ai_invoke_method(method_name, args)
    return result 