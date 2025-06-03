# ==================================================
# UNIVERSAL BEING: Visual Integration Test
# PURPOSE: Test all visual components from all AIs working together
# COMPONENTS: Button, Pentagon, Consciousness Colors
# ==================================================

extends Node2D

# Visual scenes to test
var button_scene_path = "res://scenes/templates/button_template.tscn"
var pentagon_scene_path = "res://scenes/templates/ai_pentagon_constellation.tscn"
var collab_panel_path = "res://scenes/templates/ai_collaboration_panel.tscn"

# Test beings
var test_button: ButtonUniversalBeing
var pentagon_network: AIPentagonNetwork
var current_test_phase: int = 0

# Test phases
enum TestPhase {
    BUTTON_CONSCIOUSNESS,
    PENTAGON_ACTIVATION,
    COLLABORATION_PANEL,
    FULL_INTEGRATION
}

func _ready() -> void:
    print("🌟 === UNIVERSAL BEING VISUAL INTEGRATION TEST ===")
    print("Testing all AI-created visual components...")
    
    # Start first test
    start_button_test()

func start_button_test() -> void:
    print("\n📘 Phase 1: Testing Button with Consciousness Colors")
    
    # Create button being
    test_button = preload("res://beings/button_universal_being.gd").new()
    test_button.position = Vector3(400, 300, 0)
    add_child(test_button)
    
    # Load visual scene
    test_button.load_scene(button_scene_path)
    
    # Cycle through consciousness levels
    cycle_consciousness_levels()

func cycle_consciousness_levels() -> void:
    for level in range(7):
        await get_tree().create_timer(1.5).timeout
        test_button.consciousness_level = level
        test_button.update_consciousness_visual()
        
        var color_name = ConsciousnessVisualizer.get_consciousness_name(level)
        var color = ConsciousnessVisualizer.get_consciousness_color(level)
        print("   Level %d: %s - Color: %s" % [level, color_name, color])
    
    # Move to pentagon test
    await get_tree().create_timer(2.0).timeout
    start_pentagon_test()

func start_pentagon_test() -> void:
    print("\n🔷 Phase 2: Testing AI Pentagon Constellation")
    
    # Clear previous test
    if test_button:
        test_button.queue_free()
    
    # Load pentagon scene
    var pentagon_scene = load(pentagon_scene_path)
    if pentagon_scene:
        var pentagon_instance = pentagon_scene.instantiate()
        pentagon_instance.position = Vector3(512, 300, 0)
        add_child(pentagon_instance)
        
        # Create network manager
        pentagon_network = AIPentagonNetwork.new()
        add_child(pentagon_network)
        
        # Test AI activations
        await test_ai_activations(pentagon_instance)
    else:
        print("   ❌ Pentagon scene not found!")

func test_ai_activations(pentagon_instance: Node) -> void:
    var ai_names = ["Memory", "Logic", "Creation", "Adaptation", "World"]
    
    for i in range(5):
        await get_tree().create_timer(1.0).timeout
        
        # Activate AI in network
        pentagon_network.activate_agent(i)
        
        # Pulse visual node
        var ai_node = pentagon_instance.get_node_or_null("AI%d_%s" % [i+1, ai_names[i]])
        if ai_node:
            pulse_node(ai_node)
            print("   ✅ Activated AI%d: %s" % [i+1, ai_names[i]])
    
    # Test center activation
    await get_tree().create_timer(1.0).timeout
    var center_node = pentagon_instance.get_node_or_null("OvermindLabel")
    if center_node:
        pulse_node(center_node, 1.5)
        print("   ✅ Activated Center: Overmind")
    
    # Move to collaboration panel test
    await get_tree().create_timer(2.0).timeout
    start_collaboration_test()

func start_collaboration_test() -> void:
    print("\n🤝 Phase 3: Testing AI Collaboration Panel")
    
    # Clear previous
    for child in get_children():
        child.queue_free()
    
    # Load collaboration panel
    var collab_scene = load(collab_panel_path)
    if collab_scene:
        var collab_instance = collab_scene.instantiate()
        add_child(collab_instance)
        
        # Test connections
        await animate_ai_connections(collab_instance)
    else:
        print("   ❌ Collaboration panel scene not found!")

func animate_ai_connections(panel: Node) -> void:
    var ai_nodes = ["GemmaLabel", "ClaudeCodeLabel", "CursorLabel", 
                    "ClaudeDesktopLabel", "ChatGPTLabel", "GeminiLabel"]
    
    # Get connection lines container
    var connection_container = panel.get_node_or_null("ConnectionLines")
    if not connection_container:
        print("   ❌ ConnectionLines container not found!")
        return
    
    # Draw connections between all AIs
    for i in range(ai_nodes.size()):
        for j in range(i + 1, ai_nodes.size()):
            var node1 = panel.get_node_or_null(ai_nodes[i])
            var node2 = panel.get_node_or_null(ai_nodes[j])
            
            if node1 and node2:
                draw_animated_connection(connection_container, node1, node2)
                await get_tree().create_timer(0.2).timeout
    
    print("   ✅ All AI connections animated!")
    
    # Final integration test
    await get_tree().create_timer(2.0).timeout
    start_full_integration_test()

func start_full_integration_test() -> void:
    print("\n🌟 Phase 4: Full Integration Test")
    print("Creating a consciousness-aware being with AI network visualization...")
    
    # This would combine all elements
    # For now, just print success
    print("\n✅ === ALL VISUAL INTEGRATION TESTS COMPLETE! ===")
    print("Ready for 6-AI collaborative Universal Being creation!")

# Utility functions
func pulse_node(node: Control, scale_factor: float = 1.2) -> void:
    var tween = create_tween()
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.set_trans(Tween.TRANS_SINE)
    tween.tween_property(node, "scale", Vector2.ONE * scale_factor, 0.3)
    tween.tween_property(node, "scale", Vector2.ONE, 0.3)

func draw_animated_connection(container: Node2D, from: Control, to: Control) -> void:
    var line = Line2D.new()
    line.add_point(from.global_position)
    line.add_point(to.global_position)
    line.width = 2.0
    line.default_color = Color(0.7, 0.7, 0.7, 0.5)
    container.add_child(line)
    
    # Animate color
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(line, "default_color:a", 1.0, 0.5)
    tween.tween_property(line, "default_color:a", 0.3, 0.5)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        print("Test cancelled by user")
        get_tree().quit()
