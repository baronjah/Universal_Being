# ==================================================
# UNIVERSAL BEING: Button Universal Being
# TYPE: ui_button
# PURPOSE: First example of Luminus blueprint implementation
# COMPONENTS: ui_behavior.ub.zip
# SCENES: scenes/ui/button_template.tscn
# ==================================================

extends UniversalBeing
class_name ButtonUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var click_count: int = 0
@export var button_text: String = "Click Me!"
@export var consciousness_per_click: float = 0.1

# Button visual state
var button_node: Button = null
var original_color: Color
var is_hovered: bool = false

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()  # 🌱 ALWAYS CALL SUPER FIRST
    
    being_type = "ui_button"
    being_name = "Quantum Button"
    consciousness_level = 1
    
    # This button can evolve!
    evolution_state.can_become = [
        "progress_bar.ub.zip",
        "slider.ub.zip",
        "consciousness_portal.ub.zip"
    ]
    
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()  # 🔄 ALWAYS CALL SUPER FIRST
    
    # Load the button scene
    load_scene("res://scenes/ui/button_template.tscn")
    
    # Find the button node
    button_node = get_scene_node("Button") as Button
    if button_node:
        button_node.text = button_text
        button_node.pressed.connect(_on_button_pressed)
        button_node.mouse_entered.connect(_on_mouse_entered)
        button_node.mouse_exited.connect(_on_mouse_exited)
        original_color = button_node.modulate
    
    # Add UI behavior component
    add_component("res://components/ui_behavior.ub.zip")
    
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)  # ⚡ ALWAYS CALL SUPER FIRST
    
    # Pulse effect based on consciousness
    if button_node and is_hovered:
        var pulse = sin(Time.get_ticks_msec() / 1000.0 * consciousness_level) * 0.1 + 1.0
        button_node.scale = Vector2(pulse, pulse)
    
    # Update button text with consciousness
    if button_node:
        button_node.text = "%s [Clicks: %d]" % [button_text, click_count]

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)  # 👂 ALWAYS CALL SUPER FIRST
    
    # Handle spacebar as alternative click
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_SPACE:
            _on_button_pressed()

func pentagon_sewers() -> void:
    print("🌟 %s: Pentagon Sewers - Total clicks: %d" % [being_name, click_count])
    
    # Clean up button connections
    if button_node:
        if button_node.pressed.is_connected(_on_button_pressed):
            button_node.pressed.disconnect(_on_button_pressed)
    
    super.pentagon_sewers()  # 💀 ALWAYS CALL SUPER LAST

# ===== BUTTON-SPECIFIC METHODS =====

func _on_button_pressed() -> void:
    click_count += 1
    
    # Increase consciousness with each click
    consciousness_level = mini(5, 1 + int(click_count * consciousness_per_click))
    update_consciousness_visual()
    
    print("🔘 %s clicked! Count: %d, Consciousness: %d" % [being_name, click_count, consciousness_level])
    
    # Emit consciousness awakening at milestones
    if click_count in [10, 25, 50, 100]:
        consciousness_awakened.emit(consciousness_level)
        
    # Evolution trigger
    if click_count >= 42 and can_evolve_to("consciousness_portal.ub.zip"):
        print("🌟 %s: Ready to evolve into Consciousness Portal!" % being_name)

func _on_mouse_entered() -> void:
    is_hovered = true
    if button_node:
        button_node.modulate = consciousness_aura_color

func _on_mouse_exited() -> void:
    is_hovered = false
    if button_node:
        button_node.modulate = original_color
        button_node.scale = Vector2.ONE

func update_consciousness_visual() -> void:
    # Call parent update
    super.update_consciousness_visual()
    
    # Use the new ConsciousnessVisualizer for consistent visuals
    if scene_instance:
        ConsciousnessVisualizer.apply_consciousness_visual(self, scene_instance)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    var base = super.ai_interface()
    base.custom_commands = [
        "reset_clicks",
        "magic_press",
        "set_button_text",
        "trigger_evolution"
    ]
    base.button_state = {
        "clicks": click_count,
        "text": button_text,
        "hovered": is_hovered
    }
    return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    match method_name:
        "reset_clicks":
            click_count = 0
            return "Button clicks reset to 0"
        "magic_press":
            var times = args[0] if args.size() > 0 else 42
            for i in times:
                _on_button_pressed()
            return "Magic pressed %d times!" % times
        "set_button_text":
            if args.size() > 0:
                button_text = str(args[0])
                return "Button text updated to: " + button_text
            return "No text provided"
        "trigger_evolution":
            if click_count >= 42:
                evolve_to("consciousness_portal.ub.zip")
                return "Evolution initiated!"
            return "Not enough clicks for evolution (need 42)"
        _:
            return super.ai_invoke_method(method_name, args)

func _to_string() -> String:
    return "ButtonUniversalBeing<%s> [Clicks:%d, Consciousness:%d]" % [being_name, click_count, consciousness_level]