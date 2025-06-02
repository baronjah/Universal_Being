# ==================================================
# UNIVERSAL BEING: CameraConsciousnessOverlayController
# TYPE: UI_Controller
# PURPOSE: Manages all camera consciousness UI overlays
# COMPONENTS: ui_animation.ub.zip, effect_control.ub.zip
# SCENES: consciousness_meter.tscn, info_panel.tscn, effect_sliders.tscn
# ==================================================

extends UniversalBeing
class_name CameraConsciousnessOverlayControllerUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var debug_mode: bool = false
@export var info_panel_key: String = "C"

# UI State
var consciousness_meter: UniversalBeing
var info_panel: UniversalBeing
var effect_sliders: UniversalBeing
var is_info_panel_visible: bool = false

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    # Set Universal Being identity
    being_type = "ui_controller"
    being_name = "Camera Consciousness Overlay Controller"
    consciousness_level = 1  # Basic consciousness for UI management
    
    # Load required components
    add_component("res://components/ui_animation.ub.zip")
    add_component("res://components/effect_control.ub.zip")
    
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Load and initialize UI scenes
    load_consciousness_meter()
    load_info_panel()
    if debug_mode:
        load_effect_sliders()
    
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Update UI elements if camera system is ready
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        var camera_system = SystemBootstrap.get_camera_system()
        if camera_system:
            update_consciousness_display(camera_system.get_consciousness_level())
            update_camera_info(camera_system.get_camera_state())

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # Toggle info panel with C key
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_C:
            toggle_info_panel()

func pentagon_sewers() -> void:
    # Cleanup UI elements
    if consciousness_meter:
        consciousness_meter.queue_free()
    if info_panel:
        info_panel.queue_free()
    if effect_sliders:
        effect_sliders.queue_free()
    
    super.pentagon_sewers()

# ===== BEING-SPECIFIC METHODS =====

func load_consciousness_meter() -> void:
    """Load and initialize the consciousness level meter"""
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        consciousness_meter = SystemBootstrap.create_universal_being()
        if consciousness_meter:
            consciousness_meter.name = "ConsciousnessMeter"
            consciousness_meter.set("being_type", "ui_element")
            consciousness_meter.set("being_name", "Consciousness Level Meter")
            consciousness_meter.load_scene("res://scenes/ui/camera_consciousness_overlay/consciousness_meter.tscn")
            add_child(consciousness_meter)

func load_info_panel() -> void:
    """Load and initialize the camera info panel"""
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        info_panel = SystemBootstrap.create_universal_being()
        if info_panel:
            info_panel.name = "CameraInfoPanel"
            info_panel.set("being_type", "ui_element")
            info_panel.set("being_name", "Camera Info Panel")
            info_panel.load_scene("res://scenes/ui/camera_consciousness_overlay/info_panel.tscn")
            info_panel.visible = false
            add_child(info_panel)

func load_effect_sliders() -> void:
    """Load and initialize the effect control sliders (debug mode)"""
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        effect_sliders = SystemBootstrap.create_universal_being()
        if effect_sliders:
            effect_sliders.name = "EffectSliders"
            effect_sliders.set("being_type", "ui_element")
            effect_sliders.set("being_name", "Effect Control Sliders")
            effect_sliders.load_scene("res://scenes/ui/camera_consciousness_overlay/effect_sliders.tscn")
            effect_sliders.visible = false
            add_child(effect_sliders)

func update_consciousness_display(level: int) -> void:
    """Update the consciousness meter with current level"""
    if consciousness_meter:
        consciousness_meter.call_scene_method("ConsciousnessMeter", "update_level", [level])

func update_camera_info(camera_state: Dictionary) -> void:
    """Update the info panel with current camera state"""
    if info_panel and info_panel.visible:
        info_panel.call_scene_method("InfoPanel", "update_info", [camera_state])

func toggle_info_panel() -> void:
    """Toggle visibility of the info panel"""
    if info_panel:
        is_info_panel_visible = !is_info_panel_visible
        info_panel.visible = is_info_panel_visible
        
        # Show/hide effect sliders in debug mode
        if debug_mode and effect_sliders:
            effect_sliders.visible = is_info_panel_visible

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for overlay control"""
    var base_interface = super.ai_interface()
    base_interface.custom_commands = ["toggle_info", "set_debug_mode", "update_effects"]
    base_interface.custom_properties = {
        "debug_mode": debug_mode,
        "is_info_panel_visible": is_info_panel_visible
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """Handle AI method calls"""
    var result = null
    match method_name:
        "toggle_info":
            toggle_info_panel()
            result = true
        "set_debug_mode":
            if args.size() > 0:
                debug_mode = args[0]
                if debug_mode:
                    load_effect_sliders()
                result = true
        "update_effects":
            if effect_sliders and args.size() > 0:
                effect_sliders.call_scene_method("EffectSliders", "update_effects", [args[0]])
                result = true
        _:
            result = super.ai_invoke_method(method_name, args)
    return result 