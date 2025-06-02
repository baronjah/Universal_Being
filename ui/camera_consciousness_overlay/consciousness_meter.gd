# ==================================================
# UNIVERSAL BEING: ConsciousnessMeter
# TYPE: UI_Element
# PURPOSE: Displays camera consciousness level with animations
# COMPONENTS: ui_animation.ub.zip
# SCENES: consciousness_meter.tscn
# ==================================================

extends UniversalBeing
class_name ConsciousnessMeterUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var animation_duration: float = 0.5
@export var colors: Array[Color] = [
    Color(0.2, 0.2, 0.2),  # Level 0 - Dark
    Color(0.4, 0.4, 0.8),  # Level 1 - Blue
    Color(0.6, 0.8, 0.4),  # Level 2 - Green
    Color(0.8, 0.8, 0.2),  # Level 3 - Yellow
    Color(0.8, 0.6, 0.2),  # Level 4 - Orange
    Color(0.8, 0.4, 0.2),  # Level 5 - Red-Orange
    Color(0.8, 0.2, 0.2),  # Level 6 - Red
    Color(0.8, 0.2, 0.8)   # Level 7 - Purple
]

var current_level: int = 0
var target_level: int = 0
var animation_progress: float = 0.0

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    # Set Universal Being identity
    being_type = "ui_element"
    being_name = "Consciousness Level Meter"
    consciousness_level = 1
    
    # Load required components
    add_component("res://components/ui_animation.ub.zip")
    
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Initialize UI scene
    load_scene("res://scenes/ui/camera_consciousness_overlay/consciousness_meter.tscn")
    
    # Set initial state
    update_level(0)
    
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Handle level transition animation
    if current_level != target_level:
        animation_progress += delta / animation_duration
        if animation_progress >= 1.0:
            current_level = target_level
            animation_progress = 0.0
            update_meter_display()
        else:
            update_meter_display()

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    # No direct input handling needed

func pentagon_sewers() -> void:
    # Cleanup any resources
    super.pentagon_sewers()

# ===== BEING-SPECIFIC METHODS =====

func update_level(new_level: int) -> void:
    """Update the target consciousness level with animation"""
    if new_level >= 0 and new_level < colors.size():
        target_level = new_level
        if current_level != target_level:
            animation_progress = 0.0

func update_meter_display() -> void:
    """Update the visual display of the meter"""
    if not scene_is_loaded:
        return
        
    # Calculate interpolated color
    var current_color = colors[current_level]
    var target_color = colors[target_level]
    var display_color = current_color.lerp(target_color, animation_progress)
    
    # Update meter visuals
    call_scene_method("MeterBackground", "set_color", [display_color])
    call_scene_method("LevelIndicator", "set_value", [lerp(current_level, target_level, animation_progress)])
    call_scene_method("LevelText", "set_text", [str(round(lerp(current_level, target_level, animation_progress)))])
    
    # Update glow effect
    var glow_intensity = 0.5 + (target_level * 0.1)  # More glow at higher levels
    call_scene_method("GlowEffect", "set_intensity", [glow_intensity])

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for meter control"""
    var base_interface = super.ai_interface()
    base_interface.custom_commands = ["set_level", "get_level"]
    base_interface.custom_properties = {
        "current_level": current_level,
        "target_level": target_level
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """Handle AI method calls"""
    var result = null
    match method_name:
        "set_level":
            if args.size() > 0:
                update_level(args[0])
                result = true
        "get_level":
            result = current_level
        _:
            result = super.ai_invoke_method(method_name, args)
    return result 