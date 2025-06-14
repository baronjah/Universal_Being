extends Node

# Signal for word animation events
signal word_manifested(word, properties)
signal word_evolved(word, old_properties, new_properties)
signal word_interaction(word1, word2, interaction_type)

# Core word properties dictionary
var active_words = {}

# Physical property mappings
var property_mappings = {
    "length": {
        "attribute": "scale",
        "min_value": Vector3(0.5, 0.5, 0.5),
        "max_value": Vector3(3.0, 3.0, 3.0)
    },
    "vowel_count": {
        "attribute": "color",
        "values": {
            0: Color(0.2, 0.2, 0.5),  # Low vowels: blue
            1: Color(0.2, 0.5, 0.5),  # Blue-green
            2: Color(0.2, 0.5, 0.2),  # Green
            3: Color(0.5, 0.5, 0.2),  # Yellow
            4: Color(0.5, 0.2, 0.2),  # Red
            5: Color(0.5, 0.2, 0.5)   # Many vowels: purple
        }
    },
    "consonant_pattern": {
        "attribute": "shape",
        "patterns": {
            "plosives": "cube",        # p, b, t, d, k, g
            "fricatives": "sphere",    # f, v, s, z, sh, th
            "nasals": "torus",         # m, n, ng
            "liquids": "cylinder",     # l, r
            "mixed": "icosphere"       # mixed consonant types
        }
    },
    "first_letter": {
        "attribute": "movement",
        "mappings": {
            # Alphabetic mapping to movement types
            "a": "float",
            "b": "bounce",
            "c": "circle",
            "d": "drift",
            "e": "expand",
            "f": "flicker",
            "g": "grow",
            "h": "hover",
            "i": "ignite",
            "j": "jump",
            "k": "knock",
            "l": "lift",
            "m": "morph",
            "n": "nod",
            "o": "orbit",
            "p": "pulse",
            "q": "quiver",
            "r": "rotate",
            "s": "spin",
            "t": "tilt",
            "u": "undulate",
            "v": "vibrate",
            "w": "wave",
            "x": "x-cross",
            "y": "yoyo",
            "z": "zigzag"
        }
    },
    "sentiment": {
        "attribute": "emission",
        "positive": Color(0.7, 0.9, 0.7),
        "neutral": Color(0.7, 0.7, 0.9),
        "negative": Color(0.9, 0.7, 0.7)
    }
}

# Animation patterns dictionary
var animation_patterns = {
    "float": {
        "type": "transform",
        "property": "translation:y",
        "curve": "sine",
        "amplitude": 0.5,
        "frequency": 1.0
    },
    "bounce": {
        "type": "physics",
        "property": "bounce",
        "height": 2.0,
        "damping": 0.8
    },
    "circle": {
        "type": "transform",
        "property": "rotation",
        "axis": Vector3(0, 1, 0),
        "speed": 1.0
    },
    "pulse": {
        "type": "transform",
        "property": "scale",
        "curve": "sine",
        "amplitude": 0.2,
        "frequency": 2.0
    },
    "rotate": {
        "type": "transform",
        "property": "rotation",
        "axis": Vector3(1, 1, 1),
        "speed": 0.5
    },
    "vibrate": {
        "type": "transform",
        "property": "translation",
        "curve": "noise",
        "amplitude": 0.1,
        "frequency": 5.0
    }
    # Add more animation patterns as needed
}

# Shape templates for manifestation
var shape_templates = {
    "cube": preload("res://shapes/cube.tscn"),
    "sphere": preload("res://shapes/sphere.tscn"),
    "torus": preload("res://shapes/torus.tscn"),
    "cylinder": preload("res://shapes/cylinder.tscn"),
    "icosphere": preload("res://shapes/icosphere.tscn")
}

# Main function to analyze and manifest a word
func manifest_word(word, position=Vector3.ZERO):
    # Clean up the word
    word = word.strip_edges().to_lower()
    
    if word.empty():
        return null
        
    # Calculate word properties
    var properties = analyze_word(word)
    
    # Create the visual manifestation
    var word_node = create_word_visual(word, properties, position)
    
    # Store the word in our active dictionary
    active_words[word] = {
        "properties": properties,
        "node": word_node,
        "creation_time": OS.get_unix_time(),
        "evolution_stage": 1,
        "interactions": []
    }
    
    # Emit the manifestation signal
    emit_signal("word_manifested", word, properties)
    
    return word_node

# Analyze a word to determine its properties
func analyze_word(word):
    var properties = {}
    
    # Basic properties
    properties["length"] = word.length()
    
    # Count vowels
    var vowels = "aeiouy"
    var vowel_count = 0
    for letter in word:
        if vowels.find(letter) >= 0:
            vowel_count += 1
    properties["vowel_count"] = vowel_count
    
    # Consonant pattern analysis
    var plosives = "pbtkdg"
    var fricatives = "fvszh"
    var nasals = "mn"
    var liquids = "lr"
    
    var consonant_counts = {
        "plosives": 0,
        "fricatives": 0,
        "nasals": 0,
        "liquids": 0
    }
    
    for letter in word:
        if plosives.find(letter) >= 0:
            consonant_counts["plosives"] += 1
        elif fricatives.find(letter) >= 0:
            consonant_counts["fricatives"] += 1
        elif nasals.find(letter) >= 0:
            consonant_counts["nasals"] += 1
        elif liquids.find(letter) >= 0:
            consonant_counts["liquids"] += 1
    
    # Determine dominant consonant type
    var max_count = 0
    var dominant_type = "mixed"
    
    for type in consonant_counts:
        if consonant_counts[type] > max_count:
            max_count = consonant_counts[type]
            dominant_type = type
    
    properties["consonant_pattern"] = dominant_type
    
    # First letter for movement pattern
    if word.length() > 0:
        properties["first_letter"] = word[0]
    else:
        properties["first_letter"] = "a"
    
    # Simple sentiment analysis based on specific letters
    var positive_letters = "aegilory"
    var negative_letters = "dkqvxz"
    
    var positive_count = 0
    var negative_count = 0
    
    for letter in word:
        if positive_letters.find(letter) >= 0:
            positive_count += 1
        elif negative_letters.find(letter) >= 0:
            negative_count += 1
    
    if positive_count > negative_count:
        properties["sentiment"] = "positive"
    elif negative_count > positive_count:
        properties["sentiment"] = "negative"
    else:
        properties["sentiment"] = "neutral"
    
    return properties

# Create visual representation of a word
func create_word_visual(word, properties, position):
    # Create a new Spatial node to hold the word visualization
    var word_node = Spatial.new()
    word_node.name = "Word_" + word
    word_node.translation = position
    
    # Determine the shape based on consonant pattern
    var shape_type = property_mappings["consonant_pattern"]["patterns"][properties["consonant_pattern"]]
    var shape_scene = shape_templates[shape_type]
    
    # Instance the shape
    var shape_instance = shape_scene.instance()
    word_node.add_child(shape_instance)
    
    # Apply scale based on word length
    var length_ratio = float(properties["length"]) / 10.0  # Normalize to 0-1 range for typical words
    length_ratio = clamp(length_ratio, 0.0, 1.0)
    
    var min_scale = property_mappings["length"]["min_value"]
    var max_scale = property_mappings["length"]["max_value"]
    
    var scale = min_scale.linear_interpolate(max_scale, length_ratio)
    shape_instance.scale = scale
    
    # Apply color based on vowel count
    var vowel_count = properties["vowel_count"]
    vowel_count = clamp(vowel_count, 0, 5)  # Limit to our mapping range
    
    var color = property_mappings["vowel_count"]["values"][vowel_count]
    set_shape_color(shape_instance, color)
    
    # Apply emission based on sentiment
    var emission_color = property_mappings["sentiment"][properties["sentiment"]]
    set_shape_emission(shape_instance, emission_color, 1.0)
    
    # Apply animation based on first letter
    var first_letter = properties["first_letter"]
    if property_mappings["first_letter"]["mappings"].has(first_letter):
        var animation_type = property_mappings["first_letter"]["mappings"][first_letter]
        apply_animation(word_node, animation_type)
    
    # Add label with the word
    var label = Label3D.new()
    label.text = word
    label.pixel_size = 0.03
    label.translation = Vector3(0, scale.y + 0.2, 0)
    word_node.add_child(label)
    
    # Add to scene
    add_child(word_node)
    
    return word_node

# Set the color of a shape
func set_shape_color(shape_instance, color):
    # This depends on the specific shader/material setup in your project
    # For standard materials:
    if shape_instance.get_child(0) is MeshInstance:
        var mesh_instance = shape_instance.get_child(0)
        
        # Check if material exists, create if needed
        if not mesh_instance.get_surface_material(0):
            var material = SpatialMaterial.new()
            mesh_instance.set_surface_material(0, material)
        
        # Set the color
        var material = mesh_instance.get_surface_material(0)
        if material is SpatialMaterial:
            material.albedo_color = color

# Set emission properties
func set_shape_emission(shape_instance, color, energy):
    if shape_instance.get_child(0) is MeshInstance:
        var mesh_instance = shape_instance.get_child(0)
        
        # Check if material exists
        if not mesh_instance.get_surface_material(0):
            var material = SpatialMaterial.new()
            mesh_instance.set_surface_material(0, material)
        
        # Set emission
        var material = mesh_instance.get_surface_material(0)
        if material is SpatialMaterial:
            material.emission_enabled = true
            material.emission = color
            material.emission_energy = energy

# Apply animation based on pattern
func apply_animation(word_node, animation_type):
    if not animation_patterns.has(animation_type):
        # Default to float animation if type not found
        animation_type = "float"
    
    var pattern = animation_patterns[animation_type]
    
    # Create appropriate animator based on animation type
    if pattern["type"] == "transform":
        add_transform_animation(word_node, pattern)
    elif pattern["type"] == "physics":
        add_physics_animation(word_node, pattern)
    
    # Store the animation type on the node for reference
    word_node.set_meta("animation_type", animation_type)

# Add transform-based animation
func add_transform_animation(word_node, pattern):
    var anim_player = AnimationPlayer.new()
    word_node.add_child(anim_player)
    
    var animation = Animation.new()
    animation.loop = true
    animation.length = 1.0 / pattern["frequency"] * 2.0 * PI
    
    # Create track based on property
    var track_idx = animation.add_track(Animation.TYPE_VALUE)
    
    if pattern["property"] == "rotation":
        # Rotation animation
        animation.track_set_path(track_idx, ".:rotation")
        
        # Add keyframes
        var frames = 12  # Number of keyframes
        for i in range(frames + 1):
            var ratio = float(i) / frames
            var time = ratio * animation.length
            var angle = ratio * 2.0 * PI * pattern["speed"]
            
            var rotation = Vector3.ZERO
            if pattern["axis"] == Vector3(1, 0, 0):
                rotation.x = angle
            elif pattern["axis"] == Vector3(0, 1, 0):
                rotation.y = angle
            elif pattern["axis"] == Vector3(0, 0, 1):
                rotation.z = angle
            else:
                rotation = pattern["axis"].normalized() * angle
            
            animation.track_insert_key(track_idx, time, rotation)
    
    elif pattern["property"].begins_with("translation"):
        # Parse which axis
        var axis = "xyz"
        var axis_idx = 0
        
        if pattern["property"] == "translation:x":
            axis_idx = 0
        elif pattern["property"] == "translation:y":
            axis_idx = 1
        elif pattern["property"] == "translation:z":
            axis_idx = 2
        
        # Get original position
        var start_pos = word_node.translation
        
        # Full translation animation
        if pattern["property"] == "translation":
            animation.track_set_path(track_idx, ".:translation")
            
            var frames = 24
            for i in range(frames + 1):
                var ratio = float(i) / frames
                var time = ratio * animation.length
                
                var noise_val = Vector3(
                    randf() * 2.0 - 1.0,
                    randf() * 2.0 - 1.0,
                    randf() * 2.0 - 1.0
                ) * pattern["amplitude"]
                
                animation.track_insert_key(track_idx, time, start_pos + noise_val)
        else:
            # Single axis animation
            animation.track_set_path(track_idx, ".:translation:" + axis[axis_idx])
            
            var frames = 24
            for i in range(frames + 1):
                var ratio = float(i) / frames
                var time = ratio * animation.length
                
                var offset = 0.0
                if pattern["curve"] == "sine":
                    offset = sin(ratio * 2.0 * PI) * pattern["amplitude"]
                
                animation.track_insert_key(track_idx, time, start_pos[axis_idx] + offset)
    
    elif pattern["property"] == "scale":
        animation.track_set_path(track_idx, ".:scale")
        
        # Get original scale
        var start_scale = word_node.scale
        
        var frames = 12
        for i in range(frames + 1):
            var ratio = float(i) / frames
            var time = ratio * animation.length
            
            var scale_factor = 1.0
            if pattern["curve"] == "sine":
                scale_factor = 1.0 + sin(ratio * 2.0 * PI) * pattern["amplitude"]
            
            animation.track_insert_key(track_idx, time, start_scale * scale_factor)
    
    # Add the animation to the player
    anim_player.add_animation("word_animation", animation)
    anim_player.play("word_animation")

# Add physics-based animation
func add_physics_animation(word_node, pattern):
    # This would connect to your physics system
    # For bounce, we'll just implement a simple one
    if pattern["property"] == "bounce":
        var timer = Timer.new()
        timer.wait_time = 2.0
        timer.autostart = true
        timer.connect("timeout", self, "_on_bounce_timer", [word_node, pattern])
        word_node.add_child(timer)
        
        # Store original position
        word_node.set_meta("original_y", word_node.translation.y)

# Handle bounce animation
func _on_bounce_timer(word_node, pattern):
    # Simple tween-based bounce
    var tween = Tween.new()
    word_node.add_child(tween)
    
    var start_pos = word_node.translation
    var original_y = word_node.get_meta("original_y")
    
    # Up movement
    var peak = Vector3(start_pos.x, original_y + pattern["height"], start_pos.z)
    tween.interpolate_property(word_node, "translation", start_pos, peak, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
    tween.start()
    
    yield(tween, "tween_completed")
    
    # Down movement with bounce
    var down_pos = Vector3(start_pos.x, original_y, start_pos.z)
    tween.interpolate_property(word_node, "translation", peak, down_pos, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN)
    tween.start()
    
    yield(tween, "tween_completed")
    tween.queue_free()

# Process word evolution over time
func _process(delta):
    evolve_words()
    process_interactions()

# Evolve words based on the turn system
func evolve_words():
    # Connect to turn tracker if available
    var turn_tracker = get_node_or_null("/root/Main/TurnTracker")
    if not turn_tracker:
        return
        
    # Only evolve on turn boundaries
    if turn_tracker.current_turn != 1:
        return
        
    # Find words that need evolution
    for word in active_words.keys():
        var word_data = active_words[word]
        
        # Evolve to next stage
        if word_data["evolution_stage"] < turn_tracker.current_phase:
            evolve_word(word, word_data["evolution_stage"] + 1)

# Evolve a specific word to a new stage
func evolve_word(word, new_stage):
    if not active_words.has(word):
        return
        
    var word_data = active_words[word]
    var old_properties = word_data["properties"].duplicate()
    
    # Store the original stage
    var old_stage = word_data["evolution_stage"]
    
    # Update evolution stage
    word_data["evolution_stage"] = new_stage
    
    # Apply evolution modifications based on stage
    match new_stage:
        2:  # Form stage - modify shape
            # Change shape based on evolution
            var current_shape = word_data["properties"]["consonant_pattern"]
            var shapes = property_mappings["consonant_pattern"]["patterns"].values()
            var current_idx = shapes.find(current_shape)
            var new_idx = (current_idx + 1) % shapes.size()
            word_data["properties"]["consonant_pattern"] = property_mappings["consonant_pattern"]["patterns"].keys()[new_idx]
            
        3:  # Complexity - modify color/scale
            # Intensify colors
            var current_vowels = word_data["properties"]["vowel_count"]
            word_data["properties"]["vowel_count"] = min(5, current_vowels + 1)
            
        4:  # Consciousness - modify animation
            # Change movement pattern
            var current_letter = word_data["properties"]["first_letter"]
            var alphabet = "abcdefghijklmnopqrstuvwxyz"
            var current_idx = alphabet.find(current_letter)
            var new_idx = (current_idx + 3) % alphabet.length()
            word_data["properties"]["first_letter"] = alphabet[new_idx]
            
        5:  # Awakening - add particles
            # Particle effects would be added here
            # For now, just change sentiment to positive
            word_data["properties"]["sentiment"] = "positive"
            
        # Additional evolution stages would go here...
        
    # Update the visual representation
    update_word_visual(word)
    
    # Emit evolution signal
    emit_signal("word_evolved", word, old_properties, word_data["properties"])

# Update the visual based on current properties
func update_word_visual(word):
    if not active_words.has(word):
        return
        
    var word_data = active_words[word]
    var properties = word_data["properties"]
    var word_node = word_data["node"]
    
    # Remove existing shape
    for child in word_node.get_children():
        if child is AnimationPlayer or child is Timer or child is Tween:
            continue  # Keep these nodes
        if child is Label3D:
            continue  # Keep the label
        child.queue_free()
    
    # Wait one frame for removal to complete
    yield(get_tree(), "idle_frame")
    
    # Create new shape
    var shape_type = property_mappings["consonant_pattern"]["patterns"][properties["consonant_pattern"]]
    var shape_scene = shape_templates[shape_type]
    
    # Instance the shape
    var shape_instance = shape_scene.instance()
    word_node.add_child(shape_instance)
    
    # Apply scale
    var length_ratio = float(properties["length"]) / 10.0
    length_ratio = clamp(length_ratio, 0.0, 1.0)
    
    var min_scale = property_mappings["length"]["min_value"]
    var max_scale = property_mappings["length"]["max_value"]
    
    var scale = min_scale.linear_interpolate(max_scale, length_ratio)
    shape_instance.scale = scale
    
    # Apply color
    var vowel_count = clamp(properties["vowel_count"], 0, 5)
    var color = property_mappings["vowel_count"]["values"][vowel_count]
    set_shape_color(shape_instance, color)
    
    # Apply emission
    var emission_color = property_mappings["sentiment"][properties["sentiment"]]
    set_shape_emission(shape_instance, emission_color, 1.0 + word_data["evolution_stage"] * 0.5)
    
    # Remove old animations
    for child in word_node.get_children():
        if child is AnimationPlayer or child is Timer:
            child.queue_free()
    
    # Wait one frame
    yield(get_tree(), "idle_frame")
    
    # Apply new animation
    var first_letter = properties["first_letter"]
    if property_mappings["first_letter"]["mappings"].has(first_letter):
        var animation_type = property_mappings["first_letter"]["mappings"][first_letter]
        apply_animation(word_node, animation_type)

# Process interactions between words
func process_interactions():
    # Simple proximity-based interactions
    var words = active_words.keys()
    
    for i in range(words.size()):
        for j in range(i + 1, words.size()):
            var word1 = words[i]
            var word2 = words[j]
            
            var node1 = active_words[word1]["node"]
            var node2 = active_words[word2]["node"]
            
            # Calculate distance
            var distance = node1.translation.distance_to(node2.translation)
            
            # Interaction threshold
            if distance < 3.0:
                # Record interaction if it's new
                var interaction_id = word1 + "_" + word2
                var interaction_found = false
                
                for interaction in active_words[word1]["interactions"]:
                    if interaction["with"] == word2:
                        interaction_found = true
                        break
                
                if not interaction_found:
                    # Create new interaction record
                    active_words[word1]["interactions"].append({
                        "with": word2,
                        "time": OS.get_unix_time(),
                        "type": determine_interaction_type(word1, word2)
                    })
                    
                    # Mirror in the other word
                    active_words[word2]["interactions"].append({
                        "with": word1,
                        "time": OS.get_unix_time(),
                        "type": determine_interaction_type(word1, word2)
                    })
                    
                    # Emit signal
                    emit_signal("word_interaction", word1, word2, determine_interaction_type(word1, word2))
                    
                    # Create visual connection
                    create_interaction_visual(node1, node2, determine_interaction_type(word1, word2))

# Determine type of interaction based on word properties
func determine_interaction_type(word1, word2):
    var properties1 = active_words[word1]["properties"]
    var properties2 = active_words[word2]["properties"]
    
    # Compare sentiments
    if properties1["sentiment"] == properties2["sentiment"]:
        return "harmony"
    elif properties1["sentiment"] == "positive" and properties2["sentiment"] == "negative":
        return "conflict"
    elif properties1["sentiment"] == "negative" and properties2["sentiment"] == "positive":
        return "conflict"
    else:
        return "neutral"

# Create visual representation of interaction
func create_interaction_visual(node1, node2, interaction_type):
    # Create a line between the two words
    var line = ImmediateGeometry.new()
    add_child(line)
    
    # Set material based on interaction type
    var material = SpatialMaterial.new()
    
    match interaction_type:
        "harmony":
            material.albedo_color = Color(0.2, 0.8, 0.2, 0.7)
        "conflict":
            material.albedo_color = Color(0.8, 0.2, 0.2, 0.7)
        "neutral":
            material.albedo_color = Color(0.6, 0.6, 0.6, 0.5)
    
    material.flags_transparent = true
    line.material_override = material
    
    # Create a simple animation to pulse the line
    var tween = Tween.new()
    line.add_child(tween)
    
    # Make line fade out after a few seconds
    tween.interpolate_property(material, "albedo_color:a", 
                             material.albedo_color.a, 0.0, 3.0, 
                             Tween.TRANS_SINE, Tween.EASE_OUT)
    tween.start()
    
    # Connect the tween completion to remove the line
    tween.connect("tween_completed", self, "_on_interaction_complete", [line])
    
    # Draw the line
    line.clear()
    line.begin(Mesh.PRIMITIVE_LINE_STRIP)
    line.add_vertex(node1.global_transform.origin)
    line.add_vertex(node2.global_transform.origin)
    line.end()

# Clean up the interaction line
func _on_interaction_complete(object, path, line):
    line.queue_free()

# Create a word at a random position
func manifest_random_word(word):
    var x = rand_range(-5, 5)
    var y = rand_range(0, 3)
    var z = rand_range(-5, 5)
    
    return manifest_word(word, Vector3(x, y, z))

# Main test function to spawn multiple words
func test_create_words(words):
    for word in words:
        manifest_random_word(word)