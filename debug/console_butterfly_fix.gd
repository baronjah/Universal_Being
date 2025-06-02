# ==================================================
# UNIVERSAL BEING: ConsoleButterflyFix
# TYPE: Console Enhancement
# PURPOSE: Adds butterfly creation and Akashic integration to console
# COMPONENTS: None (extends console_base)
# SCENES: None (UI handled by base class)
# ==================================================

extends ConsoleBaseUniversalBeing
class_name ConsoleButterflyFixUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var butterfly_colors: Dictionary = {
    "red": Color.RED,
    "yellow": Color.YELLOW,
    "purple": Color.PURPLE,
    "green": Color.GREEN,
    "blue": Color.BLUE
}

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    # Set Universal Being identity
    being_type = "console_butterfly_fix"
    being_name = "Console Butterfly Fix"
    consciousness_level = 2
    
    print("🌟 %s: Console Butterfly Fix Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    fix_akashic_connection()
    print("🌟 %s: Console Butterfly Fix Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    # No additional processing needed

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    # No additional input handling needed

func pentagon_sewers() -> void:
    super.pentagon_sewers()

# ===== COMMAND PROCESSING =====

func execute_command(command: String) -> String:
    """Execute a console command with butterfly and Akashic support"""
    var lower_command = command.to_lower()
    
    # Natural language butterfly creation
    if lower_command.contains("butterfly"):
        return create_butterfly_from_command(command)
    
    # Akashic commands
    if lower_command.begins_with("akashic"):
        return process_akashic_command(command)
    
    # Fall back to base command processing
    return super.execute_command(command)

func create_butterfly_from_command(command: String) -> String:
    """Create a butterfly being based on command"""
    if not SystemBootstrap or not SystemBootstrap.is_system_ready():
        return "❌ System not ready for creation"
    
    # Parse color from command
    var color = Color.BLUE  # default
    for color_name in butterfly_colors:
        if command.to_lower().contains(color_name):
            color = butterfly_colors[color_name]
            break
    
    # Create butterfly
    var butterfly = SystemBootstrap.create_universal_being()
    if not butterfly:
        return "❌ Failed to create butterfly"
    
    butterfly.name = "Butterfly Being"
    butterfly.set("being_type", "butterfly")
    butterfly.set("consciousness_level", 3)
    
    # Visual
    var visual = Label.new()
    visual.text = "🦋"
    visual.add_theme_font_size_override("font_size", 48)
    visual.modulate = color
    butterfly.add_child(visual)
    
    # Add to scene
    if get_tree().current_scene:
        get_tree().current_scene.add_child(butterfly)
        butterfly.position = get_viewport().get_visible_rect().size / 2
        
        # Add fluttering animation
        var tween = butterfly.create_tween()
        tween.set_loops()
        tween.set_trans(Tween.TRANS_SINE)
        tween.tween_property(butterfly, "position", 
            butterfly.position + Vector2(100, -50), 2.0)
        tween.tween_property(butterfly, "position",
            butterfly.position + Vector2(-100, 50), 2.0)
    
    var color_name = get_color_name(color)
    if GemmaAI:
        GemmaAI.ai_message.emit("🦋 Beautiful %s butterfly manifested!" % color_name)
    
    return "✅ %s butterfly created!" % color_name

func process_akashic_command(command: String) -> String:
    """Process Akashic Records commands"""
    var akashic = SystemBootstrap.get_akashic_records() if SystemBootstrap else null
    if not akashic:
        return "❌ Akashic Records not connected"
    
    var lower_command = command.to_lower()
    if lower_command == "akashic status":
        return "🔮 Akashic Records: ONLINE\n📚 Ready to record Universal Being history"
    elif lower_command == "akashic test":
        # Test save/load
        var test_data = {"test": "data", "time": Time.get_ticks_msec()}
        return "🔮 Testing Akashic save/load..."
    
    return "❌ Unknown Akashic command"

func fix_akashic_connection() -> void:
    """Ensure connection to Akashic Records"""
    await get_tree().create_timer(0.1).timeout
    var akashic = SystemBootstrap.get_akashic_records() if SystemBootstrap else null
    if akashic:
        print("🖥️ Console: Connected to Akashic Records!")

func get_color_name(color: Color) -> String:
    """Get color name from Color value"""
    for color_name in butterfly_colors:
        if color.is_equal_approx(butterfly_colors[color_name]):
            return color_name
    return "colorful"

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    var base_interface = super.ai_interface()
    base_interface.ai_commands = ["create_butterfly", "akashic_status"]
    base_interface.ai_properties = {
        "butterfly_colors": butterfly_colors.keys()
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    match method_name:
        "create_butterfly":
            if args.size() > 0:
                return create_butterfly_from_command(args[0])
            return "No butterfly command specified"
        "akashic_status":
            return process_akashic_command("akashic status")
        _:
            return super.ai_invoke_method(method_name, args) 