extends Node

class_name StoryConsoleCommands

# ----- CONSOLE REFERENCE -----
var console: Node  # JSHConsoleAdvanced reference
var word_seed_evolution: Node  # WordSeedEvolution reference
var words_in_space: Node  # Words visualization system
var player_controller: Node  # Player controller

# ----- COMMAND SETTINGS -----
var output_color_story: Color = Color(0.8, 0.6, 1.0)
var output_color_seed: Color = Color(0.4, 0.8, 0.4)
var output_color_error: Color = Color(1.0, 0.4, 0.4)
var output_color_system: Color = Color(0.8, 0.8, 0.2)

# ----- STORY VARIABLES -----
var current_narrative_style: String = "epic"  # fantasy, sci-fi, mythic, epic, etc.
var current_narrative_complexity: float = 0.5  # 0.0 to 1.0
var active_stories: Dictionary = {}  # story_id -> story_data
var story_authors: Array = ["Genesis", "Oracle", "Wordsmith", "Chronomancer", "Luminous"]
var last_story_id: String = ""

# ----- INITIALIZATION -----
func _ready():
    # Register story commands to the console
    register_commands()

# ----- COMMAND REGISTRATION -----
func register_commands():
    if not console:
        push_error("StoryConsoleCommands: console reference not set")
        return
    
    # Register each command
    console.register_command(
        "seed", 
        "Plant a word seed that will grow and evolve over time", 
        "seed <word> [position_x position_y position_z]",
        Callable(self, "_cmd_seed")
    )
    
    console.register_command(
        "story", 
        "Generate or control the narrative", 
        "story <generate|style|complexity|save|load> [args]",
        Callable(self, "_cmd_story")
    )
    
    console.register_command(
        "evolve", 
        "Manually trigger word evolution", 
        "evolve <word_id|all> [stages]",
        Callable(self, "_cmd_evolve")
    )
    
    console.register_command(
        "dna", 
        "View or modify a word's DNA", 
        "dna <view|modify|analyze> <word_id> [new_dna]",
        Callable(self, "_cmd_dna")
    )
    
    console.register_command(
        "wordstatus", 
        "Check the status of a seeded word", 
        "wordstatus <word_id|all>",
        Callable(self, "_cmd_wordstatus")
    )
    
    console.register_command(
        "narrative", 
        "Control the narrative style and complexity", 
        "narrative <style|complexity> <value>",
        Callable(self, "_cmd_narrative")
    )
    
    console.register_command(
        "genesis", 
        "Begin a new story with multiple seed words", 
        "genesis <theme> [word_count]",
        Callable(self, "_cmd_genesis")
    )

# ----- COMMAND IMPLEMENTATIONS -----
func _cmd_seed(args: Array) -> Dictionary:
    if not word_seed_evolution:
        return {"message": "Word seed evolution system not connected", "color": output_color_error}
    
    if args.size() < 1:
        return {"message": "Usage: /seed <word> [position_x position_y position_z]", "color": output_color_error}
    
    var word_text = args[0]
    var position = Vector3.ZERO
    
    if args.size() >= 4:
        # Position provided
        position = Vector3(float(args[1]), float(args[2]), float(args[3]))
    elif player_controller:
        # Use position in front of player
        position = player_controller.global_position + player_controller.camera_mount.global_transform.basis.z * -3.0
        position.y += 1.0  # Raise slightly
    
    # Plant the seed
    var seed_id = word_seed_evolution.plant_seed(word_text, position, "seed")
    
    if seed_id != "":
        return {
            "message": "Planted seed word '" + word_text + "' at " + position + "\nSeed ID: " + seed_id, 
            "color": output_color_seed
        }
    else:
        return {"message": "Failed to plant seed word", "color": output_color_error}

func _cmd_story(args: Array) -> Dictionary:
    if not word_seed_evolution:
        return {"message": "Word seed evolution system not connected", "color": output_color_error}
    
    if args.size() < 1:
        return {"message": "Usage: /story <generate|style|complexity|save|load> [args]", "color": output_color_error}
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "generate":
            return _cmd_story_generate(args.slice(1))
        "style":
            return _cmd_story_style(args.slice(1))
        "complexity":
            return _cmd_story_complexity(args.slice(1))
        "save":
            return _cmd_story_save(args.slice(1))
        "load":
            return _cmd_story_load(args.slice(1))
        _:
            return {"message": "Unknown story subcommand: " + subcommand, "color": output_color_error}

func _cmd_story_generate(args: Array) -> Dictionary:
    # Generate a story from current seeds
    var story = word_seed_evolution.generate_story()
    
    # Store story
    var story_id = "story_" + str(randi())
    active_stories[story_id] = {
        "text": story,
        "style": current_narrative_style,
        "complexity": current_narrative_complexity,
        "timestamp": Time.get_unix_time_from_system(),
        "author": story_authors[randi() % story_authors.size()]
    }
    
    last_story_id = story_id
    
    # Format story for console output
    var output = "=== Story by " + active_stories[story_id].author + " ===\n\n"
    output += story
    
    return {"message": output, "color": output_color_story}

func _cmd_story_style(args: Array) -> Dictionary:
    if args.size() < 1:
        return {"message": "Current style: " + current_narrative_style, "color": output_color_system}
    
    var style = args[0].to_lower()
    var valid_styles = ["fantasy", "sci-fi", "mythic", "epic", "dark", "whimsical", "cosmic", "philosophical"]
    
    if valid_styles.has(style):
        current_narrative_style = style
        
        # Update story generation if we have a word seed evolution system
        if word_seed_evolution:
            word_seed_evolution.story_generation_style = style
        
        return {"message": "Story style set to: " + style, "color": output_color_system}
    else:
        var styles_list = ", ".join(valid_styles)
        return {"message": "Invalid style. Valid options: " + styles_list, "color": output_color_error}

func _cmd_story_complexity(args: Array) -> Dictionary:
    if args.size() < 1:
        return {"message": "Current complexity: " + str(current_narrative_complexity), "color": output_color_system}
    
    var complexity = float(args[0])
    
    if complexity >= 0.0 and complexity <= 1.0:
        current_narrative_complexity = complexity
        
        # Update story generation if we have a word seed evolution system
        if word_seed_evolution:
            word_seed_evolution.story_complexity = complexity
        
        return {"message": "Story complexity set to: " + str(complexity), "color": output_color_system}
    else:
        return {"message": "Complexity must be between 0.0 and 1.0", "color": output_color_error}

func _cmd_story_save(args: Array) -> Dictionary:
    if args.size() < 1:
        return {"message": "Usage: /story save <filename>", "color": output_color_error}
    
    var filename = args[0]
    
    if last_story_id == "":
        return {"message": "No story to save. Generate a story first.", "color": output_color_error}
    
    if not active_stories.has(last_story_id):
        return {"message": "Story not found.", "color": output_color_error}
    
    var story_data = active_stories[last_story_id]
    
    # Prepare data for saving
    var save_data = {
        "story": story_data.text,
        "style": story_data.style,
        "complexity": story_data.complexity,
        "timestamp": story_data.timestamp,
        "author": story_data.author
    }
    
    # Convert to JSON
    var json_string = JSON.stringify(save_data)
    
    # Save to file
    var file = FileAccess.open("user://" + filename + ".json", FileAccess.WRITE)
    if file:
        file.store_string(json_string)
        file.close()
        return {"message": "Story saved to: " + filename + ".json", "color": output_color_system}
    else:
        return {"message": "Failed to save story.", "color": output_color_error}

func _cmd_story_load(args: Array) -> Dictionary:
    if args.size() < 1:
        return {"message": "Usage: /story load <filename>", "color": output_color_error}
    
    var filename = args[0]
    
    # Load from file
    if FileAccess.file_exists("user://" + filename + ".json"):
        var file = FileAccess.open("user://" + filename + ".json", FileAccess.READ)
        if file:
            var json_string = file.get_as_text()
            file.close()
            
            var json = JSON.new()
            var parse_result = json.parse(json_string)
            if parse_result == OK:
                var story_data = json.get_data()
                
                # Create story ID and store
                var story_id = "story_" + str(randi())
                active_stories[story_id] = {
                    "text": story_data.story,
                    "style": story_data.style,
                    "complexity": story_data.complexity,
                    "timestamp": story_data.timestamp,
                    "author": story_data.author
                }
                
                last_story_id = story_id
                
                # Format story for console output
                var output = "=== Story by " + story_data.author + " (Loaded) ===\n\n"
                output += story_data.story
                
                return {"message": output, "color": output_color_story}
            else:
                return {"message": "Failed to parse story file.", "color": output_color_error}
        else:
            return {"message": "Failed to open story file.", "color": output_color_error}
    else:
        return {"message": "Story file not found: " + filename + ".json", "color": output_color_error}

func _cmd_evolve(args: Array) -> Dictionary:
    if not word_seed_evolution:
        return {"message": "Word seed evolution system not connected", "color": output_color_error}
    
    if args.size() < 1:
        return {"message": "Usage: /evolve <word_id|all> [stages]", "color": output_color_error}
    
    var word_id = args[0]
    var stages = 1
    
    if args.size() >= 2:
        stages = int(args[1])
        stages = max(1, min(stages, 7))  # Limit to 1-7 stages
    
    if word_id == "all":
        # Evolve all words
        var evolved_count = 0
        
        # Get list of all active seeds
        var seeds = word_seed_evolution.active_seeds.keys()
        
        for seed_id in seeds:
            for i in range(stages):
                word_seed_evolution._evolve_seed(seed_id)
            evolved_count += 1
        
        return {
            "message": "Evolved " + str(evolved_count) + " words by " + str(stages) + " stages.", 
            "color": output_color_system
        }
    else:
        # Evolve specific word
        if word_seed_evolution.active_seeds.has(word_id):
            for i in range(stages):
                word_seed_evolution._evolve_seed(word_id)
            
            var word_data = word_seed_evolution.active_seeds[word_id]
            
            return {
                "message": "Evolved '" + word_data.text + "' to stage " + str(word_data.evolution_stage), 
                "color": output_color_system
            }
        else:
            return {"message": "Word ID not found: " + word_id, "color": output_color_error}

func _cmd_dna(args: Array) -> Dictionary:
    if not word_seed_evolution:
        return {"message": "Word seed evolution system not connected", "color": output_color_error}
    
    if args.size() < 2:
        return {"message": "Usage: /dna <view|modify|analyze> <word_id> [new_dna]", "color": output_color_error}
    
    var subcommand = args[0].to_lower()
    var word_id = args[1]
    
    if not word_seed_evolution.active_seeds.has(word_id):
        return {"message": "Word ID not found: " + word_id, "color": output_color_error}
    
    match subcommand:
        "view":
            var dna = word_seed_evolution.active_seeds[word_id].dna
            var word_text = word_seed_evolution.active_seeds[word_id].text
            
            var output = "DNA for '" + word_text + "':\n" + word_seed_evolution.word_dna_system.dna_to_string_representation(dna)
            return {"message": output, "color": output_color_system}
        
        "modify":
            if args.size() < 3:
                return {"message": "Usage: /dna modify <word_id> <new_dna>", "color": output_color_error}
            
            var new_dna = args[2]
            word_seed_evolution.active_seeds[word_id].dna = new_dna
            
            // Update appearance if possible
            if word_seed_evolution.words_in_space:
                var material = word_seed_evolution.word_dna_system.apply_dna_to_material(
                    word_seed_evolution.words_in_space.get_word_material(word_id),
                    new_dna
                )
                word_seed_evolution.words_in_space.set_word_material(word_id, material)
            
            return {"message": "DNA modified successfully", "color": output_color_system}
        
        "analyze":
            var dna = word_seed_evolution.active_seeds[word_id].dna
            var word_text = word_seed_evolution.active_seeds[word_id].text
            
            // Get analysis components
            var color = word_seed_evolution.word_dna_system.get_primary_color_from_dna(dna)
            var transform = word_seed_evolution.word_dna_system.get_shape_transform_from_dna(dna)
            var behavior = word_seed_evolution.word_dna_system.get_behavior_from_dna(dna)
            var sound = word_seed_evolution.word_dna_system.get_sound_profile_from_dna(dna)
            
            var output = "DNA Analysis for '" + word_text + "':\n"
            output += "Color: R=" + str(color.r) + " G=" + str(color.g) + " B=" + str(color.b) + "\n"
            output += "Shape: Scale=" + str(transform.scale) + " Rotation=" + str(transform.rotation) + "\n"
            output += "Behavior: " + str(behavior.active_behaviors.size()) + " active behaviors\n"
            output += "Sound: Pitch=" + str(sound.pitch) + " Timbre=" + sound.timbre
            
            return {"message": output, "color": output_color_system}
        
        _:
            return {"message": "Unknown DNA subcommand: " + subcommand, "color": output_color_error}

func _cmd_wordstatus(args: Array) -> Dictionary:
    if not word_seed_evolution:
        return {"message": "Word seed evolution system not connected", "color": output_color_error}
    
    if args.size() < 1:
        return {"message": "Usage: /wordstatus <word_id|all>", "color": output_color_error}
    
    var word_id = args[0]
    
    if word_id == "all":
        // List all words with their status
        var output = "Active Words:\n"
        var active_seeds = word_seed_evolution.active_seeds
        
        if active_seeds.size() == 0:
            return {"message": "No active word seeds found.", "color": output_color_system}
        
        for seed_id in active_seeds:
            var seed_data = active_seeds[seed_id]
            output += seed_id + ": '" + seed_data.text + "' (Stage " + str(seed_data.evolution_stage) + "/"
                    + str(word_seed_evolution.max_evolution_stages) + ") - Growth: " 
                    + str(int(seed_data.growth_progress * 100)) + "%\n"
        
        return {"message": output, "color": output_color_system}
    else:
        // Show detailed status for specific word
        if word_seed_evolution.active_seeds.has(word_id):
            var seed_data = word_seed_evolution.active_seeds[word_id]
            
            var output = "Word Status for '" + seed_data.text + "' (" + word_id + "):\n"
            output += "Evolution Stage: " + str(seed_data.evolution_stage) + "/" + str(word_seed_evolution.max_evolution_stages) + "\n"
            output += "Growth Progress: " + str(int(seed_data.growth_progress * 100)) + "%\n"
            output += "Category: " + seed_data.category + "\n"
            output += "Story Role: " + seed_data.story_role + "\n"
            output += "Position: " + str(seed_data.position) + "\n"
            output += "Connections: " + str(seed_data.connected_words.size()) + " words\n"
            
            if seed_data.potential_evolutions.size() > 0:
                output += "Potential Evolutions: " + ", ".join(seed_data.potential_evolutions)
            else:
                output += "Potential Evolutions: None"
            
            return {"message": output, "color": output_color_system}
        else:
            return {"message": "Word ID not found: " + word_id, "color": output_color_error}

func _cmd_narrative(args: Array) -> Dictionary:
    if args.size() < 2:
        return {"message": "Usage: /narrative <style|complexity> <value>", "color": output_color_error}
    
    var subcommand = args[0].to_lower()
    var value = args[1]
    
    match subcommand:
        "style":
            return _cmd_story_style([value])
        
        "complexity":
            return _cmd_story_complexity([value])
        
        _:
            return {"message": "Unknown narrative subcommand: " + subcommand, "color": output_color_error}

func _cmd_genesis(args: Array) -> Dictionary:
    if not word_seed_evolution:
        return {"message": "Word seed evolution system not connected", "color": output_color_error}
    
    if args.size() < 1:
        return {"message": "Usage: /genesis <theme> [word_count]", "color": output_color_error}
    
    var theme = args[0].to_lower()
    var word_count = 5  // Default to 5 words
    
    if args.size() >= 2:
        word_count = int(args[1])
        word_count = clamp(word_count, 2, 10)  // Limit between 2-10 words
    
    // Word sets based on themes
    var theme_words = {
        "creation": ["genesis", "beginning", "creation", "birth", "origin", "formation", "existence", "emergence", "dawn", "spark"],
        "destruction": ["apocalypse", "ruin", "decay", "collapse", "entropy", "chaos", "void", "end", "dissolution", "death"],
        "nature": ["forest", "mountain", "river", "ocean", "tree", "flower", "animal", "ecosystem", "wilderness", "landscape"],
        "cosmos": ["star", "planet", "galaxy", "universe", "nebula", "cosmic", "void", "infinity", "constellation", "celestial"],
        "technology": ["machine", "circuit", "algorithm", "network", "system", "program", "interface", "digital", "virtual", "data"],
        "emotion": ["love", "fear", "joy", "sorrow", "anger", "peace", "hope", "despair", "wonder", "passion"],
        "knowledge": ["wisdom", "insight", "learning", "education", "understanding", "comprehension", "discovery", "revelation", "concept", "theory"]
    }
    
    // Default to creation theme if not found
    if not theme_words.has(theme):
        theme = "creation"
    
    // Select random words from the theme
    var words = []
    var available_words = theme_words[theme].duplicate()
    
    for i in range(word_count):
        if available_words.size() == 0:
            break
        
        var index = randi() % available_words.size()
        words.append(available_words[index])
        available_words.remove_at(index)
    
    // Plant the words in a circular pattern
    var radius = 5.0
    var center_pos = Vector3.ZERO
    
    if player_controller:
        center_pos = player_controller.global_position + player_controller.camera_mount.global_transform.basis.z * -5.0
    
    var planted_words = []
    
    for i in range(words.size()):
        var angle = (2 * PI / words.size()) * i
        var offset = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
        var position = center_pos + offset
        
        // Plant the seed
        var seed_id = word_seed_evolution.plant_seed(words[i], position, "seed")
        
        if seed_id != "":
            planted_words.append(seed_id)
    
    // Connect the words in a circle
    for i in range(planted_words.size()):
        var next_i = (i + 1) % planted_words.size()
        word_seed_evolution.connect_words(planted_words[i], planted_words[next_i])
    
    return {
        "message": "Genesis of " + theme + " story created with " + str(words.size()) + " words: " + ", ".join(words),
        "color": output_color_story
    }

# ----- PUBLIC API -----
func set_references(console_ref, word_seed_ref, words_space_ref, player_ref):
    console = console_ref
    word_seed_evolution = word_seed_ref
    words_in_space = words_space_ref
    player_controller = player_ref
    
    // Register commands
    register_commands()

func get_last_story() -> String:
    if last_story_id != "" and active_stories.has(last_story_id):
        return active_stories[last_story_id].text
    return ""