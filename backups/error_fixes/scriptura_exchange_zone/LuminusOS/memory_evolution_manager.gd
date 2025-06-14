extends Node

signal memory_evolved(memory_id, old_state, new_state)
signal memory_synchronized(memories)
signal yoyo_caught_word(word, memory_id)

# Memory storage system
var memories = {
    "primary": {
        "content": [],
        "last_update": 0,
        "evolution_stage": 1,
        "color": Color(0.5, 0.25, 0.75)  # Purple
    },
    "secondary": {
        "content": [],
        "last_update": 0,
        "evolution_stage": 1,
        "color": Color(0.25, 0.5, 0.75)  # Blue
    },
    "tertiary": {
        "content": [],
        "last_update": 0,
        "evolution_stage": 1,
        "color": Color(0.25, 0.75, 0.5)  # Teal
    }
}

# Word yoyo system
var yoyo = {
    "active": false,
    "extension_length": 5.0,
    "retraction_speed": 2.0,
    "catch_radius": 1.5,
    "target_word": null,
    "caught_words": [],
    "visual_node": null
}

# References to other systems
var word_animator
var turn_tracker
var word_translator

# Task automation system
var automated_tasks = [
    {
        "name": "Memory Synchronization",
        "frequency": 60,  # seconds
        "last_execution": 0,
        "handler": "synchronize_memories",
        "enabled": true
    },
    {
        "name": "Word Evolution",
        "frequency": 120,  # seconds
        "last_execution": 0,
        "handler": "evolve_random_words",
        "enabled": true
    },
    {
        "name": "Yoyo Word Catching",
        "frequency": 45,  # seconds
        "last_execution": 0,
        "handler": "launch_yoyo_catcher",
        "enabled": true
    }
]

func _ready():
    # Get references to other systems
    word_animator = get_node_or_null("/root/Main/WordAnimator")
    turn_tracker = get_node_or_null("/root/Main/TurnTracker")
    word_translator = get_node_or_null("/root/Main/WordTranslator")
    
    # Create yoyo visual if word animator exists
    if word_animator:
        _create_yoyo_visual()
    
    # Start task timer
    set_process(true)

func _process(delta):
    # Process automated tasks
    _process_automated_tasks(delta)
    
    # Update yoyo if active
    if yoyo["active"] and yoyo["visual_node"]:
        _update_yoyo(delta)

# Process all automated tasks
func _process_automated_tasks(delta):
    var current_time = OS.get_unix_time()
    
    for task in automated_tasks:
        if not task["enabled"]:
            continue
            
        if current_time - task["last_execution"] >= task["frequency"]:
            # Execute task
            if has_method(task["handler"]):
                call(task["handler"])
                
            # Update execution time
            task["last_execution"] = current_time

# Add a memory to a specific store
func add_memory(memory_id, content):
    if not memories.has(memory_id):
        return false
    
    # Add the content to the specified memory
    memories[memory_id]["content"].append({
        "data": content,
        "timestamp": OS.get_unix_time(),
        "evolution_stage": memories[memory_id]["evolution_stage"],
        "source": "manual"
    })
    
    # Update last update time
    memories[memory_id]["last_update"] = OS.get_unix_time()
    
    return true

# Synchronize all memories to maintain consistency
func synchronize_memories():
    print("Synchronizing memories...")
    
    # Find unique content across memories
    var all_content = {}
    
    for memory_id in memories:
        var memory = memories[memory_id]
        
        for item in memory["content"]:
            var content_hash = str(item["data"]).hash()
            
            if not all_content.has(content_hash):
                all_content[content_hash] = {
                    "data": item["data"],
                    "source_memory": memory_id,
                    "timestamp": item["timestamp"],
                    "evolution_stage": item["evolution_stage"]
                }
    
    # Ensure all memories have all content
    for memory_id in memories:
        for content_hash in all_content:
            var content_data = all_content[content_hash]
            
            # Check if this memory already has this content
            var has_content = false
            for item in memories[memory_id]["content"]:
                if str(item["data"]).hash() == content_hash:
                    has_content = true
                    break
            
            # If not, add it
            if not has_content:
                memories[memory_id]["content"].append({
                    "data": content_data["data"],
                    "timestamp": OS.get_unix_time(),
                    "evolution_stage": memories[memory_id]["evolution_stage"],
                    "source": "sync_from_" + content_data["source_memory"]
                })
                
                # Update last update time
                memories[memory_id]["last_update"] = OS.get_unix_time()
    
    # Emit synchronized signal
    emit_signal("memory_synchronized", memories)
    
    return true

# Evolve a specific memory
func evolve_memory(memory_id):
    if not memories.has(memory_id):
        return false
    
    var memory = memories[memory_id]
    var old_stage = memory["evolution_stage"]
    
    # Increment evolution stage
    memory["evolution_stage"] += 1
    
    # Apply evolution effects
    match memory["evolution_stage"]:
        2:  # Secondary evolution
            memory["color"] = Color(0.6, 0.3, 0.8)  # Deeper purple
        3:  # Tertiary evolution
            memory["color"] = Color(0.7, 0.4, 0.9)  # Rich purple
        4:  # Quaternary evolution
            memory["color"] = Color(0.8, 0.5, 1.0)  # Vivid purple
        5:  # Final evolution
            memory["color"] = Color(1.0, 0.7, 1.0)  # Luminous purple
    
    # Evolve all content in this memory
    for item in memory["content"]:
        item["evolution_stage"] = memory["evolution_stage"]
    
    # Update last update time
    memory["last_update"] = OS.get_unix_time()
    
    # Emit evolution signal
    emit_signal("memory_evolved", memory_id, old_stage, memory["evolution_stage"])
    
    return true

# Evolve random words from memories
func evolve_random_words():
    if not word_animator:
        return
    
    print("Evolving random words...")
    
    # Collect all words from memories
    var all_words = []
    
    for memory_id in memories:
        var memory = memories[memory_id]
        
        for item in memory["content"]:
            if typeof(item["data"]) == TYPE_STRING:
                all_words.append(item["data"])
    
    # Manifest a few random words with evolved properties
    var words_to_evolve = min(all_words.size(), 3)
    
    for i in range(words_to_evolve):
        if all_words.empty():
            break
            
        var random_index = randi() % all_words.size()
        var word = all_words[random_index]
        all_words.remove(random_index)
        
        # Create evolved word
        var position = Vector3(
            rand_range(-5, 5),
            rand_range(1, 3),
            rand_range(-5, 5)
        )
        
        var word_node = word_animator.manifest_word(word, position)
        
        # Manually evolve the word to a random stage
        var evolution_stage = randi() % 5 + 1
        for stage in range(1, evolution_stage):
            word_animator.evolve_word(word, stage + 1)
            yield(get_tree(), "idle_frame")  # Wait a frame between evolutions

# Create the yoyo visual
func _create_yoyo_visual():
    # Create a new Spatial node
    var yoyo_node = Spatial.new()
    yoyo_node.name = "WordYoyo"
    
    # Create the yoyo model (simple sphere)
    var mesh_instance = MeshInstance.new()
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.3
    sphere_mesh.height = 0.6
    mesh_instance.mesh = sphere_mesh
    
    # Create material
    var material = SpatialMaterial.new()
    material.albedo_color = Color(0.9, 0.7, 0.2)  # Gold
    material.emission_enabled = true
    material.emission = Color(0.9, 0.7, 0.2)
    material.emission_energy = 0.5
    mesh_instance.material_override = material
    
    # Add to the yoyo node
    yoyo_node.add_child(mesh_instance)
    
    # Create the string (simple line)
    var immediate_geo = ImmediateGeometry.new()
    immediate_geo.name = "YoyoString"
    
    # Create material for the string
    var string_material = SpatialMaterial.new()
    string_material.albedo_color = Color(0.9, 0.9, 0.9)
    string_material.flags_unshaded = true
    immediate_geo.material_override = string_material
    
    # Add to the yoyo node
    yoyo_node.add_child(immediate_geo)
    
    # Store the node
    yoyo["visual_node"] = yoyo_node
    
    # Add to the scene
    add_child(yoyo_node)
    
    # Hide initially
    yoyo_node.visible = false

# Launch the yoyo to catch words
func launch_yoyo_catcher():
    if not word_animator or not yoyo["visual_node"]:
        return
    
    print("Launching yoyo word catcher...")
    
    # Ensure the yoyo isn't already active
    if yoyo["active"]:
        return
    
    # Get all active words from the animator
    var active_words = word_animator.active_words
    
    if active_words.empty():
        return
    
    # Choose a random word to target
    var words = active_words.keys()
    var target_word = words[randi() % words.size()]
    var target_node = active_words[target_word]["node"]
    
    # Set yoyo properties
    yoyo["active"] = true
    yoyo["target_word"] = target_word
    
    # Position the yoyo at the origin
    yoyo["visual_node"].translation = Vector3(0, 3, 0)
    yoyo["visual_node"].visible = true
    
    # Create an animation to extend the yoyo toward the target
    var tween = Tween.new()
    yoyo["visual_node"].add_child(tween)
    
    # Extend the yoyo toward the word
    tween.interpolate_property(
        yoyo["visual_node"],
        "translation",
        yoyo["visual_node"].translation,
        target_node.translation,
        yoyo["extension_length"] / yoyo["retraction_speed"],
        Tween.TRANS_EXPO,
        Tween.EASE_OUT
    )
    
    tween.start()
    
    # Wait for the extension to complete, then check for catch
    yield(tween, "tween_completed")
    
    # Check if we caught the word
    var distance = yoyo["visual_node"].translation.distance_to(target_node.translation)
    
    if distance <= yoyo["catch_radius"]:
        # Caught the word!
        _catch_word(target_word)
    
    # Retract the yoyo
    tween.interpolate_property(
        yoyo["visual_node"],
        "translation",
        yoyo["visual_node"].translation,
        Vector3(0, 3, 0),
        yoyo["visual_node"].translation.distance_to(Vector3(0, 3, 0)) / yoyo["retraction_speed"],
        Tween.TRANS_EXPO,
        Tween.EASE_IN
    )
    
    tween.start()
    
    # Wait for retraction to complete
    yield(tween, "tween_completed")
    
    # Clean up
    yoyo["active"] = false
    yoyo["target_word"] = null
    yoyo["visual_node"].visible = false
    tween.queue_free()

# Update the yoyo string
func _update_yoyo(delta):
    # Draw the string from origin to yoyo
    var string = yoyo["visual_node"].get_node("YoyoString")
    
    string.clear()
    string.begin(Mesh.PRIMITIVE_LINE_STRIP)
    string.add_vertex(Vector3(0, 3, 0))
    string.add_vertex(yoyo["visual_node"].translation)
    string.end()

# Handle catching a word with the yoyo
func _catch_word(word):
    if not word_animator.active_words.has(word):
        return
    
    print("Caught word with yoyo: " + word)
    
    # Add to caught words list
    yoyo["caught_words"].append(word)
    
    # Add to all memories
    for memory_id in memories:
        add_memory(memory_id, word)
    
    # Visual effect for the caught word
    var word_node = word_animator.active_words[word]["node"]
    
    # Create a brief glow effect
    var tween = Tween.new()
    word_node.add_child(tween)
    
    # Get child mesh instance
    var mesh_instance = null
    for child in word_node.get_children():
        if child is MeshInstance:
            mesh_instance = child
            break
    
    if mesh_instance and mesh_instance.get_surface_material(0):
        var material = mesh_instance.get_surface_material(0)
        
        # Store original emission energy
        var original_energy = 0
        if material is SpatialMaterial and material.emission_enabled:
            original_energy = material.emission_energy
        
        # Increase emission energy
        if material is SpatialMaterial:
            material.emission_enabled = true
            material.emission_energy = 3.0
        
        # Return to original after a delay
        yield(get_tree().create_timer(0.5), "timeout")
        
        if is_instance_valid(material) and material is SpatialMaterial:
            material.emission_energy = original_energy
    
    # Emit signal
    emit_signal("yoyo_caught_word", word, "primary")  # Primary memory as default
    
    # Determine which memory received the strongest connection
    var strongest_memory = "primary"
    var strongest_connection = 0
    
    # This would analyze the word to determine its affinity with different memories
    # For now, use a simple random selection
    for memory_id in memories:
        var connection_strength = randf()
        if connection_strength > strongest_connection:
            strongest_connection = connection_strength
            strongest_memory = memory_id
    
    # Emit signal with the strongest memory
    emit_signal("yoyo_caught_word", word, strongest_memory)

# Enable or disable a specific task
func set_task_enabled(task_name, enabled):
    for task in automated_tasks:
        if task["name"] == task_name:
            task["enabled"] = enabled
            return true
    
    return false

# Get status of all tasks
func get_task_status():
    var status = []
    
    for task in automated_tasks:
        status.append({
            "name": task["name"],
            "enabled": task["enabled"],
            "frequency": task["frequency"],
            "last_execution": task["last_execution"],
            "next_execution": task["last_execution"] + task["frequency"]
        })
    
    return status