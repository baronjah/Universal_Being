extends Spatial

signal word_caught(word, properties)
signal debug_triggered(word, debug_info)
signal emoticon_activated(emoticon, position, effect_type)

# References to other systems
var word_animator
var word_translator
var memory_manager
var turn_tracker

# Data sea configuration
var sea_size = Vector3(20, 8, 20)  # Width, height, depth
var word_count = 50
var data_sea_words = []
var word_nodes = {}
var caught_words = []

# YoYo system
var yo_yo_active = false
var yo_yo_node
var yo_yo_string
var yo_yo_base_position = Vector3(0, 7, 0)
var yo_yo_target_position = Vector3.ZERO
var yo_yo_state = "idle"  # idle, extending, retracting
var yo_yo_extension_speed = 5.0
var yo_yo_catch_radius = 1.5
var yo_yo_max_length = 15.0
var yo_yo_current_length = 0.0

# Emoticon system
var emoticons = ["😊", "😢", "😍", "😎", "🤔", "😱", "🌟", "💡", "❤️", "✨", 
                 "👁️", "🔥", "🌊", "🌈", "🎮", "🎲", "🧠", "👾", "⚡", "🌀"]
var active_emoticons = []
var emoticon_nodes = {}

# Debug system
var debug_mode = false
var debug_overlay
var debug_word_info = {}
var flawed_creation_chance = 0.2  # Chance of a word being "flawed" (0.0-1.0)
var flawed_words = []

# Synergy system
var synergy_connections = []
var synergy_strength = 0.0  # 0.0-1.0
var last_synergy_update = 0.0
var synergy_update_interval = 5.0  # seconds

# Trigger words for debug mode
var debug_trigger_words = ["debug", "error", "fix", "code", "analyze", "inspect", "evaluate"]

func _ready():
    # Get references to other systems
    word_animator = get_node_or_null("/root/Main/WordAnimator")
    word_translator = get_node_or_null("/root/Main/WordTranslator")
    memory_manager = get_node_or_null("/root/Main/MemoryEvolutionManager")
    turn_tracker = get_node_or_null("/root/Main/TurnTracker")
    
    # Create data sea environment
    _create_sea_environment()
    
    # Create yo-yo
    _create_yo_yo()
    
    # Create debug overlay
    _create_debug_overlay()
    
    # Populate the sea with words
    populate_data_sea()
    
    # Start processing
    set_process(true)
    set_process_input(true)

func _process(delta):
    # Update yo-yo position and state
    if yo_yo_active:
        _update_yo_yo(delta)
    
    # Update emoticons
    _update_emoticons(delta)
    
    # Update synergy system
    _update_synergy(delta)
    
    # Random chance to trigger a flawed creation
    if randf() < 0.001:  # Very small chance each frame
        _create_flawed_word()

func _input(event):
    # Handle mouse input for yo-yo control
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            # Cast ray from camera to get 3D position
            var camera = get_viewport().get_camera()
            var from = camera.project_ray_origin(event.position)
            var to = from + camera.project_ray_normal(event.position) * 100
            
            var space_state = get_world().direct_space_state
            var result = space_state.intersect_ray(from, to)
            
            if result:
                # Launch yo-yo to target position
                yo_yo_active = true
                yo_yo_target_position = result.position
                yo_yo_state = "extending"
                yo_yo_node.visible = true
    
    # Toggle debug mode with F12 key
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_F12:
            debug_mode = !debug_mode
            debug_overlay.visible = debug_mode
            
            # Update all word debug info
            if debug_mode:
                _update_all_debug_info()

# Create the visual sea environment
func _create_sea_environment():
    # Create a plane for the sea floor
    var sea_floor = MeshInstance.new()
    var plane_mesh = PlaneMesh.new()
    plane_mesh.size = Vector2(sea_size.x, sea_size.z)
    sea_floor.mesh = plane_mesh
    
    # Create material
    var material = SpatialMaterial.new()
    material.albedo_color = Color(0.1, 0.3, 0.5, 0.8)
    material.flags_transparent = true
    sea_floor.material_override = material
    
    # Position at bottom of sea
    sea_floor.translation = Vector3(0, 0, 0)
    add_child(sea_floor)
    
    # Create sea volume particles
    var particles = Particles.new()
    particles.name = "SeaParticles"
    
    # This would require a particle material - simplified version here
    var particle_material = ParticlesMaterial.new()
    particle_material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_BOX
    particle_material.emission_box_extents = Vector3(sea_size.x/2, sea_size.y/2, sea_size.z/2)
    particle_material.gravity = Vector3(0, 0.1, 0)
    particle_material.initial_velocity = 0.2
    particle_material.color = Color(0.4, 0.6, 0.9, 0.3)
    particles.process_material = particle_material
    
    # Position in center of sea volume
    particles.translation = Vector3(0, sea_size.y/2, 0)
    add_child(particles)

# Create the yo-yo object
func _create_yo_yo():
    # Create yo-yo node
    yo_yo_node = Spatial.new()
    yo_yo_node.name = "YoYo"
    add_child(yo_yo_node)
    
    # Create yo-yo model (simple sphere)
    var yo_yo_mesh = MeshInstance.new()
    var sphere = SphereMesh.new()
    sphere.radius = 0.4
    sphere.height = 0.8
    yo_yo_mesh.mesh = sphere
    
    # Create material
    var material = SpatialMaterial.new()
    material.albedo_color = Color(0.9, 0.7, 0.2)  # Gold
    material.emission_enabled = true
    material.emission = Color(0.9, 0.7, 0.2)
    material.emission_energy = 0.5
    yo_yo_mesh.material_override = material
    
    yo_yo_node.add_child(yo_yo_mesh)
    
    # Create yo-yo string
    yo_yo_string = ImmediateGeometry.new()
    yo_yo_string.name = "YoYoString"
    
    # Create string material
    var string_material = SpatialMaterial.new()
    string_material.albedo_color = Color(0.9, 0.9, 0.9)
    string_material.flags_unshaded = true
    yo_yo_string.material_override = string_material
    
    add_child(yo_yo_string)
    
    # Set initial position and hide
    yo_yo_node.translation = yo_yo_base_position
    yo_yo_node.visible = false

# Create debug overlay
func _create_debug_overlay():
    debug_overlay = Control.new()
    debug_overlay.name = "DebugOverlay"
    debug_overlay.anchor_right = 1.0
    debug_overlay.anchor_bottom = 1.0
    debug_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(debug_overlay)
    
    # Add title
    var title = Label.new()
    title.text = "DEBUG MODE - Data Sea Controller"
    title.anchor_right = 1.0
    title.align = Label.ALIGN_CENTER
    title.add_color_override("font_color", Color(1, 0.5, 0, 1))
    debug_overlay.add_child(title)
    
    # Hide by default
    debug_overlay.visible = false

# Populate the data sea with words
func populate_data_sea():
    # Define sample words or load from file/database
    var sample_words = [
        "create", "magic", "evolve", "manifest", "dream", "connect", "transform", 
        "animate", "channel", "flow", "dimension", "reality", "virtual", "memory",
        "signal", "pattern", "syntax", "element", "quantum", "cycle", "cosmic", 
        "neural", "binary", "digital", "analog", "sequence", "node", "network",
        "system", "process", "entity", "interface", "controller", "dynamic", 
        "static", "flux", "transfer", "buffer", "stream", "filter", "module",
        "daemon", "protocol", "session", "thread", "kernel", "vector", "matrix",
        "device", "terminal", "console", "output", "input", "portal", "gateway"
    ]
    
    # Add random debug trigger words
    for i in range(3):
        sample_words.append(debug_trigger_words[randi() % debug_trigger_words.size()])
    
    # Shuffle the words
    sample_words.shuffle()
    
    # Take a subset if we have more words than needed
    var words_to_create = min(sample_words.size(), word_count)
    
    # Create each word
    for i in range(words_to_create):
        var word = sample_words[i]
        var is_flawed = randf() < flawed_creation_chance
        
        # Create position within sea volume
        var pos = Vector3(
            rand_range(-sea_size.x/2, sea_size.x/2),
            rand_range(1, sea_size.y),
            rand_range(-sea_size.z/2, sea_size.z/2)
        )
        
        # Create word properties
        var properties = {
            "position": pos,
            "color": Color(rand_range(0.5, 1.0), rand_range(0.5, 1.0), rand_range(0.5, 1.0)),
            "size": rand_range(0.8, 1.5),
            "evolution_stage": randi() % 5,
            "rotation_speed": rand_range(0.2, 1.0),
            "movement_amplitude": rand_range(0.1, 0.5),
            "movement_frequency": rand_range(0.5, 2.0),
            "is_flawed": is_flawed,
            "creation_time": OS.get_unix_time(),
            "is_debug_trigger": debug_trigger_words.has(word)
        }
        
        # Store word data
        data_sea_words.append({"word": word, "properties": properties})
        
        # Mark flawed words
        if is_flawed:
            flawed_words.append(word)
        
        # Create 3D representation
        _create_word_node(word, properties)
        
        # Create debug info
        _create_debug_info(word, properties)

# Create 3D representation of a word
func _create_word_node(word, properties):
    # Create word node
    var word_node = Spatial.new()
    word_node.name = "Word_" + word
    word_node.translation = properties["position"]
    add_child(word_node)
    
    # Create 3D text mesh for the word
    # This would typically use a 3D text mesh, but for simplicity we'll use a Label3D
    var label = Label3D.new()
    label.text = word
    label.font_size = 36 * properties["size"]
    label.modulate = properties["color"]
    
    # If flawed, add visual indication
    if properties["is_flawed"]:
        label.outline_modulate = Color(1, 0, 0)
        label.outline_size = 2
    
    # If debug trigger, make it stand out
    if properties["is_debug_trigger"]:
        label.font_size *= 1.2
        label.modulate = Color(1, 0.5, 0)
    
    word_node.add_child(label)
    
    # Add emoticon if word has a strong effect
    if randf() < 0.2:  # 20% chance
        _add_emoticon_to_word(word_node, emoticons[randi() % emoticons.size()])
    
    # Store reference
    word_nodes[word] = word_node

# Create debug info for a word
func _create_debug_info(word, properties):
    var debug_info = {
        "creation_time": properties["creation_time"],
        "is_flawed": properties["is_flawed"],
        "evolution_stage": properties["evolution_stage"],
        "memory_references": 0,
        "catch_attempts": 0,
        "synergy_connections": [],
        "flawed_aspects": []
    }
    
    # Generate flawed aspects if word is flawed
    if properties["is_flawed"]:
        var flawed_aspects = ["rendering", "animation", "physics", "collision", "memory", "reference"]
        var aspect_count = randi() % 3 + 1  # 1-3 flawed aspects
        
        for i in range(aspect_count):
            debug_info["flawed_aspects"].append(flawed_aspects[randi() % flawed_aspects.size()])
    
    debug_word_info[word] = debug_info

# Add an emoticon to a word node
func _add_emoticon_to_word(word_node, emoticon_text):
    var emoticon = Label3D.new()
    emoticon.text = emoticon_text
    emoticon.font_size = 24
    emoticon.translation = Vector3(0, 0.5, 0)
    
    word_node.add_child(emoticon)
    
    # Create animation for the emoticon
    var anim_player = AnimationPlayer.new()
    word_node.add_child(anim_player)
    
    var animation = Animation.new()
    animation.length = 2.0
    animation.loop = true
    
    # Add track for position
    var track_idx = animation.add_track(Animation.TYPE_VALUE)
    animation.track_set_path(track_idx, NodePath("../") + emoticon.get_path() + ":translation")
    
    # Add keyframes
    animation.track_insert_key(track_idx, 0.0, Vector3(0, 0.5, 0))
    animation.track_insert_key(track_idx, 1.0, Vector3(0, 0.8, 0))
    animation.track_insert_key(track_idx, 2.0, Vector3(0, 0.5, 0))
    
    # Add animation to player and play
    anim_player.add_animation("float", animation)
    anim_player.play("float")
    
    # Track active emoticon
    active_emoticons.append({
        "node": emoticon,
        "text": emoticon_text,
        "parent": word_node,
        "creation_time": OS.get_unix_time()
    })

# Update yo-yo position and behavior
func _update_yo_yo(delta):
    match yo_yo_state:
        "extending":
            # Move yo-yo toward target
            var direction = (yo_yo_target_position - yo_yo_node.translation).normalized()
            yo_yo_node.translation += direction * yo_yo_extension_speed * delta
            
            # Update string
            _update_yo_yo_string()
            
            # Check if we're close enough to target
            var distance = yo_yo_node.translation.distance_to(yo_yo_target_position)
            if distance < 0.5:
                # Check for nearby words to catch
                _check_for_catchable_words()
                
                # Start retracting
                yo_yo_state = "retracting"
        
        "retracting":
            # Move yo-yo back to base
            var direction = (yo_yo_base_position - yo_yo_node.translation).normalized()
            yo_yo_node.translation += direction * yo_yo_extension_speed * delta
            
            # Update string
            _update_yo_yo_string()
            
            # Check if we're back at base
            var distance = yo_yo_node.translation.distance_to(yo_yo_base_position)
            if distance < 0.5:
                yo_yo_state = "idle"
                yo_yo_active = false
                yo_yo_node.visible = false

# Update yo-yo string visualization
func _update_yo_yo_string():
    yo_yo_string.clear()
    yo_yo_string.begin(Mesh.PRIMITIVE_LINE_STRIP)
    yo_yo_string.add_vertex(yo_yo_base_position)
    yo_yo_string.add_vertex(yo_yo_node.translation)
    yo_yo_string.end()

# Check for words near the yo-yo that can be caught
func _check_for_catchable_words():
    for word_data in data_sea_words:
        var word = word_data["word"]
        var properties = word_data["properties"]
        
        # Skip if already caught
        if caught_words.has(word):
            continue
        
        # Check if word node exists
        if not word in word_nodes:
            continue
        
        # Check distance to yo-yo
        var word_pos = word_nodes[word].translation
        var distance = word_pos.distance_to(yo_yo_node.translation)
        
        if distance <= yo_yo_catch_radius:
            # Catch the word!
            _catch_word(word)
            
            # Only catch one word at a time
            break

# Catch a word with the yo-yo
func _catch_word(word):
    print("Caught word: " + word)
    
    # Find word data
    var word_data = null
    for data in data_sea_words:
        if data["word"] == word:
            word_data = data
            break
    
    if word_data == null:
        return
    
    # Add to caught words list
    caught_words.append(word)
    
    # Visual effect for caught word
    _create_catch_effect(word)
    
    # Check if it's a debug trigger word
    if word_data["properties"]["is_debug_trigger"]:
        _trigger_debug_mode(word)
    
    # Check if it's a flawed word
    if word_data["properties"]["is_flawed"]:
        _highlight_flawed_word(word)
    
    # Add to memory system if available
    if memory_manager and memory_manager.has_method("add_memory"):
        memory_manager.add_memory("primary", word)
    
    # Update debug info
    if word in debug_word_info:
        debug_word_info[word]["catch_attempts"] += 1
    
    # Emit signal
    emit_signal("word_caught", word, word_data["properties"])

# Create visual effect when catching a word
func _create_catch_effect(word):
    if not word in word_nodes:
        return
    
    var word_node = word_nodes[word]
    
    # Create particles at word position
    var particles = CPUParticles.new()
    particles.translation = word_node.translation
    particles.amount = 20
    particles.lifetime = 1
    particles.explosiveness = 0.8
    particles.direction = Vector3(0, 1, 0)
    particles.spread = 180
    particles.gravity = Vector3(0, -9.8, 0)
    particles.initial_velocity = 2
    
    # Create material for particles
    var material = SpatialMaterial.new()
    material.albedo_color = Color(1, 0.8, 0.2)  # Gold
    material.flags_unshaded = true
    particles.material_override = material
    
    add_child(particles)
    
    # Auto-remove after effect completes
    yield(get_tree().create_timer(1.5), "timeout")
    particles.queue_free()
    
    # Fade out the caught word
    var tween = Tween.new()
    add_child(tween)
    
    # Get the label node
    var label = null
    for child in word_node.get_children():
        if child is Label3D:
            label = child
            break
    
    if label:
        tween.interpolate_property(label, "modulate:a", 
                                   label.modulate.a, 0.3, 
                                   0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
        tween.start()
    
    # Move the word toward memory system visualization if it exists
    var memory_viz = get_node_or_null("/root/Main/MemoryEvolutionDisplay")
    if memory_viz:
        var end_pos = word_node.translation + Vector3(0, 5, 0)  # Move up as if going to memory
        
        tween.interpolate_property(word_node, "translation",
                                  word_node.translation, end_pos,
                                  1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
        tween.start()

# Trigger debug mode for a debug word
func _trigger_debug_mode(word):
    debug_mode = true
    debug_overlay.visible = true
    
    # Find word data
    var word_data = null
    for data in data_sea_words:
        if data["word"] == word:
            word_data = data
            break
    
    if word_data == null:
        return
    
    # Create debug info panel specifically for this word
    var debug_panel = Panel.new()
    debug_panel.anchor_left = 0.7
    debug_panel.anchor_top = 0.3
    debug_panel.anchor_right = 0.98
    debug_panel.anchor_bottom = 0.7
    debug_overlay.add_child(debug_panel)
    
    # Add debug information
    var debug_info = Label.new()
    debug_info.anchor_right = 1.0
    debug_info.anchor_bottom = 1.0
    debug_info.margin_left = 10
    debug_info.margin_top = 10
    debug_info.margin_right = -10
    debug_info.margin_bottom = -10
    
    var info_text = "DEBUG INFO: " + word + "\n\n"
    info_text += "Creation Time: " + str(word_data["properties"]["creation_time"]) + "\n"
    info_text += "Evolution Stage: " + str(word_data["properties"]["evolution_stage"]) + "\n"
    info_text += "Is Flawed: " + str(word_data["properties"]["is_flawed"]) + "\n"
    
    if word_data["properties"]["is_flawed"] and word in debug_word_info:
        info_text += "Flawed Aspects: " + str(debug_word_info[word]["flawed_aspects"]) + "\n"
    
    info_text += "Position: " + str(word_data["properties"]["position"]) + "\n"
    
    debug_info.text = info_text
    debug_panel.add_child(debug_info)
    
    # Add close button
    var close_button = Button.new()
    close_button.text = "X"
    close_button.anchor_left = 1.0
    close_button.anchor_right = 1.0
    close_button.margin_left = -30
    close_button.margin_right = -5
    close_button.margin_top = 5
    close_button.margin_bottom = 25
    debug_panel.add_child(close_button)
    
    # Connect close button
    close_button.connect("pressed", self, "_on_debug_panel_close", [debug_panel])
    
    # Emit debug trigger signal
    emit_signal("debug_triggered", word, debug_word_info[word] if word in debug_word_info else {})

# Highlight a flawed word
func _highlight_flawed_word(word):
    if not word in word_nodes:
        return
    
    var word_node = word_nodes[word]
    
    # Find the label
    var label = null
    for child in word_node.get_children():
        if child is Label3D:
            label = child
            break
    
    if label:
        # Create pulsing animation
        var tween = Tween.new()
        word_node.add_child(tween)
        
        # Create glitch effect by randomly changing colors
        for i in range(10):
            var start_time = i * 0.2
            var rand_color = Color(1, 0, 0) if i % 2 == 0 else Color(1, 1, 0)
            
            tween.interpolate_property(label, "modulate", 
                                     label.modulate, rand_color, 
                                     0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,
                                     start_time)
            
            tween.interpolate_property(label, "outline_modulate", 
                                     Color(1, 0, 0), Color(1, 1, 0), 
                                     0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,
                                     start_time)
        
        # Return to normal color at the end
        tween.interpolate_property(label, "modulate", 
                                 rand_color, Color(1, 1, 1, 0.3), 
                                 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,
                                 2.0)
        
        tween.start()
        
        # Add "ERROR" emoticon
        _add_emoticon_to_word(word_node, "⚠️")

# Update emoticons
func _update_emoticons(delta):
    # Create new random emoticons
    if randf() < 0.01 and active_emoticons.size() < 20:  # 1% chance per frame, max 20 emoticons
        _create_random_emoticon()
    
    # Age out old emoticons
    var current_time = OS.get_unix_time()
    var emoticons_to_remove = []
    
    for i in range(active_emoticons.size()):
        var emoticon_data = active_emoticons[i]
        
        # Remove emoticons older than 30 seconds
        if current_time - emoticon_data["creation_time"] > 30:
            emoticons_to_remove.append(i)
    
    # Remove from end to start to avoid index issues
    for i in range(emoticons_to_remove.size() - 1, -1, -1):
        var idx = emoticons_to_remove[i]
        
        if idx < active_emoticons.size():
            var emoticon_data = active_emoticons[idx]
            
            # Remove node if it still exists
            if is_instance_valid(emoticon_data["node"]):
                emoticon_data["node"].queue_free()
            
            active_emoticons.remove(idx)

# Create a random floating emoticon
func _create_random_emoticon():
    var emoticon_text = emoticons[randi() % emoticons.size()]
    
    # Create position within sea volume
    var pos = Vector3(
        rand_range(-sea_size.x/2, sea_size.x/2),
        rand_range(1, sea_size.y),
        rand_range(-sea_size.z/2, sea_size.z/2)
    )
    
    # Create emoticon node
    var emoticon = Label3D.new()
    emoticon.text = emoticon_text
    emoticon.font_size = 48
    emoticon.translation = pos
    emoticon.billboard = SpatialMaterial.BILLBOARD_ENABLED
    add_child(emoticon)
    
    # Create fade in animation
    var tween = Tween.new()
    emoticon.add_child(tween)
    
    tween.interpolate_property(emoticon, "modulate:a", 
                             0, 1, 
                             0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
    tween.start()
    
    # Track active emoticon
    active_emoticons.append({
        "node": emoticon,
        "text": emoticon_text,
        "parent": null,
        "creation_time": OS.get_unix_time()
    })
    
    # Emit signal
    emit_signal("emoticon_activated", emoticon_text, pos, "random")

# Update synergy system
func _update_synergy(delta):
    # Only update periodically
    var current_time = OS.get_unix_time()
    if current_time - last_synergy_update < synergy_update_interval:
        return
    
    last_synergy_update = current_time
    
    # Clear old connections
    for connection in synergy_connections:
        if is_instance_valid(connection["node"]):
            connection["node"].queue_free()
    
    synergy_connections.clear()
    
    # Create new connections between related words
    var connected_words = []
    
    for i in range(data_sea_words.size()):
        var word_data1 = data_sea_words[i]
        var word1 = word_data1["word"]
        
        # Skip if caught or already connected
        if caught_words.has(word1) or connected_words.has(word1):
            continue
        
        # Find related word
        for j in range(i + 1, data_sea_words.size()):
            var word_data2 = data_sea_words[j]
            var word2 = word_data2["word"]
            
            # Skip if caught or already connected
            if caught_words.has(word2) or connected_words.has(word2):
                continue
            
            # Check if words are related
            if _are_words_related(word1, word2):
                # Create connection
                if word1 in word_nodes and word2 in word_nodes:
                    _create_synergy_connection(word1, word2)
                    connected_words.append(word1)
                    connected_words.append(word2)
                    break

# Check if two words are related
func _are_words_related(word1, word2):
    # Simple heuristic: check if they share first letter or are similar length
    if word1.empty() or word2.empty():
        return false
    
    if word1[0] == word2[0]:
        return true
    
    if abs(word1.length() - word2.length()) <= 1:
        return true
    
    # More complex relationship based on categories would go here
    
    return false

# Create a visual connection between related words
func _create_synergy_connection(word1, word2):
    var word_node1 = word_nodes[word1]
    var word_node2 = word_nodes[word2]
    
    # Create line between words
    var line = ImmediateGeometry.new()
    add_child(line)
    
    # Create material for line
    var material = SpatialMaterial.new()
    material.albedo_color = Color(0.5, 0.8, 1.0, 0.7)
    material.flags_transparent = true
    material.flags_unshaded = true
    line.material_override = material
    
    # Draw line
    line.clear()
    line.begin(Mesh.PRIMITIVE_LINE_STRIP)
    line.add_vertex(word_node1.translation)
    line.add_vertex(word_node2.translation)
    line.end()
    
    # Store connection
    synergy_connections.append({
        "word1": word1,
        "word2": word2,
        "node": line
    })
    
    # Update debug info
    if word1 in debug_word_info and word2 in debug_word_info:
        if not debug_word_info[word1]["synergy_connections"].has(word2):
            debug_word_info[word1]["synergy_connections"].append(word2)
        
        if not debug_word_info[word2]["synergy_connections"].has(word1):
            debug_word_info[word2]["synergy_connections"].append(word1)

# Create a flawed word
func _create_flawed_word():
    # Only create if we have few flawed words
    if flawed_words.size() >= 5:
        return
    
    # Choose from a list of specially crafted "flawed" words
    var flawed_word_options = ["glitch", "error", "corrupt", "fault", "broken", "missing", "undefined", "null"]
    var word = flawed_word_options[randi() % flawed_word_options.size()]
    
    # Create position within sea volume
    var pos = Vector3(
        rand_range(-sea_size.x/2, sea_size.x/2),
        rand_range(1, sea_size.y),
        rand_range(-sea_size.z/2, sea_size.z/2)
    )
    
    # Create flawed properties
    var properties = {
        "position": pos,
        "color": Color(1.0, 0.3, 0.3),  # Red
        "size": rand_range(1.2, 2.0),
        "evolution_stage": 0,
        "rotation_speed": 2.0,
        "movement_amplitude": 0.8,
        "movement_frequency": 3.0,
        "is_flawed": true,
        "creation_time": OS.get_unix_time(),
        "is_debug_trigger": true
    }
    
    # Store word data
    data_sea_words.append({"word": word, "properties": properties})
    flawed_words.append(word)
    
    # Create 3D representation
    _create_word_node(word, properties)
    
    # Create debug info
    _create_debug_info(word, properties)
    
    # Add error emoticon
    if word in word_nodes:
        _add_emoticon_to_word(word_nodes[word], "⚠️")

# Update all debug info
func _update_all_debug_info():
    # Update debug overlay
    if debug_overlay:
        # Remove old children except title
        var children_to_remove = []
        for i in range(1, debug_overlay.get_child_count()):
            children_to_remove.append(debug_overlay.get_child(i))
        
        for child in children_to_remove:
            child.queue_free()
        
        # Add statistics panel
        var stats_panel = Panel.new()
        stats_panel.anchor_left = 0.02
        stats_panel.anchor_top = 0.1
        stats_panel.anchor_right = 0.25
        stats_panel.anchor_bottom = 0.3
        debug_overlay.add_child(stats_panel)
        
        var stats_label = Label.new()
        stats_label.anchor_right = 1.0
        stats_label.anchor_bottom = 1.0
        stats_label.margin_left = 10
        stats_label.margin_top = 10
        stats_label.margin_right = -10
        stats_label.margin_bottom = -10
        
        stats_label.text = "DATA SEA STATISTICS\n\n"
        stats_label.text += "Total Words: " + str(data_sea_words.size()) + "\n"
        stats_label.text += "Caught Words: " + str(caught_words.size()) + "\n"
        stats_label.text += "Flawed Words: " + str(flawed_words.size()) + "\n"
        stats_label.text += "Active Emoticons: " + str(active_emoticons.size()) + "\n"
        stats_label.text += "Synergy Connections: " + str(synergy_connections.size()) + "\n"
        
        stats_panel.add_child(stats_label)
        
        # Add flawed words panel
        if flawed_words.size() > 0:
            var flawed_panel = Panel.new()
            flawed_panel.anchor_left = 0.02
            flawed_panel.anchor_top = 0.35
            flawed_panel.anchor_right = 0.25
            flawed_panel.anchor_bottom = 0.6
            debug_overlay.add_child(flawed_panel)
            
            var flawed_label = Label.new()
            flawed_label.anchor_right = 1.0
            flawed_label.anchor_bottom = 1.0
            flawed_label.margin_left = 10
            flawed_label.margin_top = 10
            flawed_label.margin_right = -10
            flawed_label.margin_bottom = -10
            
            flawed_label.text = "FLAWED WORDS\n\n"
            for word in flawed_words:
                flawed_label.text += "- " + word
                
                if word in debug_word_info and debug_word_info[word]["flawed_aspects"].size() > 0:
                    flawed_label.text += " (" + str(debug_word_info[word]["flawed_aspects"][0]) + ")"
                
                flawed_label.text += "\n"
            
            flawed_panel.add_child(flawed_label)

# Handle debug panel close
func _on_debug_panel_close(panel):
    panel.queue_free()

# Get status of the data sea
func get_sea_status():
    return {
        "total_words": data_sea_words.size(),
        "caught_words": caught_words.size(),
        "flawed_words": flawed_words.size(),
        "active_emoticons": active_emoticons.size(),
        "synergy_connections": synergy_connections.size(),
        "debug_mode": debug_mode,
        "yo_yo_active": yo_yo_active
    }