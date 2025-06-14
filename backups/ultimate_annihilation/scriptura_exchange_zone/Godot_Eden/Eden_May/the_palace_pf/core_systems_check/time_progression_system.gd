extends Node

class_name TimeProgressionSystem

# ----- TIME SETTINGS -----
@export_category("Time Settings")
@export var time_enabled: bool = true
@export var base_time_scale: float = 1.0
@export var movement_time_acceleration: float = 0.5  # Time acceleration per unit of movement
@export var max_time_acceleration: float = 5.0
@export var time_deceleration_rate: float = 0.8  # How quickly time slows when not moving
@export var dream_time_scale: float = 2.5  # Time flows faster in dreams

# ----- STORY PROGRESSION SETTINGS -----
@export_category("Story Progression")
@export var story_evolution_threshold: float = 5.0  # Time units needed for story evolution
@export var memory_creation_threshold: float = 2.0  # Time units needed for memory creation
@export var telepathy_connection_chance: float = 0.2  # Chance to create telepathic connections
@export var dream_connection_strength: float = 2.0  # How strongly dreams connect to memories

# ----- ANIMATION SETTINGS -----
@export_category("Animation Settings")
@export var min_time_for_animation: float = 0.5  # Minimum time passed for animation
@export var animation_speed_factor: float = 1.2  # How animation speed scales with time
@export var animation_blend_time: float = 0.3  # Transition time between animations

# ----- COMPONENT REFERENCES -----
var game_controller: Node
var word_seed_evolution: Node
var zone_scale_system: Node
var player_controller: Node

# ----- TIME STATE -----
var current_time: float = 0.0
var previous_time: float = 0.0
var time_acceleration: float = 0.0
var time_since_last_story_evolution: float = 0.0
var time_since_last_memory_creation: float = 0.0
var is_in_dream_state: bool = false
var current_dream_id: String = ""
var dream_time_accumulator: float = 0.0
var dream_connection_targets: Array = []

# ----- MEMORY & TELEPATHY SYSTEM -----
var memory_fragments: Dictionary = {}  # time -> memory data
var telepathic_connections: Array = []  # Connection between memories and dreams
var dream_fragments: Dictionary = {}  # dream_id -> dream data

# ----- STORY EVOLUTION TRACKING -----
var story_segments: Array = []
var current_story_arc: String = "beginning"  # beginning, rising_action, climax, falling_action, resolution
var story_intensity: float = 0.0  # 0.0 to 1.0
var story_evolution_points: Array = []  # Points where story evolved

# ----- SIGNALS -----
signal time_advanced(amount, total)
signal story_evolved(old_segment, new_segment)
signal memory_created(memory_id, data)
signal dream_entered(dream_id)
signal dream_exited(dream_id)
signal telepathic_connection_formed(from_id, to_id, strength)

# ----- INITIALIZATION -----
func _ready():
    # Start initial time
    current_time = 0.0
    previous_time = 0.0
    
    # Initialize story evolution tracking
    initialize_story_tracking()
    
    # Connect signals
    if player_controller:
        player_controller.connect("player_moved", _on_player_moved)

# ----- TIME PROGRESSION -----
func _process(delta):
    if not time_enabled:
        return
    
    # Store previous time
    previous_time = current_time
    
    # Calculate base time advancement
    var time_advance = delta * base_time_scale
    
    # Apply time acceleration from movement
    time_advance += delta * time_acceleration
    
    # Apply dream state time scaling
    if is_in_dream_state:
        time_advance *= dream_time_scale
    
    # Advance time
    current_time += time_advance
    
    # Track time for story evolution
    time_since_last_story_evolution += time_advance
    time_since_last_memory_creation += time_advance
    
    # Accumulate dream time if in dream state
    if is_in_dream_state:
        dream_time_accumulator += time_advance
    
    # Check for story evolution
    if time_since_last_story_evolution >= story_evolution_threshold:
        evolve_story()
    
    # Check for memory creation
    if time_since_last_memory_creation >= memory_creation_threshold:
        create_memory()
    
    # Gradually decelerate time if not actively moving
    time_acceleration = max(0.0, time_acceleration * time_deceleration_rate)
    
    # Emit time advanced signal
    emit_signal("time_advanced", time_advance, current_time)
    
    # Update dream connections if in dream state
    if is_in_dream_state:
        update_dream_connections()

func accelerate_time(amount: float):
    # Accelerate time based on player movement or other factors
    time_acceleration = min(max_time_acceleration, time_acceleration + amount)

func _on_player_moved(distance: float, velocity: Vector3):
    # Accelerate time based on player movement
    var acceleration_amount = distance * movement_time_acceleration
    accelerate_time(acceleration_amount)
    
    # Check for animation triggering
    trigger_movement_animations(velocity)

# ----- STORY EVOLUTION -----
func initialize_story_tracking():
    # Setup initial story segments
    story_segments = [
        "awakening",          # Initial state
        "exploration",        # Discovering the world
        "connection",         # Forming connections between words
        "transformation",     # Words evolving
        "conflict",           # Tensions between different concepts
        "resolution",         # Resolving conflicts
        "transcendence",      # Moving beyond initial limitations
        "rebirth"             # Cycle begins anew
    ]
    
    # Initialize with first segment
    current_story_arc = "beginning"
    
    # Add initial evolution point
    story_evolution_points.append({
        "time": current_time,
        "segment": story_segments[0],
        "arc": current_story_arc,
        "intensity": 0.0
    })

func evolve_story():
    # Reset timer
    time_since_last_story_evolution = 0.0
    
    # Get current segment index
    var current_segment_index = story_segments.find(story_evolution_points[-1].segment)
    
    # Determine next segment
    var next_segment_index = (current_segment_index + 1) % story_segments.size()
    var next_segment = story_segments[next_segment_index]
    
    # Update story arc based on segment
    if next_segment_index <= 1:
        current_story_arc = "beginning"
        story_intensity = float(next_segment_index) / 2.0
    elif next_segment_index <= 3:
        current_story_arc = "rising_action"
        story_intensity = 0.3 + float(next_segment_index - 2) / 2.0 * 0.3
    elif next_segment_index == 4:
        current_story_arc = "climax"
        story_intensity = 1.0
    elif next_segment_index <= 6:
        current_story_arc = "falling_action"
        story_intensity = 0.6 - float(next_segment_index - 5) / 2.0 * 0.3
    else:
        current_story_arc = "resolution"
        story_intensity = 0.3
    
    # Record evolution point
    story_evolution_points.append({
        "time": current_time,
        "segment": next_segment,
        "arc": current_story_arc,
        "intensity": story_intensity
    })
    
    # Emit signal
    emit_signal("story_evolved", story_segments[current_segment_index], next_segment)
    
    # Apply story evolution effects
    apply_story_evolution_effects(next_segment, current_story_arc, story_intensity)

func apply_story_evolution_effects(segment, arc, intensity):
    if not game_controller:
        return
    
    # Apply different effects based on story segment
    match segment:
        "awakening":
            # Create initial words
            if word_seed_evolution:
                var core_words = ["awakening", "consciousness", "beginning", "awareness", "perception"]
                create_word_cluster(core_words, Vector3(0, 2, 0), 3.0)
        
        "exploration":
            # Create exploration-themed words
            if word_seed_evolution:
                var exploration_words = ["discover", "journey", "explore", "search", "path", "find"]
                create_word_cluster(exploration_words, Vector3(5, 0, 5), 4.0)
                
            # Change reality to encourage exploration
            if game_controller.has_method("set_reality"):
                game_controller.set_reality("digital")
        
        "connection":
            # Increase connection visibility
            if word_seed_evolution:
                connect_nearby_words(5.0, 10)
            
            # Create connection-themed words
            var connection_words = ["connect", "bridge", "link", "bond", "relationship", "network"]
            create_word_cluster(connection_words, Vector3(-5, 2, 5), 4.0)
        
        "transformation":
            # Evolve existing words
            if word_seed_evolution and word_seed_evolution.active_seeds:
                var words_to_evolve = min(5, word_seed_evolution.active_seeds.size())
                for i in range(words_to_evolve):
                    var word_id = word_seed_evolution.active_seeds.keys()[randi() % word_seed_evolution.active_seeds.size()]
                    if word_seed_evolution.has_method("_evolve_seed"):
                        word_seed_evolution._evolve_seed(word_id)
            
            # Change reality to support transformation
            if game_controller.has_method("set_reality"):
                game_controller.set_reality("astral")
        
        "conflict":
            # Create conflict-themed words
            var conflict_words = ["conflict", "tension", "opposition", "clash", "struggle", "challenge"]
            create_word_cluster(conflict_words, Vector3(0, -2, 8), 4.0)
            
            # Create opposing force
            if zone_scale_system:
                create_opposing_forces()
        
        "resolution":
            # Create resolution-themed words
            var resolution_words = ["harmony", "balance", "peace", "solution", "unity", "accord"]
            create_word_cluster(resolution_words, Vector3(8, 2, -5), 4.0)
            
            # Connect opposing forces
            if word_seed_evolution:
                connect_opposing_words()
        
        "transcendence":
            # Create transcendence-themed words
            var transcendence_words = ["transcend", "ascend", "elevate", "surpass", "beyond", "higher"]
            create_word_cluster(transcendence_words, Vector3(-8, 4, -5), 4.0)
            
            # Shift to highest scale
            if zone_scale_system and zone_scale_system.has_method("get_scale_levels"):
                var scales = zone_scale_system.get_scale_levels()
                if scales.size() > 0:
                    enter_scale_zone(scales[-1])  # Highest scale
        
        "rebirth":
            # Create rebirth-themed words
            var rebirth_words = ["rebirth", "renewal", "restart", "cycle", "genesis", "recreation"]
            create_word_cluster(rebirth_words, Vector3(0, 0, -8), 4.0)
            
            # Reset to physical reality
            if game_controller.has_method("set_reality"):
                game_controller.set_reality("physical")
    
    # Apply intensity-based effects
    if zone_scale_system:
        # Adjust zone properties based on story intensity
        adjust_zones_by_intensity(intensity)

func create_word_cluster(words, center_position, radius):
    if not word_seed_evolution or not word_seed_evolution.has_method("plant_seed"):
        return
    
    for i in range(words.size()):
        var angle = (2 * PI / words.size()) * i
        var offset = Vector3(cos(angle) * radius, sin(angle) * radius * 0.5, sin(angle) * radius)
        var position = center_position + offset
        
        word_seed_evolution.plant_seed(words[i], position)

func connect_nearby_words(max_distance, max_connections):
    if not word_seed_evolution or not word_seed_evolution.active_seeds:
        return
    
    var connections_made = 0
    var active_seeds = word_seed_evolution.active_seeds
    
    # Get all words
    var word_ids = active_seeds.keys()
    
    # Randomize connection order
    word_ids.shuffle()
    
    # Connect words that are close together
    for word_id in word_ids:
        if connections_made >= max_connections:
            break
        
        var word_pos = active_seeds[word_id].position
        
        for other_id in word_ids:
            if word_id == other_id:
                continue
                
            if connections_made >= max_connections:
                break
            
            var other_pos = active_seeds[other_id].position
            
            if word_pos.distance_to(other_pos) <= max_distance:
                if word_seed_evolution.has_method("connect_words"):
                    if word_seed_evolution.connect_words(word_id, other_id):
                        connections_made += 1

func create_opposing_forces():
    if not zone_scale_system:
        return
    
    # Create two opposing zones
    var order_zone_id = zone_scale_system.create_custom_zone(
        Vector3(10, 0, 0),
        5.0,
        "human",
        "STABLE",
        {"force": "order", "polarity": 1}
    )
    
    var chaos_zone_id = zone_scale_system.create_custom_zone(
        Vector3(-10, 0, 0),
        5.0,
        "human",
        "CHAOTIC",
        {"force": "chaos", "polarity": -1}
    )
    
    # Create words in each zone
    if word_seed_evolution:
        var order_words = ["order", "structure", "system", "pattern", "discipline"]
        var chaos_words = ["chaos", "disorder", "freedom", "chance", "spontaneity"]
        
        for word in order_words:
            var pos = zone_scale_system.active_zones[order_zone_id].position + Vector3(randf_range(-3, 3), randf_range(-1, 3), randf_range(-3, 3))
            word_seed_evolution.plant_seed(word, pos)
        
        for word in chaos_words:
            var pos = zone_scale_system.active_zones[chaos_zone_id].position + Vector3(randf_range(-3, 3), randf_range(-1, 3), randf_range(-3, 3))
            word_seed_evolution.plant_seed(word, pos)

func connect_opposing_words():
    if not word_seed_evolution or not word_seed_evolution.active_seeds:
        return
    
    var order_words = []
    var chaos_words = []
    
    # Find words related to order and chaos
    for word_id in word_seed_evolution.active_seeds:
        var word_text = word_seed_evolution.active_seeds[word_id].text.to_lower()
        
        if word_text in ["order", "structure", "system", "pattern", "discipline"]:
            order_words.append(word_id)
        
        if word_text in ["chaos", "disorder", "freedom", "chance", "spontaneity"]:
            chaos_words.append(word_id)
    
    # Create connections between opposing concepts
    for order_id in order_words:
        for chaos_id in chaos_words:
            if word_seed_evolution.has_method("connect_words"):
                word_seed_evolution.connect_words(order_id, chaos_id)

func enter_scale_zone(scale_level):
    if not zone_scale_system or not player_controller:
        return
    
    # Find zone of the desired scale
    var target_zone_id = ""
    
    for zone_id in zone_scale_system.active_zones:
        if zone_scale_system.active_zones[zone_id].scale_level == scale_level:
            target_zone_id = zone_id
            break
    
    # If no zone found, create one
    if target_zone_id == "":
        target_zone_id = zone_scale_system.create_custom_zone(
            Vector3(0, 10, 0),
            15.0,
            scale_level,
            "STABLE"
        )
    
    # Teleport player to zone
    var target_position = zone_scale_system.active_zones[target_zone_id].position
    player_controller.teleport_to(target_position)

func adjust_zones_by_intensity(intensity):
    if not zone_scale_system:
        return
    
    # Adjust all zones based on story intensity
    for zone_id in zone_scale_system.active_zones:
        var zone_data = zone_scale_system.active_zones[zone_id]
        
        # Higher intensity means more evolution and manifestation
        zone_data.evolution_factor = lerp(1.0, 2.0, intensity)
        zone_data.manifestation_factor = lerp(1.0, 2.0, intensity)
        
        # Climax means higher destruction
        if current_story_arc == "climax":
            zone_data.destruction_factor = 2.0
        else:
            zone_data.destruction_factor = 0.5
        
        # Time flows differently at different story points
        if current_story_arc == "beginning":
            zone_data.time_dilation = 0.7  # Slower start
        elif current_story_arc == "rising_action":
            zone_data.time_dilation = 1.0 + intensity * 0.5  # Gradually faster
        elif current_story_arc == "climax":
            zone_data.time_dilation = 2.0  # Fast at climax
        elif current_story_arc == "falling_action":
            zone_data.time_dilation = 1.5 - intensity * 0.5  # Gradually slower
        else:
            zone_data.time_dilation = 0.8  # Slower resolution

# ----- MEMORY SYSTEM -----
func create_memory():
    # Reset timer
    time_since_last_memory_creation = 0.0
    
    # Generate a unique memory ID
    var memory_id = "memory_" + str(memory_fragments.size())
    
    # Determine memory content
    var memory_content = generate_memory_content()
    
    # Create memory data
    var memory_data = {
        "id": memory_id,
        "time": current_time,
        "content": memory_content,
        "intensity": randf(),
        "connections": [],
        "dream_linked": false
    }
    
    # Store memory
    memory_fragments[memory_id] = memory_data
    
    # Emit signal
    emit_signal("memory_created", memory_id, memory_data)
    
    # Check for telepathic connections
    if randf() < telepathy_connection_chance:
        create_telepathic_connection(memory_id)
    
    return memory_id

func generate_memory_content():
    var memory_content = ""
    
    if game_controller and game_controller.current_scene:
        # Use current game scene as memory content
        var scene = game_controller.current_scene
        
        # Get words in scene
        var words_text = []
        for word_data in scene.words:
            words_text.append(word_data.text)
        
        if words_text.size() > 0:
            memory_content = "Words: " + ", ".join(words_text)
        
        # Add current time zone
        if scene.zones and scene.zones.size() > 0:
            for zone_data in scene.zones:
                if zone_data.has("time_zone"):
                    memory_content += " in " + zone_data.time_zone.capitalize() + " time zone"
                    break
        
        # Add current reality
        if scene.has("reality"):
            memory_content += " in " + scene.reality.capitalize() + " reality"
    
    # If we couldn't generate content, create placeholder
    if memory_content == "":
        memory_content = "Memory fragment at time " + str(snapped(current_time, 0.1))
    
    return memory_content

func create_telepathic_connection(memory_id):
    if memory_fragments.size() < 2:
        return
    
    # Find a memory to connect to (not self)
    var target_memory_id = memory_id
    while target_memory_id == memory_id:
        var memory_ids = memory_fragments.keys()
        target_memory_id = memory_ids[randi() % memory_ids.size()]
    
    # Create connection data
    var connection = {
        "from_id": memory_id,
        "to_id": target_memory_id,
        "strength": randf(),
        "type": "telepathy",
        "creation_time": current_time
    }
    
    # Add to connections lists
    telepathic_connections.append(connection)
    memory_fragments[memory_id].connections.append(target_memory_id)
    memory_fragments[target_memory_id].connections.append(memory_id)
    
    # Emit signal
    emit_signal("telepathic_connection_formed", memory_id, target_memory_id, connection.strength)
    
    return connection

# ----- DREAM SYSTEM -----
func enter_dream_state():
    if is_in_dream_state:
        return
    
    is_in_dream_state = true
    dream_time_accumulator = 0.0
    
    # Generate a unique dream ID
    current_dream_id = "dream_" + str(dream_fragments.size())
    
    # Create dream data
    dream_fragments[current_dream_id] = {
        "id": current_dream_id,
        "entry_time": current_time,
        "duration": 0.0,
        "content": "",
        "connected_memories": [],
        "intensity": story_intensity
    }
    
    # Emit signal
    emit_signal("dream_entered", current_dream_id)
    
    # Apply dream state effects
    if game_controller and game_controller.has_method("set_reality"):
        game_controller.set_reality("astral")  # Dreams happen in astral reality
    
    # Identify memories that might connect to this dream
    identify_dream_connection_targets()
    
    return current_dream_id

func exit_dream_state():
    if not is_in_dream_state:
        return
    
    is_in_dream_state = false
    
    # Update dream duration
    if dream_fragments.has(current_dream_id):
        dream_fragments[current_dream_id].duration = dream_time_accumulator
        
        # Generate dream content based on connected memories
        var dream_content = generate_dream_content(current_dream_id)
        dream_fragments[current_dream_id].content = dream_content
    
    # Emit signal
    emit_signal("dream_exited", current_dream_id)
    
    # Apply exit dream effects
    if game_controller and game_controller.has_method("set_reality"):
        game_controller.set_reality("physical")  # Return to physical reality
    
    current_dream_id = ""

func identify_dream_connection_targets():
    dream_connection_targets.clear()
    
    if memory_fragments.size() == 0:
        return
    
    # Get all memories sorted by time
    var sorted_memories = []
    for memory_id in memory_fragments:
        sorted_memories.append({
            "id": memory_id,
            "time": memory_fragments[memory_id].time
        })
    
    # Sort by time (newest first)
    sorted_memories.sort_custom(func(a, b): return a.time > b.time)
    
    # Take the top 5 newest memories as potential connections
    var max_targets = min(5, sorted_memories.size())
    for i in range(max_targets):
        dream_connection_targets.append(sorted_memories[i].id)

func update_dream_connections():
    if not is_in_dream_state or dream_connection_targets.size() == 0:
        return
    
    # Small chance to connect to a memory each update
    if randf() < 0.02 * dream_connection_strength:
        # Pick a random target
        var target_id = dream_connection_targets[randi() % dream_connection_targets.size()]
        
        # Connect the dream to this memory
        connect_dream_to_memory(current_dream_id, target_id)

func connect_dream_to_memory(dream_id, memory_id):
    if not dream_fragments.has(dream_id) or not memory_fragments.has(memory_id):
        return false
    
    # Add to dream's connected memories
    if not memory_id in dream_fragments[dream_id].connected_memories:
        dream_fragments[dream_id].connected_memories.append(memory_id)
    
    # Mark memory as dream-linked
    memory_fragments[memory_id].dream_linked = true
    
    return true

func generate_dream_content(dream_id):
    if not dream_fragments.has(dream_id):
        return "Empty dream"
    
    var dream_data = dream_fragments[dream_id]
    
    # Start with dream introduction
    var content = "Dream of "
    
    # Add theme based on story arc
    match current_story_arc:
        "beginning":
            content += "awakening and discovery"
        "rising_action":
            content += "growth and challenge"
        "climax":
            content += "confrontation and revelation"
        "falling_action":
            content += "reflection and understanding"
        "resolution":
            content += "harmony and completion"
    
    # Add connected memories
    if dream_data.connected_memories.size() > 0:
        content += " involving "
        var memory_texts = []
        
        for memory_id in dream_data.connected_memories:
            if memory_fragments.has(memory_id):
                var memory_text = memory_fragments[memory_id].content
                if memory_text.length() > 30:
                    memory_text = memory_text.substr(0, 30) + "..."
                memory_texts.append(memory_text)
        
        content += memory_texts.join(", ")
    else:
        content += " with no clear memories"
    
    return content

# ----- ANIMATION CONTROL -----
func trigger_movement_animations(velocity: Vector3):
    if not game_controller or velocity.length() < 0.1:
        return
    
    # Only trigger animations if enough time has passed
    if current_time - previous_time < min_time_for_animation:
        return
    
    # Get movement direction
    var direction = velocity.normalized()
    
    # Find words in movement path
    if word_seed_evolution and word_seed_evolution.active_seeds:
        var player_pos = player_controller.global_position
        var forward_pos = player_pos + direction * 5.0
        
        # Find words in path
        for word_id in word_seed_evolution.active_seeds:
            var word_data = word_seed_evolution.active_seeds[word_id]
            var word_pos = word_data.position
            
            # Check if word is roughly in movement path
            var to_word = word_pos - player_pos
            var dot_product = to_word.dot(direction)
            
            if dot_product > 0 and to_word.length() < 10.0:
                # Word is ahead in movement path, trigger animation
                animate_word_for_movement(word_id, velocity.length())

func animate_word_for_movement(word_id, speed):
    if not game_controller or not game_controller.has_method("create_animation"):
        return
    
    # Animation type depends on story arc and speed
    var animation_type = "pulse"
    
    if speed > 5.0:
        animation_type = "move_away"
    elif current_story_arc == "climax":
        animation_type = "rotate"
    elif current_story_arc == "rising_action":
        animation_type = "scale_up"
    elif current_story_arc == "falling_action":
        animation_type = "scale_down"
    
    # Create animation based on type
    match animation_type:
        "pulse":
            var animation_id = "pulse_" + word_id
            var data = {
                "word_id": word_id,
                "start_scale": Vector3(1.0, 1.0, 1.0),
                "end_scale": Vector3(1.2, 1.2, 1.2),
                "ease_factor": -2  # Ease out
            }
            game_controller.create_animation(animation_id, "word_scale", 0.5, data)
            
            # Create reverse animation to complete pulse
            var reverse_id = "pulse_reverse_" + word_id
            var reverse_data = {
                "word_id": word_id,
                "start_scale": Vector3(1.2, 1.2, 1.2),
                "end_scale": Vector3(1.0, 1.0, 1.0),
                "ease_factor": 2,  # Ease in
                "next_animation": ""  # End of sequence
            }
            game_controller.create_animation(reverse_id, "word_scale", 0.5, reverse_data)
            
            # Link animations
            game_controller.active_animations[animation_id].next_animation = reverse_id
            
            # Start animation
            game_controller.start_animation(animation_id)
        
        "move_away":
            var animation_id = "move_" + word_id
            
            if game_controller.words_in_space:
                var word_pos = game_controller.words_in_space.get_word_position(word_id)
                var move_dir = (word_pos - player_controller.global_position).normalized()
                var end_pos = word_pos + move_dir * 1.0
                
                var data = {
                    "word_id": word_id,
                    "start_position": word_pos,
                    "end_position": end_pos,
                    "ease_factor": 1  # Linear
                }
                game_controller.create_animation(animation_id, "word_move", 0.3, data)
                
                # Create return animation
                var return_id = "return_" + word_id
                var return_data = {
                    "word_id": word_id,
                    "start_position": end_pos,
                    "end_position": word_pos,
                    "ease_factor": 2,  # Ease in
                    "next_animation": ""  # End of sequence
                }
                game_controller.create_animation(return_id, "word_move", 0.7, return_data)
                
                # Link animations
                game_controller.active_animations[animation_id].next_animation = return_id
                
                # Start animation
                game_controller.start_animation(animation_id)
        
        "rotate":
            var animation_id = "rotate_" + word_id
            
            var data = {
                "word_id": word_id,
                "start_rotation": Vector3(0, 0, 0),
                "end_rotation": Vector3(0, PI, 0),
                "ease_factor": -1,  # Slight ease out
                "use_quaternion": true
            }
            game_controller.create_animation(animation_id, "word_rotation", 0.8, data)
            
            # Start animation
            game_controller.start_animation(animation_id)
        
        "scale_up":
            var animation_id = "scale_up_" + word_id
            
            var data = {
                "word_id": word_id,
                "start_scale": Vector3(1.0, 1.0, 1.0),
                "end_scale": Vector3(1.5, 1.5, 1.5),
                "ease_factor": 2  # Ease in
            }
            game_controller.create_animation(animation_id, "word_scale", 1.0, data)
            
            # Start animation
            game_controller.start_animation(animation_id)
        
        "scale_down":
            var animation_id = "scale_down_" + word_id
            
            var data = {
                "word_id": word_id,
                "start_scale": Vector3(1.0, 1.0, 1.0),
                "end_scale": Vector3(0.7, 0.7, 0.7),
                "ease_factor": -2  # Ease out
            }
            game_controller.create_animation(animation_id, "word_scale", 0.7, data)
            
            # Create return animation
            var return_id = "restore_" + word_id
            var return_data = {
                "word_id": word_id,
                "start_scale": Vector3(0.7, 0.7, 0.7),
                "end_scale": Vector3(1.0, 1.0, 1.0),
                "ease_factor": 2,  # Ease in
                "next_animation": ""  # End of sequence
            }
            game_controller.create_animation(return_id, "word_scale", 1.0, return_data)
            
            # Link animations
            game_controller.active_animations[animation_id].next_animation = return_id
            
            # Start animation
            game_controller.start_animation(animation_id)

# ----- PUBLIC API -----
func get_current_time():
    return current_time

func get_current_time_formatted():
    # Format time as HH:MM:SS
    var total_seconds = int(current_time)
    var hours = total_seconds / 3600
    var minutes = (total_seconds % 3600) / 60
    var seconds = total_seconds % 60
    
    return "%02d:%02d:%02d" % [hours, minutes, seconds]

func get_current_story_segment():
    if story_evolution_points.size() == 0:
        return ""
    
    return story_evolution_points[-1].segment

func get_current_story_arc():
    return current_story_arc

func get_story_evolution_points():
    return story_evolution_points

func get_memory_fragments():
    return memory_fragments

func get_dream_fragments():
    return dream_fragments

func get_telepathic_connections():
    return telepathic_connections

func toggle_dream_state():
    if is_in_dream_state:
        exit_dream_state()
    else:
        enter_dream_state()
    
    return is_in_dream_state

func set_references(game_ctrl, word_seed, zone_scale, player):
    game_controller = game_ctrl
    word_seed_evolution = word_seed
    zone_scale_system = zone_scale
    player_controller = player