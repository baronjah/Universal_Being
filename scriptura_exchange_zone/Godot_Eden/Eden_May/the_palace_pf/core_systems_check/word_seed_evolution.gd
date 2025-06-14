extends Node

class_name WordSeedEvolution

# ----- EVOLUTION SETTINGS -----
@export_category("Evolution Settings")
@export var evolution_enabled: bool = true
@export var evolution_speed: float = 1.0  # Multiplier for evolution rate
@export var random_mutation_chance: float = 0.05  # 5% chance of random mutations
@export var environmental_influence: float = 0.3  # How much environment affects evolution
@export var connection_influence: float = 0.4  # How much connections affect evolution
@export var max_evolution_stages: int = 7  # Maximum evolution stages

# ----- STORY SETTINGS -----
@export_category("Story Settings")
@export var story_generation_enabled: bool = true
@export var story_update_interval: float = 60.0  # Seconds between story updates
@export var story_complexity: float = 0.5  # How complex generated stories should be
@export var story_memory_size: int = 10  # How many story events to remember

# ----- SEED SETTINGS -----
@export_category("Seed Settings")
@export var initial_seed_words: Array = ["creation", "void", "light", "darkness", "potential"]
@export var seed_growth_rate: float = 1.0  # Base rate for seed growth
@export var seed_energy_requirement: float = 10.0  # Energy needed for seeds to grow
@export var seed_minimum_connections: int = 1  # Connections needed to evolve

# ----- COMPONENT REFERENCES -----
var words_in_space: Node  # Reference to word visualization system
var word_dna_system: Node  # Reference to DNA system
var player_controller: Node  # Reference to player for energy costs
var console: Node  # Reference to console for output

# ----- SYSTEM STATE -----
var active_seeds: Dictionary = {}  # word_id -> seed_data
var evolution_timers: Dictionary = {}  # word_id -> timer
var story_events: Array = []  # Array of story events that have occurred
var story_timer: Timer
var current_time: float = 0.0  # In-world time counter
var story_roots: Array = []  # Words that serve as story anchors

# ----- DNA SEQUENCES -----
var dna_libraries: Dictionary = {
    "creation": {
        "dna_patterns": ["ACTG-TGCA-ACTG-TCGA", "GTAC-CGTA-GTAC-ACGT"],
        "evolution_paths": ["life", "energy", "form", "idea"]
    },
    "destruction": {
        "dna_patterns": ["TCGA-GTAC-TCGA-GACT", "CATG-CATG-CATG-CATG"],
        "evolution_paths": ["chaos", "void", "entropy", "rebirth"]
    },
    "knowledge": {
        "dna_patterns": ["AACC-GGTT-AACC-GGTT", "AGCT-TCGA-AGCT-TCGA"],
        "evolution_paths": ["wisdom", "intelligence", "memory", "insight"]
    },
    "emotion": {
        "dna_patterns": ["AATT-GGCC-AATT-GGCC", "ACGT-TGCA-ACGT-TGCA"],
        "evolution_paths": ["joy", "fear", "love", "anger"]
    },
    "matter": {
        "dna_patterns": ["CCGG-AATT-CCGG-AATT", "CGAT-GCTA-CGAT-GCTA"],
        "evolution_paths": ["earth", "water", "fire", "air"]
    }
}

# ----- SIGNALS -----
signal seed_planted(word_id, initial_dna)
signal word_evolved(word_id, from_stage, to_stage, new_dna)
signal story_updated(story_text)
signal evolution_completed(word_id, final_form)

# ----- INITIALIZATION -----
func _ready():
    # Setup story timer
    story_timer = Timer.new()
    story_timer.wait_time = story_update_interval
    story_timer.one_shot = false
    story_timer.timeout.connect(_on_story_timer_timeout)
    add_child(story_timer)
    
    if story_generation_enabled:
        story_timer.start()

# ----- SEED PLANTING -----
func plant_seed(word_text: String, position: Vector3, category: String = "seed", custom_dna: String = "") -> String:
    if not words_in_space:
        push_error("WordSeedEvolution: words_in_space reference not set")
        return ""
    
    # Generate a unique ID
    var word_id = "seed_" + word_text + "_" + str(randi())
    
    # Generate or use provided DNA
    var dna = custom_dna
    if dna == "":
        dna = _generate_initial_dna(word_text)
    
    # Create the word in 3D space
    if words_in_space.has_method("add_word"):
        words_in_space.add_word(word_id, word_text, position, category)
        
        # Apply DNA to word appearance
        if word_dna_system:
            # Apply DNA visual properties
            var material = word_dna_system.apply_dna_to_material(words_in_space.get_word_material(word_id), dna)
            words_in_space.set_word_material(word_id, material)
    
    # Setup seed data
    active_seeds[word_id] = {
        "text": word_text,
        "dna": dna,
        "position": position,
        "evolution_stage": 0,
        "growth_progress": 0.0,
        "last_update_time": Time.get_ticks_msec() / 1000.0,
        "connected_words": [],
        "category": category,
        "story_role": _determine_story_role(word_text),
        "potential_evolutions": _get_potential_evolutions(word_text, dna)
    }
    
    # Emit signal
    emit_signal("seed_planted", word_id, dna)
    
    # Log to console
    if console and console.has_method("log"):
        console.log("Seed planted: " + word_text, Color(0.2, 0.8, 0.3))
    
    # Setup evolution timer
    _setup_evolution_timer(word_id)
    
    # Check if this is a potential story root
    if _is_story_root(word_text):
        story_roots.append(word_id)
    
    return word_id

# ----- EVOLUTION PROCESSING -----
func process_evolution(delta: float):
    if not evolution_enabled:
        return
    
    # Update in-world time
    current_time += delta
    
    # Process each active seed
    var seeds_to_process = active_seeds.keys()
    for word_id in seeds_to_process:
        if active_seeds.has(word_id):  # Check again in case it was removed during processing
            _update_seed_growth(word_id, delta)

func _update_seed_growth(word_id: String, delta: float):
    if not active_seeds.has(word_id):
        return
    
    var seed_data = active_seeds[word_id]
    
    # Calculate growth factors
    var connection_factor = _calculate_connection_factor(word_id)
    var environment_factor = _calculate_environment_factor(word_id)
    var energy_factor = _calculate_energy_factor(word_id)
    
    # Calculate total growth increment
    var growth_increment = delta * seed_growth_rate * evolution_speed * connection_factor * environment_factor * energy_factor
    
    # Apply growth
    seed_data.growth_progress += growth_increment
    
    # Check if ready for evolution
    if seed_data.growth_progress >= 1.0 and seed_data.evolution_stage < max_evolution_stages:
        _evolve_seed(word_id)

func _evolve_seed(word_id: String):
    if not active_seeds.has(word_id):
        return
    
    var seed_data = active_seeds[word_id]
    
    # Reset growth progress
    seed_data.growth_progress = 0.0
    
    # Record previous stage
    var previous_stage = seed_data.evolution_stage
    
    # Increment evolution stage
    seed_data.evolution_stage += 1
    
    # Evolve the DNA
    var new_dna = _evolve_dna(seed_data.dna, word_id)
    seed_data.dna = new_dna
    
    # Determine new word based on evolution
    var new_word = _determine_evolved_word(word_id, seed_data.text, seed_data.evolution_stage)
    seed_data.text = new_word
    
    # Update the word in 3D space
    if words_in_space:
        # Update text
        if words_in_space.has_method("update_word_text"):
            words_in_space.update_word_text(word_id, new_word)
        
        # Update appearance based on DNA
        if word_dna_system:
            var material = word_dna_system.apply_dna_to_material(words_in_space.get_word_material(word_id), new_dna)
            words_in_space.set_word_material(word_id, material)
            
            # Apply transformations
            if words_in_space.has_method("get_word_node"):
                var word_node = words_in_space.get_word_node(word_id)
                if word_node:
                    word_dna_system.apply_dna_to_transform(word_node, new_dna)
    
    # Update potential evolutions
    seed_data.potential_evolutions = _get_potential_evolutions(new_word, new_dna)
    
    # Record story event
    _add_story_event({
        "type": "evolution",
        "word_id": word_id,
        "from_word": seed_data.text,
        "to_word": new_word,
        "from_stage": previous_stage,
        "to_stage": seed_data.evolution_stage,
        "time": current_time
    })
    
    # Emit signal
    emit_signal("word_evolved", word_id, previous_stage, seed_data.evolution_stage, new_dna)
    
    # Log to console
    if console and console.has_method("log"):
        console.log("Word evolved: " + seed_data.text + " (Stage " + str(seed_data.evolution_stage) + ")", Color(0.8, 0.4, 0.9))
    
    # Check if final evolution reached
    if seed_data.evolution_stage >= max_evolution_stages:
        _finalize_evolution(word_id)

func _finalize_evolution(word_id: String):
    if not active_seeds.has(word_id):
        return
    
    var seed_data = active_seeds[word_id]
    
    # Special effects for fully evolved word
    if words_in_space and words_in_space.has_method("apply_special_effect"):
        words_in_space.apply_special_effect(word_id, "completion")
    
    # Record story event
    _add_story_event({
        "type": "completion",
        "word_id": word_id,
        "word": seed_data.text,
        "stage": seed_data.evolution_stage,
        "time": current_time
    })
    
    # Emit signal
    emit_signal("evolution_completed", word_id, seed_data.text)
    
    # Log to console
    if console and console.has_method("log_success"):
        console.log_success("Evolution completed: " + seed_data.text + " has reached its final form!")

# ----- DNA EVOLUTION -----
func _generate_initial_dna(word_text: String) -> String:
    # Check if we have a predefined DNA pattern for this word type
    var word_type = _determine_word_type(word_text)
    
    if dna_libraries.has(word_type):
        var library = dna_libraries[word_type]
        var patterns = library.dna_patterns
        
        if patterns.size() > 0:
            return patterns[randi() % patterns.size()]
    
    # Otherwise generate using the DNA system
    if word_dna_system:
        return word_dna_system.generate_dna_for_word(word_text)
    
    # Fallback to a basic pattern
    return "ACGT-ACGT-ACGT-ACGT"

func _evolve_dna(current_dna: String, word_id: String) -> String:
    if not active_seeds.has(word_id):
        return current_dna
    
    var seed_data = active_seeds[word_id]
    
    # Get DNA sections
    var dna_sections = current_dna.split("-")
    if dna_sections.size() != 4:
        # Invalid DNA format, regenerate
        return _generate_initial_dna(seed_data.text)
    
    # Apply evolution based on connections
    var connected_words = seed_data.connected_words
    var evolved_dna = dna_sections.duplicate()
    
    # If connected to other words, influence DNA
    if connected_words.size() > 0:
        for connected_id in connected_words:
            if active_seeds.has(connected_id):
                var connected_dna = active_seeds[connected_id].dna
                var connected_sections = connected_dna.split("-")
                
                if connected_sections.size() == 4:
                    # Randomly select a section to influence
                    var section_idx = randi() % 4
                    
                    # Cross-pollinate DNA
                    var current_section = evolved_dna[section_idx]
                    var influence_section = connected_sections[section_idx]
                    
                    if current_section.length() == influence_section.length():
                        var new_section = ""
                        for i in range(current_section.length()):
                            # 50% chance to take each nucleotide from either source
                            if randf() < 0.5:
                                new_section += current_section[i]
                            else:
                                new_section += influence_section[i]
                        
                        evolved_dna[section_idx] = new_section
    
    # Apply random mutations
    if randf() < random_mutation_chance:
        var section_idx = randi() % 4
        var nucleotide_idx = randi() % evolved_dna[section_idx].length()
        var nucleotides = ["A", "C", "G", "T", "U", "X", "Y", "Z"]
        var new_nucleotide = nucleotides[randi() % nucleotides.size()]
        
        # Apply mutation
        var section = evolved_dna[section_idx]
        evolved_dna[section_idx] = section.substr(0, nucleotide_idx) + new_nucleotide + section.substr(nucleotide_idx + 1)
    
    # Rejoin DNA sections
    return evolved_dna.join("-")

# ----- WORD EVOLUTION -----
func _determine_evolved_word(word_id: String, current_word: String, stage: int) -> String:
    if not active_seeds.has(word_id):
        return current_word
    
    var seed_data = active_seeds[word_id]
    
    # Check if we have predefined evolution paths
    var word_type = _determine_word_type(current_word)
    
    if dna_libraries.has(word_type) and stage <= max_evolution_stages:
        var library = dna_libraries[word_type]
        var paths = library.evolution_paths
        
        if paths.size() > 0:
            # Choose evolution path based on connections and environment
            var connection_influence = _calculate_connection_influence(word_id)
            var path_index = (connection_influence * paths.size()) as int % paths.size()
            
            return paths[path_index]
    
    # If no predefined path, use potential evolutions
    if seed_data.potential_evolutions.size() > 0:
        var evolution_index = randi() % seed_data.potential_evolutions.size()
        return seed_data.potential_evolutions[evolution_index]
    
    # If all else fails, append a symbol to show evolution
    var symbols = ["*", "+", "^", "'", ":", "~"]
    return current_word + symbols[stage % symbols.size()]

func _get_potential_evolutions(word_text: String, dna: String) -> Array:
    # Generate potential evolutions based on word and DNA
    var potential = []
    
    # Use word type to generate related concepts
    var word_type = _determine_word_type(word_text)
    
    match word_type:
        "creation":
            potential = ["life", "genesis", "birth", "formation", "emergence"]
        "destruction":
            potential = ["decay", "ruin", "collapse", "dissolution", "entropy"]
        "knowledge":
            potential = ["wisdom", "insight", "understanding", "comprehension", "enlightenment"]
        "emotion":
            potential = ["feeling", "passion", "sentiment", "sensation", "affection"]
        "matter":
            potential = ["substance", "element", "material", "essence", "form"]
        _:
            # For unknown types, generate variations
            potential = [word_text + "ion", word_text + "ness", word_text + "ity", "meta" + word_text, "trans" + word_text]
    
    # Use DNA to influence potential evolutions
    if word_dna_system:
        # Apply DNA influence (implementation depends on your DNA system)
        pass
    
    return potential

# ----- HELPER FUNCTIONS -----
func _determine_word_type(word_text: String) -> String:
    # Simple categorization based on word meaning
    var creation_words = ["create", "creation", "begin", "birth", "generate", "form", "manifest", "spawn"]
    var destruction_words = ["destroy", "destruction", "end", "death", "eliminate", "dissolve", "erase"]
    var knowledge_words = ["know", "knowledge", "learn", "understand", "comprehend", "perceive", "think"]
    var emotion_words = ["feel", "emotion", "love", "hate", "fear", "joy", "anger", "peace"]
    var matter_words = ["matter", "substance", "object", "thing", "material", "element", "atom"]
    
    word_text = word_text.to_lower()
    
    for word in creation_words:
        if word_text.find(word) >= 0:
            return "creation"
    
    for word in destruction_words:
        if word_text.find(word) >= 0:
            return "destruction"
    
    for word in knowledge_words:
        if word_text.find(word) >= 0:
            return "knowledge"
    
    for word in emotion_words:
        if word_text.find(word) >= 0:
            return "emotion"
    
    for word in matter_words:
        if word_text.find(word) >= 0:
            return "matter"
    
    # Default to creation for unknown words
    return "creation"

func _determine_story_role(word_text: String) -> String:
    # Determine what role this word might play in a story
    var protagonist_words = ["hero", "protagonist", "champion", "leader", "voyager", "explorer"]
    var antagonist_words = ["villain", "antagonist", "enemy", "opponent", "adversary", "challenge"]
    var setting_words = ["world", "realm", "dimension", "universe", "kingdom", "domain", "place"]
    var plot_words = ["journey", "quest", "adventure", "mission", "task", "challenge", "conflict"]
    
    word_text = word_text.to_lower()
    
    for word in protagonist_words:
        if word_text.find(word) >= 0:
            return "protagonist"
    
    for word in antagonist_words:
        if word_text.find(word) >= 0:
            return "antagonist"
    
    for word in setting_words:
        if word_text.find(word) >= 0:
            return "setting"
    
    for word in plot_words:
        if word_text.find(word) >= 0:
            return "plot"
    
    # Default to element for unknown words
    return "element"

func _is_story_root(word_text: String) -> bool:
    # Determine if this word should be a root for story generation
    var root_words = ["creation", "beginning", "genesis", "origin", "source", "foundation"]
    
    word_text = word_text.to_lower()
    
    for word in root_words:
        if word_text.find(word) >= 0:
            return true
    
    return false

func _setup_evolution_timer(word_id: String):
    # Create a timer for this seed's evolution
    var timer = Timer.new()
    timer.name = "EvolutionTimer_" + word_id
    timer.wait_time = 5.0  # Check evolution every 5 seconds
    timer.autostart = true
    timer.timeout.connect(func(): _on_evolution_timer_timeout(word_id))
    add_child(timer)
    
    evolution_timers[word_id] = timer

func _calculate_connection_factor(word_id: String) -> float:
    if not active_seeds.has(word_id):
        return 1.0
    
    var seed_data = active_seeds[word_id]
    var connected_count = seed_data.connected_words.size()
    
    # No connections means slow growth
    if connected_count == 0:
        return 0.5
    
    # Optimal number of connections is 3-5
    if connected_count >= seed_minimum_connections and connected_count <= 5:
        return 1.0 + (connected_count - seed_minimum_connections) * 0.1
    
    # Too many connections can slow growth
    if connected_count > 5:
        return 1.5 - (connected_count - 5) * 0.05
    
    # Less than minimum connections
    return 0.5 + (connected_count / seed_minimum_connections) * 0.5

func _calculate_environment_factor(word_id: String) -> float:
    if not active_seeds.has(word_id) or not words_in_space:
        return 1.0
    
    # In a real implementation, this would check the word's environment
    # For now, return a random factor between 0.8 and 1.2
    return 0.8 + randf() * 0.4

func _calculate_energy_factor(word_id: String) -> float:
    if not active_seeds.has(word_id) or not player_controller:
        return 1.0
    
    // In a real implementation, this would use the player's energy
    // For now, return 1.0 (no energy limitation)
    return 1.0

func _calculate_connection_influence(word_id: String) -> float:
    if not active_seeds.has(word_id):
        return 0.0
    
    var seed_data = active_seeds[word_id]
    var connected_count = seed_data.connected_words.size()
    
    if connected_count == 0:
        return 0.0
    
    // Calculate influence based on connection types
    var influence = 0.0
    for connected_id in seed_data.connected_words:
        if active_seeds.has(connected_id):
            var connected_type = _determine_word_type(active_seeds[connected_id].text)
            var self_type = _determine_word_type(seed_data.text)
            
            // Opposite types have more influence
            if (self_type == "creation" and connected_type == "destruction") or \
               (self_type == "destruction" and connected_type == "creation"):
                influence += 0.5
            else:
                influence += 0.2
    
    return min(influence, 1.0)

# ----- STORY GENERATION -----
func _on_story_timer_timeout():
    if story_generation_enabled:
        generate_story()

func generate_story() -> String:
    if story_events.size() == 0 and active_seeds.size() == 0:
        return "The story has yet to begin. Plant seeds of creation to start your narrative."
    
    var story = ""
    
    # Find story protagonists
    var protagonists = []
    var antagonists = []
    var settings = []
    
    for word_id in active_seeds:
        var seed_data = active_seeds[word_id]
        
        if seed_data.story_role == "protagonist":
            protagonists.append(seed_data.text)
        elif seed_data.story_role == "antagonist":
            antagonists.append(seed_data.text)
        elif seed_data.story_role == "setting":
            settings.append(seed_data.text)
    
    # Generate story beginning
    if protagonists.size() == 0:
        if active_seeds.size() > 0:
            # Use any word as protagonist if none defined
            var random_id = active_seeds.keys()[randi() % active_seeds.size()]
            protagonists.append(active_seeds[random_id].text)
    
    if settings.size() == 0:
        settings.append("the realm of words")
    
    // Craft the beginning
    story += "In " + settings[0] + ", "
    
    if protagonists.size() > 0:
        story += protagonists[0] + " "
    else:
        story += "an unnamed entity "
    
    // Add journey context
    story += "journeyed through the fabric of creation"
    
    if antagonists.size() > 0:
        story += ", facing the challenge of " + antagonists[0]
    
    story += ".\n\n"
    
    // Process story events
    if story_events.size() > 0:
        // Sort events by time
        story_events.sort_custom(func(a, b): return a.time < b.time)
        
        // Take most recent events up to story_memory_size
        var recent_events = story_events.slice(max(0, story_events.size() - story_memory_size))
        
        // Generate narrative from events
        for event in recent_events:
            match event.type:
                "evolution":
                    story += _narrative_for_evolution(event) + "\n"
                "connection":
                    story += _narrative_for_connection(event) + "\n"
                "completion":
                    story += _narrative_for_completion(event) + "\n"
    
    // Add story ending or continuation hook
    story += "\nThe story continues to unfold as words manifest new realities..."
    
    // Log to console
    if console and console.has_method("log"):
        console.log("Story updated", Color(0.7, 0.7, 1.0))
    
    // Emit signal
    emit_signal("story_updated", story)
    
    return story

func _narrative_for_evolution(event: Dictionary) -> String:
    var narratives = [
        "As time flowed, {from_word} transformed into {to_word}, revealing new potential.",
        "Through the process of change, {from_word} evolved to become {to_word}.",
        "The essence of {from_word} shifted, emerging as {to_word} in a brilliant display.",
        "{from_word} underwent metamorphosis, transcending into {to_word} as its true nature unfolded.",
        "In a subtle transformation, {from_word} ascended to its next form: {to_word}."
    ]
    
    var template = narratives[randi() % narratives.size()]
    return template.replace("{from_word}", event.from_word).replace("{to_word}", event.to_word)

func _narrative_for_connection(event: Dictionary) -> String:
    var narratives = [
        "A connection formed between {word1} and {word2}, creating a bridge of meaning.",
        "{word1} reached out to {word2}, establishing a bond that resonated through reality.",
        "The energies of {word1} and {word2} intertwined, strengthening both in their journey.",
        "A thread of significance connected {word1} to {word2}, weaving them into the tapestry of existence.",
        "As {word1} and {word2} joined in harmony, new possibilities emerged from their union."
    ]
    
    var template = narratives[randi() % narratives.size()]
    return template.replace("{word1}", event.word1).replace("{word2}", event.word2)

func _narrative_for_completion(event: Dictionary) -> String:
    var narratives = [
        "{word} reached its final form, radiating with completed potential.",
        "The journey of {word} culminated in transcendence, its essence now fully realized.",
        "Having reached the pinnacle of evolution, {word} now stood as a fundamental truth in the narrative.",
        "The metamorphosis of {word} completed, forever changing the fabric of the story.",
        "As {word} attained completeness, its influence spread throughout the realm of words."
    ]
    
    var template = narratives[randi() % narratives.size()]
    return template.replace("{word}", event.word)

func _add_story_event(event: Dictionary):
    story_events.append(event)
    
    // Trim story events if needed
    while story_events.size() > story_memory_size * 3:  // Keep 3x memory size for history
        story_events.pop_front()
    
    // If many events have occurred since last story update, generate new story
    if story_events.size() % 5 == 0:
        generate_story()

# ----- WORD CONNECTION -----
func connect_words(word_id1: String, word_id2: String) -> bool:
    if not active_seeds.has(word_id1) or not active_seeds.has(word_id2):
        return false
    
    // Add connection to tracking
    if not word_id2 in active_seeds[word_id1].connected_words:
        active_seeds[word_id1].connected_words.append(word_id2)
    
    if not word_id1 in active_seeds[word_id2].connected_words:
        active_seeds[word_id2].connected_words.append(word_id1)
    
    // Make visual connection if possible
    if words_in_space and words_in_space.has_method("connect_words"):
        words_in_space.connect_words(word_id1, word_id2)
    
    // Add story event
    _add_story_event({
        "type": "connection",
        "word1": active_seeds[word_id1].text,
        "word2": active_seeds[word_id2].text,
        "word_id1": word_id1,
        "word_id2": word_id2,
        "time": current_time
    })
    
    // Log to console
    if console and console.has_method("log"):
        console.log("Connected " + active_seeds[word_id1].text + " to " + active_seeds[word_id2].text, Color(0.3, 0.7, 0.9))
    
    return true

# ----- EVENT HANDLERS -----
func _on_evolution_timer_timeout(word_id: String):
    if evolution_enabled and active_seeds.has(word_id):
        _update_seed_growth(word_id, 5.0)  // Use timer interval as delta

# ----- PUBLIC API -----
func plant_word_seed(word_text: String, position: Vector3) -> String:
    return plant_seed(word_text, position)

func get_word_dna(word_id: String) -> String:
    if active_seeds.has(word_id):
        return active_seeds[word_id].dna
    return ""

func get_evolution_stage(word_id: String) -> int:
    if active_seeds.has(word_id):
        return active_seeds[word_id].evolution_stage
    return -1

func get_current_story() -> String:
    return generate_story()

func get_word_status(word_id: String) -> Dictionary:
    if active_seeds.has(word_id):
        return active_seeds[word_id]
    return {}

func set_references(words_system, dna_system, player, console_system):
    words_in_space = words_system
    word_dna_system = dna_system
    player_controller = player
    console = console_system