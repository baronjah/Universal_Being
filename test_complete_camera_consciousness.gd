# ==================================================
# SCRIPT NAME: test_complete_camera_consciousness.gd
# DESCRIPTION: Complete test for all 8 consciousness levels
# PURPOSE: Verify the entire camera consciousness system
# ==================================================

extends Node3D

var camera_being: CameraUniversalBeing
var consciousness_descriptions: Array[String] = [
    "Dormant - No consciousness, basic perception",
    "Awakening - Vignette appears at the edges of vision", 
    "Aware - Depth perception emerges, focus and blur",
    "Conscious - Reality glows with consciousness bloom",
    "Enlightened - Reality splits into component colors",
    "Transcendent - Space-time warps around awareness",
    "Cosmic - Multiple realities seen simultaneously", 
    "Beyond - All effects unified, reality breathes"
]

var test_timer: Timer
var current_test_level: int = 0
var auto_mode: bool = false

func _ready():
    print("\n🎬 === COMPLETE CAMERA CONSCIOUSNESS TEST ===")
    print("🎬 Testing all 8 levels of consciousness effects")
    
    # Create test environment  
    create_test_environment()
    
    # Wait for scene setup
    await get_tree().process_frame
    
    # Create camera being
    create_conscious_camera()
    
    # Setup UI
    create_test_ui()
    
    # Setup timer for auto-progression
    setup_auto_test()
    
    print_instructions()

func create_test_environment() -> void:
    """Create objects to test effects on"""
    print("🏗️ Creating consciousness test environment...")
    
    # Create bright objects for bloom testing
    for i in range(5):
        var mesh = MeshInstance3D.new()
        mesh.mesh = SphereMesh.new()
        mesh.position = Vector3(
            randf_range(-8, 8),
            randf_range(-2, 4),
            randf_range(3, 15)  # Different distances for DOF
        )
        
        # Create emissive materials for consciousness glow
        var material = StandardMaterial3D.new()
        var hue = i / 5.0
        material.albedo_color = Color.from_hsv(hue, 0.8, 1.0)
        material.emission_enabled = true
        material.emission = material.albedo_color * 0.8
        material.emission_energy = 2.0
        mesh.material_override = material
        
        add_child(mesh)
    
    # Add geometric patterns for aberration testing
    for i in range(3):
        var cube = MeshInstance3D.new()
        cube.mesh = BoxMesh.new()
        cube.position = Vector3(i * 4 - 4, 0, 8)
        cube.scale = Vector3(0.5, 2, 0.5)
        
        var material = StandardMaterial3D.new()
        material.albedo_color = Color.WHITE
        material.emission_enabled = true
        material.emission = Color.WHITE
        material.emission_energy = 1.5
        cube.material_override = material
        
        add_child(cube)
    
    # Add lighting
    var light = DirectionalLight3D.new()
    light.position = Vector3(0, 10, 5)
    light.rotation_degrees = Vector3(-45, 0, 0)
    add_child(light)
    
    print("✅ Test environment created")

func create_conscious_camera() -> void:
    """Create camera being with effects"""
    camera_being = CameraUniversalBeing.new()
    camera_being.name = "ConsciousTestCamera"
    camera_being.consciousness_level = 0
    
    # Load camera scene
    camera_being.load_scene("res://addons/trackball_camera/camera_point.tscn")
    
    add_child(camera_being)
    
    print("🎥 Conscious camera created")

func create_test_ui() -> void:
    """Create UI for testing"""
    var ui = CanvasLayer.new()
    ui.name = "TestUI"
    add_child(ui)
    
    var container = VBoxContainer.new()
    container.position = Vector2(20, 20)
    ui.add_child(container)
    
    # Title
    var title = Label.new()
    title.text = "Complete Camera Consciousness Test"
    title.add_theme_font_size_override("font_size", 28)
    container.add_child(title)
    
    # Current level info
    var level_info = RichTextLabel.new()
    level_info.name = "LevelInfo"
    level_info.custom_minimum_size = Vector2(500, 100)
    level_info.bbcode_enabled = true
    level_info.text = get_level_info_text(0)
    container.add_child(level_info)
    
    # Controls info
    var controls = RichTextLabel.new()
    controls.custom_minimum_size = Vector2(500, 200)
    controls.bbcode_enabled = true
    controls.text = """[b]Controls:[/b]
[color=yellow]0-7 Keys:[/color] Jump to consciousness level
[color=yellow]Enter:[/color] Start/stop auto progression
[color=yellow]Space:[/color] Next level manually
[color=yellow]R:[/color] Reset to level 0
[color=yellow]P:[/color] Print current shader info
[color=yellow]Mouse:[/color] Orbit camera (trackball)"""
    container.add_child(controls)
    
    # Performance info
    var perf_info = Label.new()
    perf_info.name = "PerformanceInfo"
    perf_info.text = "FPS: 60"
    container.add_child(perf_info)

func setup_auto_test() -> void:
    """Setup automatic progression timer"""
    test_timer = Timer.new()
    test_timer.wait_time = 4.0  # 4 seconds per level
    test_timer.timeout.connect(_on_auto_progress)
    add_child(test_timer)

func get_level_info_text(level: int) -> String:
    """Get formatted info for current level"""
    var color_map = [
        "gray", "white", "cyan", "green", 
        "yellow", "magenta", "red", "orange"
    ]
    
    var description = consciousness_descriptions[level] if level < consciousness_descriptions.size() else "Unknown"
    
    return "[b][color=%s]Level %d: %s[/color][/b]\n[i]%s[/i]" % [
        color_map[level], level, 
        ["DORMANT", "AWAKENING", "AWARE", "CONSCIOUS", "ENLIGHTENED", "TRANSCENDENT", "COSMIC", "BEYOND"][level],
        description
    ]

func print_instructions() -> void:
    """Print usage instructions"""
    print("\n🎮 === TEST CONTROLS ===")
    print("🎮 0-7 Keys: Jump to consciousness level")
    print("🎮 Enter: Start/stop auto progression (%s)" % ("ON" if auto_mode else "OFF"))
    print("🎮 Space: Next level manually")
    print("🎮 R: Reset to level 0")
    print("🎮 P: Print shader info")
    print("🎮 Mouse: Orbit camera")
    print("\n📊 Starting at level 0 (Dormant)")

func _input(event: InputEvent) -> void:
    """Handle test controls"""
    # Number keys for direct level setting
    for i in range(8):
        if event.is_action_pressed("ui_%d" % i) or event.is_action_pressed("key_%d" % i):
            set_consciousness_level(i)
            return
    
    # Auto progression toggle
    if event.is_action_pressed("ui_accept"):  # Enter
        toggle_auto_mode()
    
    # Manual next level
    elif event.is_action_pressed("ui_select"):  # Space
        next_level()
    
    # Reset to level 0
    elif event.is_action_pressed("ui_r"):
        set_consciousness_level(0)
    
    # Print shader info
    elif event.is_action_pressed("ui_p"):
        print_shader_info()

func set_consciousness_level(level: int) -> void:
    """Set specific consciousness level"""
    if not camera_being:
        return
    
    var old_level = camera_being.consciousness_level
    camera_being.consciousness_level = level
    current_test_level = level
    
    # Trigger consciousness change
    if camera_being.has_method("_on_consciousness_changed"):
        camera_being._on_consciousness_changed(level)
    
    update_ui()
    
    print("\n🧠 Consciousness Level: %d → %d" % [old_level, level])
    print("🎆 Effect: %s" % consciousness_descriptions[level])
    
    # Special announcements for major levels
    match level:
        3:
            print("🌟 Consciousness blooms! Reality begins to glow...")
        5:
            print("🌀 Space-time bends around your awareness...")
        7:
            print("✨ MAXIMUM CONSCIOUSNESS - Reality itself breathes with you!")

func next_level() -> void:
    """Advance to next consciousness level"""
    var next = (current_test_level + 1) % 8
    set_consciousness_level(next)

func toggle_auto_mode() -> void:
    """Toggle automatic progression"""
    auto_mode = !auto_mode
    
    if auto_mode:
        test_timer.start()
        print("▶️ Auto progression started (4s per level)")
    else:
        test_timer.stop()
        print("⏸️ Auto progression stopped")

func _on_auto_progress() -> void:
    """Auto progression timer callback"""
    if auto_mode:
        next_level()

func print_shader_info() -> void:
    """Print current shader information"""
    if not camera_being:
        return
    
    print("\n📊 === SHADER DEBUG INFO ===")
    print("📊 Current consciousness level: %d" % camera_being.consciousness_level)
    
    if camera_being.camera_effects:
        var debug_info = camera_being.camera_effects.get_debug_info() if camera_being.camera_effects.has_method("get_debug_info") else {}
        for key in debug_info:
            print("📊 %s: %s" % [key, debug_info[key]])
    else:
        print("📊 No camera effects component found")

func update_ui() -> void:
    """Update UI elements"""
    var level_info = get_node_or_null("TestUI/VBoxContainer/LevelInfo")
    if level_info:
        level_info.text = get_level_info_text(current_test_level)
    
    var perf_info = get_node_or_null("TestUI/VBoxContainer/PerformanceInfo")
    if perf_info:
        perf_info.text = "FPS: %d | Level: %d/%d | Auto: %s" % [
            Engine.get_frames_per_second(),
            current_test_level,
            7,
            "ON" if auto_mode else "OFF"
        ]

func _process(_delta: float) -> void:
    """Update performance display"""
    update_ui()

func _exit_tree() -> void:
    """Cleanup"""
    if test_timer:
        test_timer.stop()
    
    print("🎬 Complete camera consciousness test ended")