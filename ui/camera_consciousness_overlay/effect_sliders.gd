# ==================================================
# UNIVERSAL BEING: EffectSliders
# TYPE: UI_Element
# PURPOSE: Debug controls for camera consciousness effects
# COMPONENTS: ui_animation.ub.zip, effect_control.ub.zip
# SCENES: effect_sliders.tscn
# ==================================================

extends UniversalBeing
class_name EffectSlidersUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var preset_save_path: String = "user://effect_presets/"
@export var default_preset: String = "default"

# Effect definitions with default values
var effect_definitions: Dictionary = {
    "glow_intensity": {"min": 0.0, "max": 2.0, "default": 1.0, "step": 0.1},
    "blur_amount": {"min": 0.0, "max": 5.0, "default": 0.0, "step": 0.1},
    "chromatic_aberration": {"min": 0.0, "max": 1.0, "default": 0.0, "step": 0.05},
    "vignette_strength": {"min": 0.0, "max": 1.0, "default": 0.0, "step": 0.05},
    "distortion_amount": {"min": 0.0, "max": 1.0, "default": 0.0, "step": 0.05}
}

var current_values: Dictionary = {}
var active_preset: String = ""

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    # Set Universal Being identity
    being_type = "ui_element"
    being_name = "Effect Control Sliders"
    consciousness_level = 1
    
    # Load required components
    add_component("res://components/ui_animation.ub.zip")
    add_component("res://components/effect_control.ub.zip")
    
    # Initialize current values with defaults
    for effect in effect_definitions:
        current_values[effect] = effect_definitions[effect].default
    
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Initialize UI scene
    load_scene("res://scenes/ui/camera_consciousness_overlay/effect_sliders.tscn")
    
    # Create sliders for each effect
    create_effect_sliders()
    
    # Load default preset
    load_preset(default_preset)
    
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    # No continuous processing needed

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    # Input handled by slider signals

func pentagon_sewers() -> void:
    # Save current values as preset before cleanup
    if active_preset != "":
        save_preset(active_preset)
    
    super.pentagon_sewers()

# ===== BEING-SPECIFIC METHODS =====

func create_effect_sliders() -> void:
    """Create slider controls for each effect"""
    if not scene_is_loaded:
        return
        
    var container = get_scene_node("EffectContainer")
    if not container:
        return
        
    for effect in effect_definitions:
        var def = effect_definitions[effect]
        call_scene_method("EffectContainer", "add_effect_slider", [
            effect,
            def.min,
            def.max,
            def.default,
            def.step
        ])

func update_effects(effect_values: Dictionary) -> void:
    """Update effect values from external source"""
    for effect in effect_values:
        if effect in current_values:
            current_values[effect] = effect_values[effect]
            call_scene_method("EffectContainer", "set_slider_value", [effect, effect_values[effect]])

func save_preset(preset_name: String) -> bool:
    """Save current effect values as a preset"""
    var dir = DirAccess.open("user://")
    if not dir.dir_exists(preset_save_path):
        dir.make_dir_recursive(preset_save_path)
    
    var file = FileAccess.open(preset_save_path + preset_name + ".json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(current_values))
        active_preset = preset_name
        return true
    return false

func load_preset(preset_name: String) -> bool:
    """Load effect values from a preset"""
    var file = FileAccess.open(preset_save_path + preset_name + ".json", FileAccess.READ)
    if file:
        var json = JSON.parse_string(file.get_as_text())
        if json:
            current_values = json
            update_effects(current_values)
            active_preset = preset_name
            return true
    return false

func _on_slider_value_changed(effect: String, value: float) -> void:
    """Handle slider value changes"""
    if effect in current_values:
        current_values[effect] = value
        # Notify camera system of effect change
        if SystemBootstrap and SystemBootstrap.is_system_ready():
            var camera_system = SystemBootstrap.get_camera_system()
            if camera_system:
                camera_system.set_effect_value(effect, value)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for effect control"""
    var base_interface = super.ai_interface()
    base_interface.custom_commands = ["update_effects", "save_preset", "load_preset", "get_effects"]
    base_interface.custom_properties = {
        "current_values": current_values,
        "active_preset": active_preset
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """Handle AI method calls"""
    var result = null
    match method_name:
        "update_effects":
            if args.size() > 0:
                update_effects(args[0])
                result = true
        "save_preset":
            if args.size() > 0:
                result = save_preset(args[0])
        "load_preset":
            if args.size() > 0:
                result = load_preset(args[0])
        "get_effects":
            result = current_values
        _:
            result = super.ai_invoke_method(method_name, args)
    return result 