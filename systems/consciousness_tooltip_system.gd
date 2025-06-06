# =============================================================
# UNIVERSAL BEING: CONSCIOUSNESS TOOLTIP SYSTEM
# TYPE: UI/Tooltip
# PURPOSE: Show narrative consciousness tooltips above beings
# COMPONENTS: consciousness_icon assets (level_0.png...level_7.png)
# SCENES: None (pure code, attach to autoload/scene root)
# =============================================================

extends UniversalBeing
class_name ConsciousnessTooltipSystem

signal tooltip_shown(being: UniversalBeing)
signal tooltip_hidden()

const TOOLTIPS := {
    0: "The Void whispers: 'I am not, yet I could be...'",
    1: "Light speaks: 'I am! The first thought ignites!'",
    2: "Waters murmur: 'I choose, therefore I divide...'",
    3: "Earth declares: 'I root, I grow, I foundation...'",
    4: "Stars sing: 'We are six, we guide as one!'",
    5: "Life dances: 'All forms flow through me!'",
    6: "Image reflects: 'I see myself in creation...'",
    7: "Rest breathes: 'Complete, yet ever-beginning...'"
}

const CONSCIOUSNESS_COLORS := {
    0: Color.GRAY,
    1: Color("e0e0e0"),
    2: Color("68aaff"),
    3: Color("7bff8a"),
    4: Color("ffe24d"),
    5: Color("ffffff"),
    6: Color("ff4256"),
    7: Color("a27dff")
}

const ICON_PATH_FORMAT := "res://assets/icons/consciousness/level_%d.png"

# ----- Pentagon Methods (Lifecycle) -----

func pentagon_init() -> void:
    # Custom singleton management if needed
    pass

func pentagon_ready() -> void:
    # UI nodes are created in _ready
    pass

func pentagon_process(delta: float) -> void:
    # For pulsing/persistent effects
    if _visible:
        _pulse_bg(delta)

func pentagon_input(event: InputEvent) -> void:
    pass

func pentagon_sewers() -> void:
    # Cleanup, remove from scene tree if needed
    queue_free()

# ----- UI Nodes -----
var _bg: ColorRect
var _icon: TextureRect
var _label: Label
var _tween: Tween
var _visible: bool = false
var _current_being: UniversalBeing = null
var _pulse_time: float = 0.0

# ----- Core Godot Lifecycle -----
func _ready() -> void:
    pentagon_init()
    _create_tooltip_ui()
    pentagon_ready()

func _process(delta: float) -> void:
    pentagon_process(delta)

# ----- Tooltip UI Creation -----
func _create_tooltip_ui():
    # Background
    _bg = ColorRect.new()
    _bg.color = Color(0, 0, 0, 0.88)
    _bg.corner_radius_top_left = 12
    _bg.corner_radius_top_right = 12
    _bg.corner_radius_bottom_left = 16
    _bg.corner_radius_bottom_right = 16
    _bg.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
    _bg.size = Vector2(320, 54)
    _bg.material = ShaderMaterial.new()
    _bg.material.shader = Shader.new()
    _bg.material.shader.code = "
        shader_type canvas_item;
        uniform float pulse = 0.0;
        void fragment() {
            vec4 col = COLOR;
            col.rgb += vec3(0.10, 0.12, 0.16) * pulse;
            COLOR = col;
        }
    "
    add_child(_bg)
    _bg.hide()

    # Icon
    _icon = TextureRect.new()
    _icon.position = Vector2(16, 10)
    _icon.size = Vector2(32, 32)
    _icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _bg.add_child(_icon)

    # Label
    _label = Label.new()
    _label.position = Vector2(58, 14)
    _label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _label.add_theme_font_size_override("font_size", 18)
    _label.add_theme_color_override("font_color", Color("cccccc"))
    _label.add_theme_constant_override("outline_size", 2)
    _label.add_theme_color_override("font_outline_color", Color("ffffff"))
    _label.text = ""
    _label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _label.set("theme_override_colors/font_shadow_color", Color(1,1,1,0.45))
    _label.set("theme_override_constants/shadow_offset_x", 2)
    _label.set("theme_override_constants/shadow_offset_y", 2)
    _bg.add_child(_label)

    # Tween
    _tween = create_tween()
    _tween.stop()

# ----- Tooltip System Methods -----

func show_tooltip(being: UniversalBeing, position: Vector2) -> void:
    _current_being = being
    var level := being.consciousness_level if being.has("consciousness_level") else 0
    update_tooltip_text(level, being)
    _position_tooltip(position)
    _visible = true
    _bg.show()
    _bg.modulate.a = 0.0
    _label.modulate = Color(1,1,1,0.0)
    _icon.modulate = Color(1,1,1,0.0)
    _tween.kill() # Kill any previous tweens
    _tween = create_tween()
    _tween.tween_property(_bg, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE)
    _tween.parallel().tween_property(_label, "modulate:a", 1.0, 0.22)
    _tween.parallel().tween_property(_icon, "modulate:a", 1.0, 0.22)
    tooltip_shown.emit(being)

func hide_tooltip() -> void:
    if not _visible:
        return
    _visible = false
    _tween.kill()
    _tween = create_tween()
    _tween.tween_property(_bg, "modulate:a", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
    _tween.parallel().tween_property(_label, "modulate:a", 0.0, 0.13)
    _tween.parallel().tween_property(_icon, "modulate:a", 0.0, 0.13)
    _tween.finished.connect(_on_hide_fade_done)
    tooltip_hidden.emit()

func _on_hide_fade_done():
    _bg.hide()
    _label.text = ""
    _icon.texture = null
    _current_being = null

func update_tooltip_text(level: int, being: UniversalBeing = null) -> void:
    # Use being's custom narrative if present
    var narrative := ""
    if being and being.has_method("get_custom_narrative_for_level"):
        narrative = being.get_custom_narrative_for_level(level)
    else:
        narrative = get_narrative_for_level(level)
    _label.text = narrative
    _label.add_theme_color_override("font_color", CONSCIOUSNESS_COLORS.get(level, Color.WHITE))
    _label.add_theme_color_override("font_outline_color", CONSCIOUSNESS_COLORS.get(level, Color.WHITE).inverted())
    _icon.texture = load(ICON_PATH_FORMAT % level)
    _icon.modulate = CONSCIOUSNESS_COLORS.get(level, Color.WHITE)
    _pulse_time = 0.0

func get_narrative_for_level(level: int) -> String:
    return TOOLTIPS.get(level, "...")
    
func _position_tooltip(pos: Vector2) -> void:
    # Show tooltip above the being (project world to screen if needed)
    var offset := Vector2(0, -70)
    _bg.global_position = pos + offset

func _pulse_bg(delta: float) -> void:
    # Subtle pulsing effect for background glow
    _pulse_time += delta
    var pulse := 0.18 + 0.09 * sin(_pulse_time * 2.5)
    if _bg.material and _bg.material is ShaderMaterial:
        _bg.material.set_shader_parameter("pulse", pulse)

# ----- Static Singleton Accessor -----

static func get_instance() -> ConsciousnessTooltipSystem:
    return Engine.get_main_loop().get_root().get_node_or_null("ConsciousnessTooltipSystem")

# ----- Optional: Pentagon Stubs (for full pattern) -----
# (Unused but provided for clarity/extension)
func pentagon_is_ready() -> bool:
    return _bg != null and _bg.visible

# ----- Example: Integration Hook -----
# To be called from UniversalBeing or manager:
#   ConsciousnessTooltipSystem.get_instance().show_tooltip(self, screen_pos)
#   ConsciousnessTooltipSystem.get_instance().hide_tooltip()

# END FILE