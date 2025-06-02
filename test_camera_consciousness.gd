# ==================================================
# SCRIPT NAME: test_camera_consciousness.gd
# DESCRIPTION: Test scene for camera consciousness effects
# PURPOSE: Verify camera system with effects integration
# ==================================================

extends Node3D

var camera_being: CameraUniversalBeing
var test_objects: Array[Node3D] = []
var consciousness_timer: Timer

func _ready():
    print("🎬 Camera Consciousness Test Scene Starting...")
    
    # Create test environment
    create_test_environment()
    
    # Wait a frame for scene to be ready
    await get_tree().process_frame
    
    # Create conscious camera
    create_conscious_camera()
    
    # Setup automatic consciousness evolution test
    setup_consciousness_test()
    
    print("🎬 Test Scene Ready!")
    print("🎬 Controls:")
    print("   - Mouse: Orbit camera")
    print("   - Q/E: Roll camera")  
    print("   - 1-7: Set consciousness level manually")
    print("   - Space: Toggle effects")
    print("   - R: Reset camera")

func create_test_environment() -> void:
    """Create some objects to look at"""
    print("🏗️ Creating test environment...")
    
    # Create several spheres at different distances
    for i in range(8):
        var mesh_instance = MeshInstance3D.new()
        mesh_instance.mesh = SphereMesh.new()
        mesh_instance.name = "TestSphere_%d" % i
        
        # Position in a circle pattern
        var angle = (i / 8.0) * PI * 2
        var radius = 5.0 + (i * 2.0)  # Different distances for DOF testing
        mesh_instance.position = Vector3(
            cos(angle) * radius,
            sin(i * 0.5) * 2.0,  # Varying heights
            sin(angle) * radius
        )
        
        # Add material with consciousness colors
        var material = StandardMaterial3D.new()
        material.albedo_color = get_consciousness_color(i)
        material.emission_energy = 0.2
        material.emission = material.albedo_color
        mesh_instance.material_override = material
        
        add_child(mesh_instance)
        test_objects.append(mesh_instance)
    
    # Add some lighting
    var light = DirectionalLight3D.new()
    light.position = Vector3(0, 10, 5)
    light.rotation_degrees = Vector3(-45, 0, 0)
    add_child(light)
    
    print("🏗️ Created %d test objects" % test_objects.size())

func get_consciousness_color(level: int) -> Color:
    """Get consciousness color for visualization"""
    var colors = [
        Color.GRAY,        # 0: Dormant
        Color.WHITE,       # 1: Awakening  
        Color.CYAN,        # 2: Aware
        Color.GREEN,       # 3: Active
        Color.YELLOW,      # 4: Enlightened
        Color.MAGENTA,     # 5: Transcendent
        Color.RED,         # 6: Cosmic
        Color.WHITE        # 7: Beyond
    ]
    return colors[level % colors.size()]

func create_conscious_camera() -> void:
    """Create a conscious camera being"""
    print("🎥 Creating conscious camera...")
    
    # Load camera scene first (the trackball addon scene)
    # var camera_scene = preload("res://addons/goutte.camera.trackball/camera_point.tscn")
    var camera_scene = null  # TODO: Install trackball addon
    if not camera_scene:
        push_error("❌ Camera scene not found! Please ensure trackball addon is installed")
        return
    
    # Create camera being
    camera_being = CameraUniversalBeing.new()
    camera_being.name = "ConsciousCamera"
    camera_being.consciousness_level = 1  # Start with awakening
    
    # Load the camera scene into the being
    camera_being.load_scene("res://addons/goutte.camera.trackball/camera_point.tscn")
    
    # Add to our test scene
    add_child(camera_being)
    
    print("🎥 Conscious camera created with consciousness level: %d" % camera_being.consciousness_level)

func setup_consciousness_test() -> void:
    """Setup automatic consciousness evolution for testing"""
    consciousness_timer = Timer.new()
    consciousness_timer.wait_time = 3.0  # Change every 3 seconds
    consciousness_timer.timeout.connect(_on_consciousness_timer_timeout)
    add_child(consciousness_timer)
    consciousness_timer.start()
    
    print("⏰ Automatic consciousness evolution enabled (every 3s)")

func _on_consciousness_timer_timeout() -> void:
    """Automatically evolve camera consciousness for testing"""
    if not camera_being:
        return
        
    # Cycle through consciousness levels
    camera_being.consciousness_level = (camera_being.consciousness_level % 7) + 1
    
    print("📈 Auto-evolved camera to consciousness level: %d" % camera_being.consciousness_level)
    
    # Show effect description
    var descriptions = [
        "No effects",
        "Vignette awakening", 
        "Depth of field awareness",
        "Consciousness bloom",
        "Chromatic aberration",
        "Reality distortion", 
        "Quantum vision",
        "Consciousness pulse"
    ]
    
    var level = camera_being.consciousness_level
    if level < descriptions.size():
        print("🎆 Effect: %s" % descriptions[level])

func _input(event: InputEvent) -> void:
    """Handle test input"""
    if not camera_being:
        return
    
    # Manual consciousness level setting
    if event.is_action_pressed("ui_1"):
        camera_being.consciousness_level = 1
        print("🎥 Set consciousness level: 1 (Awakening)")
    elif event.is_action_pressed("ui_2"):
        camera_being.consciousness_level = 2
        print("🎥 Set consciousness level: 2 (Aware)")
    elif event.is_action_pressed("ui_3"):
        camera_being.consciousness_level = 3
        print("🎥 Set consciousness level: 3 (Conscious)")
    elif event.is_action_pressed("ui_4"):
        camera_being.consciousness_level = 4
        print("🎥 Set consciousness level: 4 (Enlightened)")
    elif event.is_action_pressed("ui_5"):
        camera_being.consciousness_level = 5
        print("🎥 Set consciousness level: 5 (Transcendent)")
    elif event.is_action_pressed("ui_6"):
        camera_being.consciousness_level = 6
        print("🎥 Set consciousness level: 6 (Cosmic)")
    elif event.is_action_pressed("ui_7"):
        camera_being.consciousness_level = 7
        print("🎥 Set consciousness level: 7 (Beyond)")
    
    # Toggle effects
    elif event.is_action_pressed("ui_accept"):  # Space
        if camera_being.has_method("set_effects_enabled"):
            camera_being.effects_enabled = !camera_being.effects_enabled
            camera_being.set_effects_enabled(camera_being.effects_enabled)
        print("🎆 Camera effects: %s" % ("enabled" if camera_being.effects_enabled else "disabled"))
    
    # Reset camera
    elif event.is_action_pressed("ui_r"):
        if camera_being.has_method("reset_camera_position"):
            camera_being.reset_camera_position()
        print("🔄 Camera position reset")

func _exit_tree() -> void:
    """Cleanup"""
    if consciousness_timer:
        consciousness_timer.stop()
    
    print("🎬 Camera consciousness test ended")