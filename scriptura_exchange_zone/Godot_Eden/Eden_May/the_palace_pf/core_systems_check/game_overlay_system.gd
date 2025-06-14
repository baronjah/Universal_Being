extends Node

# ----- OVERLAY SYSTEM SETTINGS -----
@export_category("Overlay Settings")
@export var overlay_enabled: bool = false
@export var overlay_transparency: float = 0.5
@export var overlay_capture_rate: int = 60  # FPS for capture
@export var disable_input_passthrough: bool = false

# ----- INTEGRATION SETTINGS -----
@export_category("Integration Settings")
@export var words_in_space_path: NodePath
@export var player_controller_path: NodePath
@export var target_window_title: String = "Grand Theft Auto IV"

# ----- VISUAL SETTINGS -----
@export_category("Visual Settings")
@export var words_scale_in_overlay: float = 0.7
@export var connection_width_in_overlay: float = 0.05
@export var adapt_to_scene_lighting: bool = true
@export var use_game_colors_for_words: bool = false

# ----- COMPONENT REFERENCES -----
var words_in_space: Node
var player_controller: Node
var overlay_viewport: SubViewport
var overlay_camera: Camera3D
var external_game_texture: ViewportTexture
var external_game_rect: TextureRect
var overlay_container: Control

# ----- SYSTEM STATE -----
var is_capturing: bool = false
var current_frame_data: Image
var external_window_handle: int = -1
var overlay_mode: String = "BLEND"  # BLEND, REPLACE, ALTERNATE

# ----- SIGNALS -----
signal overlay_toggled(is_enabled)
signal external_game_connected(window_title)
signal external_game_disconnected()
signal word_manifested_from_game(word, position)

# ----- INITIALIZATION -----
func _ready():
    # Get references to components
    words_in_space = get_node_or_null(words_in_space_path)
    player_controller = get_node_or_null(player_controller_path)
    
    # Setup overlay system
    setup_overlay_system()
    
    # Try to connect to game if enabled
    if overlay_enabled:
        connect_to_external_game()

# ----- OVERLAY SYSTEM SETUP -----
func setup_overlay_system():
    # Create overlay viewport for rendering words
    overlay_viewport = SubViewport.new()
    overlay_viewport.name = "OverlayViewport"
    overlay_viewport.size = get_viewport().size
    overlay_viewport.transparent_bg = true
    overlay_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    add_child(overlay_viewport)
    
    # Create overlay camera
    overlay_camera = Camera3D.new()
    overlay_camera.name = "OverlayCamera"
    overlay_camera.current = true
    overlay_viewport.add_child(overlay_camera)
    
    # Create UI container for overlay
    overlay_container = Control.new()
    overlay_container.name = "OverlayContainer"
    overlay_container.anchor_right = 1.0
    overlay_container.anchor_bottom = 1.0
    add_child(overlay_container)
    
    # Create texture rect for external game
    external_game_rect = TextureRect.new()
    external_game_rect.name = "ExternalGameView"
    external_game_rect.anchor_right = 1.0
    external_game_rect.anchor_bottom = 1.0
    external_game_rect.expand = true
    external_game_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    overlay_container.add_child(external_game_rect)
    
    # Connect to window resize signal
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    
    # Hide overlay initially if not enabled
    overlay_container.visible = overlay_enabled

# ----- EXTERNAL GAME CONNECTION -----
func connect_to_external_game():
    # This would use native code to find and capture from external window
    # For demonstration purposes, we'll simulate successful connection
    
    # In a real implementation, you would:
    # 1. Find window by title
    # 2. Get window handle
    # 3. Setup capture mechanism (e.g., via plugin)
    
    print("Attempting to connect to external game: ", target_window_title)
    
    # Simulate successful connection
    external_window_handle = 12345  # Simulated window handle
    
    if external_window_handle != -1:
        print("Successfully connected to external game window")
        is_capturing = true
        emit_signal("external_game_connected", target_window_title)
        
        # Start capture timer
        var timer = Timer.new()
        timer.name = "CaptureTimer"
        timer.wait_time = 1.0 / overlay_capture_rate
        timer.autostart = true
        timer.timeout.connect(_on_capture_timer_timeout)
        add_child(timer)
    else:
        print("Failed to connect to external game window")

func disconnect_from_external_game():
    is_capturing = false
    external_window_handle = -1
    
    # Stop capture timer
    if has_node("CaptureTimer"):
        get_node("CaptureTimer").queue_free()
    
    emit_signal("external_game_disconnected")

# ----- CAPTURE AND RENDERING -----
func _on_capture_timer_timeout():
    if is_capturing and external_window_handle != -1:
        capture_external_game_frame()

func capture_external_game_frame():
    # In a real implementation, this would capture a frame from the external window
    # For demonstration, we'll simulate frame capture
    
    # Create a dummy texture
    var dummy_texture = ImageTexture.create_from_image(Image.create(1024, 768, false, Image.FORMAT_RGBA8))
    
    # Apply the texture to the external game view
    external_game_rect.texture = dummy_texture
    
    # Process any game data for word manifestation
    process_game_data_for_words()

func process_game_data_for_words():
    # In a real implementation, this would analyze game data to generate words
    # For demonstration, we'll simulate detecting objects occasionally
    
    if randf() < 0.01:  # 1% chance each frame
        var random_game_objects = ["car", "pedestrian", "building", "tree", "weapon", "vehicle", "shop", "street"]
        var random_object = random_game_objects[randi() % random_game_objects.size()]
        
        # Calculate a random position in 3D space
        var random_position = Vector3(
            randf_range(-10, 10),
            randf_range(0, 5),
            randf_range(-10, 10)
        )
        
        # Manifest word from game object
        manifest_word_from_game(random_object, random_position)

func manifest_word_from_game(word: String, position: Vector3):
    if words_in_space and words_in_space.has_method("add_word"):
        # Generate a unique ID for the word
        var word_id = "game_" + word + "_" + str(randi())
        
        # Determine category based on word
        var category = "object"  # Default
        
        if word in ["car", "vehicle", "weapon", "tree"]:
            category = "object"
        elif word in ["running", "driving", "shooting", "walking"]:
            category = "action"
        elif word in ["fast", "slow", "heavy", "light"]:
            category = "property"
        
        # Add the word to the 3D space
        words_in_space.add_word(word_id, word, position, category)
        
        # Emit signal
        emit_signal("word_manifested_from_game", word, position)

# ----- OVERLAY MANAGEMENT -----
func set_overlay_enabled(enabled: bool):
    overlay_enabled = enabled
    overlay_container.visible = enabled
    
    if enabled and external_window_handle == -1:
        connect_to_external_game()
    elif !enabled and external_window_handle != -1:
        disconnect_from_external_game()
    
    emit_signal("overlay_toggled", enabled)

func set_overlay_mode(mode: String):
    overlay_mode = mode
    
    match mode:
        "BLEND":
            # Set blend mode
            external_game_rect.modulate.a = overlay_transparency
        "REPLACE":
            # Replace mode - alternate between game and overlay
            external_game_rect.modulate.a = 1.0
        "ALTERNATE":
            # Setup alternating timer
            if has_node("AlternateTimer"):
                get_node("AlternateTimer").queue_free()
            
            var timer = Timer.new()
            timer.name = "AlternateTimer"
            timer.wait_time = 0.5  # Alternate every half second
            timer.autostart = true
            timer.timeout.connect(_on_alternate_timer_timeout)
            add_child(timer)

func _on_alternate_timer_timeout():
    # Toggle between game and overlay
    external_game_rect.visible = !external_game_rect.visible

# ----- HELPER FUNCTIONS -----
func _on_viewport_size_changed():
    # Update overlay viewport size
    if overlay_viewport:
        overlay_viewport.size = get_viewport().size

# ----- WORD MANIFESTATION FROM CONSOLE -----
func process_console_command(command: String):
    var parts = command.split(" ", false)
    
    if parts.size() > 0:
        match parts[0]:
            "spawn":
                if parts.size() > 1:
                    var word = parts[1]
                    
                    # Get spawn position from player
                    var spawn_pos = Vector3.ZERO
                    if player_controller:
                        spawn_pos = player_controller.global_position + (-player_controller.camera_mount.global_transform.basis.z * 2.0)
                    
                    # Manifest the word
                    manifest_word_from_game(word, spawn_pos)
                    return true
            "overlay":
                if parts.size() > 1:
                    match parts[1]:
                        "on":
                            set_overlay_enabled(true)
                            return true
                        "off":
                            set_overlay_enabled(false)
                            return true
                        "blend":
                            set_overlay_mode("BLEND")
                            return true
                        "replace":
                            set_overlay_mode("REPLACE")
                            return true
                        "alternate":
                            set_overlay_mode("ALTERNATE")
                            return true
            "capture":
                if parts.size() > 1:
                    target_window_title = parts.slice(1).join(" ")
                    if is_capturing:
                        disconnect_from_external_game()
                    connect_to_external_game()
                    return true
    
    return false

# ----- PUBLIC API -----
func set_overlay_transparency(value: float):
    overlay_transparency = clamp(value, 0.0, 1.0)
    external_game_rect.modulate.a = overlay_transparency

func capture_word_from_game_position(screen_position: Vector2):
    # Simulate extracting a word from game at the given screen position
    var possible_words = ["character", "object", "vehicle", "building", "scenery", "weapon", "item"]
    var word = possible_words[randi() % possible_words.size()]
    
    # Convert screen position to 3D world position
    var world_position = Vector3(
        (screen_position.x / get_viewport().size.x - 0.5) * 20.0,
        randf_range(0, 5),
        (screen_position.y / get_viewport().size.y - 0.5) * 20.0
    )
    
    # Manifest the word
    manifest_word_from_game(word, world_position)
    return word