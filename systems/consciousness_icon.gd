# ==================================================
# UNIVERSAL BEING: ConsciousnessIcon
# TYPE: Asset Component
# PURPOSE: Display consciousness level icons with beautiful animations
# COMPONENTS: consciousness_icons.ub.zip
# SCENES: consciousness_icon.tscn
# ==================================================

extends UniversalBeing
class_name ConsciousnessIcon

# ===== CONSCIOUSNESS PROPERTIES =====
@export var icon_size: Vector2 = Vector2(32, 32)
@export var auto_update: bool = true
@export var animation_enabled: bool = true
@export var glow_enabled: bool = true

# ===== ICON NODES =====
@onready var icon_sprite: Sprite2D = $IconSprite
@onready var glow_effect: Sprite2D = $GlowEffect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# ===== CONSCIOUSNESS DATA =====
var consciousness_colors: Dictionary = {
    0: Color(0.5, 0.5, 0.5),      # Dormant - Gray
    1: Color(0.9, 0.9, 0.9),      # Awakening - Pale
    2: Color(0.2, 0.4, 1.0),      # Aware - Blue
    3: Color(0.2, 1.0, 0.2),      # Connected - Green
    4: Color(1.0, 0.84, 0.0),     # Enlightened - Gold
    5: Color(1.0, 1.0, 1.0),      # Transcendent - White
    6: Color(0.8, 0.4, 1.0),      # Cosmic - Purple
    7: Color(1.0, 0.7, 0.9)       # Universal - Pink
}

var icon_paths: Dictionary = {
    0: "res://icon.svg",
    1: "res://icon.svg", 
    2: "res://icon.svg",
    3: "res://icon.svg",
    4: "res://icon.svg",
    5: "res://icon.svg",
    6: "res://icon.svg",
    7: "res://icon.svg"
}

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    being_type = "consciousness_icon"
    being_name = "Consciousness Icon"
    consciousness_level = 1
    
    evolution_state.can_become = [
        "consciousness_icon_animated.ub.zip",
        "consciousness_meter.ub.zip",
        "consciousness_visualizer.ub.zip"
    ]
    
    print("🎨 ConsciousnessIcon: Pentagon Init Complete")

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Initialize icon display
    _setup_icon_display()
    
    # Connect to consciousness changes if auto-update enabled
    if auto_update:
        _connect_consciousness_signals()
    
    print("🎨 ConsciousnessIcon: Pentagon Ready Complete")

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Update glow effect for higher consciousness levels
    if glow_enabled and consciousness_level >= 5:
        _update_glow_effect(delta)

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # Handle icon interaction
    if event is InputEventMouseButton and event.pressed:
        if _is_mouse_over_icon():
            _on_icon_clicked()

func pentagon_sewers() -> void:
    print("🎨 ConsciousnessIcon: Pentagon Sewers")
    
    # Cleanup animations
    if animation_player and animation_player.is_playing():
        animation_player.stop()
    
    super.pentagon_sewers()

# ===== ICON MANAGEMENT =====

func _setup_icon_display() -> void:
    """Initialize the icon display based on current consciousness level"""
    if not icon_sprite:
        push_error("ConsciousnessIcon: IconSprite node not found!")
        return
    
    update_icon_for_level(consciousness_level)

func update_icon_for_level(level: int) -> void:
    """Update icon to display the specified consciousness level"""
    if level < 0 or level > 7:
        push_warning("ConsciousnessIcon: Invalid consciousness level: %d" % level)
        level = clamp(level, 0, 7)
    
    consciousness_level = level
    
    # Load and set the appropriate icon
    var icon_path = icon_paths.get(level, icon_paths[0])
    var icon_texture = load(icon_path)
    
    if icon_texture:
        icon_sprite.texture = icon_texture
        icon_sprite.modulate = consciousness_colors[level]
        
        # Resize to specified size
        if icon_texture.get_size() != icon_size:
            var scale_factor = icon_size / icon_texture.get_size()
            icon_sprite.scale = scale_factor
        
        print("🎨 Updated icon to consciousness level %d" % level)
        
        # Trigger animation if enabled
        if animation_enabled and animation_player:
            _play_consciousness_animation(level)
        
        # Update glow effect
        _update_glow_for_level(level)
    else:
        push_error("ConsciousnessIcon: Could not load icon: %s" % icon_path)

func _play_consciousness_animation(level: int) -> void:
    """Play appropriate animation for consciousness level"""
    if not animation_player:
        return
    
    var animation_name = ""
    match level:
        0: animation_name = "dormant_pulse"
        1: animation_name = "awakening_flicker"
        2, 3: animation_name = "gentle_glow"
        4: animation_name = "golden_shine"
        5, 6, 7: animation_name = "transcendent_radiance"
    
    if animation_player.has_animation(animation_name):
        animation_player.play(animation_name)
    else:
        # Fallback to simple pulse
        animation_player.play("default_pulse")

func _update_glow_for_level(level: int) -> void:
    """Update glow effect based on consciousness level"""
    if not glow_effect:
        return
    
    if level >= 5:  # Transcendent levels get glow
        glow_effect.visible = true
        glow_effect.modulate = consciousness_colors[level]
        glow_effect.modulate.a = 0.6  # Semi-transparent glow
    else:
        glow_effect.visible = false

func _update_glow_effect(delta: float) -> void:
    """Animate the glow effect for high consciousness levels"""
    if not glow_effect or not glow_effect.visible:
        return
    
    # Pulsing glow animation
    var pulse = sin(Time.get_time_dict_from_system().msec * 0.005) * 0.3 + 0.7
    glow_effect.modulate.a = pulse * 0.6

# ===== EVENT HANDLING =====

func _connect_consciousness_signals() -> void:
    """Connect to consciousness change signals"""
    # Connect to parent if it's a Universal Being
    var parent_being = get_parent()
    if parent_being and parent_being.has_signal("consciousness_changed"):
        parent_being.consciousness_changed.connect(_on_consciousness_changed)

func _on_consciousness_changed(new_level: int) -> void:
    """Handle consciousness level changes"""
    print("🎨 ConsciousnessIcon: Consciousness changed to %d" % new_level)
    update_icon_for_level(new_level)

func _is_mouse_over_icon() -> bool:
    """Check if mouse is over the icon"""
    if not icon_sprite:
        return false
    
    var mouse_pos = get_viewport().get_mouse_position()
    var icon_rect = Rect2(
        icon_sprite.global_position - icon_sprite.scale * icon_size / 2,
        icon_sprite.scale * icon_size
    )
    return icon_rect.has_point(mouse_pos)

func _on_icon_clicked() -> void:
    """Handle icon click events"""
    print("🎨 ConsciousnessIcon clicked! Level: %d" % consciousness_level)
    
    # Emit signal for other systems
    if has_signal("icon_clicked"):
        emit_signal("icon_clicked", consciousness_level)
    
    # Play click animation
    if animation_player and animation_player.has_animation("click_response"):
        animation_player.play("click_response")

# ===== AI INTEGRATION =====

signal icon_clicked(consciousness_level: int)
signal consciousness_visualized(level: int, color: Color)

func ai_interface() -> Dictionary:
    """AI interface for Gemma and other AI systems"""
    var base = super.ai_interface()
    base.custom_commands = [
        "set_consciousness",
        "get_consciousness_info", 
        "animate_transition",
        "toggle_glow",
        "cycle_levels"
    ]
    base.consciousness_data = {
        "current_level": consciousness_level,
        "available_levels": range(8),
        "colors": consciousness_colors,
        "icon_paths": icon_paths
    }
    return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """AI method invocation"""
    var result: Variant = null
    
    match method_name:
        "set_consciousness":
            if args.size() > 0:
                var level = int(args[0])
                update_icon_for_level(level)
                result = "Consciousness set to level %d" % level
            else:
                result = "No level specified"
        
        "get_consciousness_info":
            result = {
                "level": consciousness_level,
                "color": consciousness_colors[consciousness_level],
                "icon_path": icon_paths[consciousness_level],
                "glow_enabled": glow_enabled and consciousness_level >= 5
            }
        
        "animate_transition":
            if args.size() > 0:
                var target_level = int(args[0])
                _animate_consciousness_transition(target_level)
                result = "Animating transition to level %d" % target_level
            else:
                result = "No target level specified"
        
        "toggle_glow":
            glow_enabled = !glow_enabled
            _update_glow_for_level(consciousness_level)
            result = "Glow effect: %s" % ("enabled" if glow_enabled else "disabled")
        
        "cycle_levels":
            var next_level = (consciousness_level + 1) % 8
            update_icon_for_level(next_level)
            result = "Cycled to consciousness level %d" % next_level
        
        _:
            result = await super.ai_invoke_method(method_name, args)
    
    return result

func _animate_consciousness_transition(target_level: int) -> void:
    """Animate transition between consciousness levels"""
    if target_level == consciousness_level:
        return
    
    # Create smooth transition animation
    var tween = create_tween()
    tween.set_parallel(true)
    
    # Fade out current icon
    tween.tween_property(icon_sprite, "modulate:a", 0.0, 0.3)
    
    # Wait and change level
    await tween.tween_delay(0.3).finished
    update_icon_for_level(target_level)
    
    # Fade in new icon
    icon_sprite.modulate.a = 0.0
    tween.tween_property(icon_sprite, "modulate:a", 1.0, 0.3)

func _to_string() -> String:
    return "ConsciousnessIcon<Level:%d>" % consciousness_level