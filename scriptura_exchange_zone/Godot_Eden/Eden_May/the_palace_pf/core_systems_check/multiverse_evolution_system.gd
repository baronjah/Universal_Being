extends Node

class_name MultiverseEvolutionSystem

# ----- MULTIVERSE SETTINGS -----
@export_category("Multiverse Settings")
@export var multiverse_enabled: bool = true
@export var universe_count: int = 7  # Number of parallel universes
@export var evolution_turn_duration: float = 300.0  # Seconds per turn
@export var universe_divergence_factor: float = 0.3  # How different universes become
@export var story_synchronization: float = 0.5  # How synchronized stories are across universes

# ----- TURN SETTINGS -----
@export_category("Turn Settings")
@export var auto_advance_turns: bool = true
@export var turns_per_age: int = 7  # Number of turns in one cosmic age
@export var cosmic_ages: Array = ["Genesis", "Formation", "Complexity", "Consciousness", "Transcendence", "Unity", "Beyond"]
@export var turn_transition_duration: float = 5.0  # Seconds to transition between turns

# ----- STORY INTEGRATION -----
@export_category("Story Integration")
@export var story_per_universe: bool = true  # Each universe has its own story
@export var metanarrative_enabled: bool = true  # Overall story connecting all universes
@export var crossover_probability: float = 0.2  # Chance of story elements crossing universes
@export var player_story_influence: float = 0.7  # How much player actions affect stories

# ----- COMPONENT REFERENCES -----
var game_controller: Node
var time_progression_system: Node
var word_seed_evolution: Node
var zone_scale_system: Node
var player_controller: Node

# ----- MULTIVERSE STATE -----
var current_turn: int = 1
var current_age: int = 0
var current_universe_id: int = 0
var active_universes: Dictionary = {}  # universe_id -> universe_data
var turn_time_remaining: float = 0.0
var is_transitioning_turn: bool = false
var turn_transition_progress: float = 0.0
var metanarrative: Dictionary = {}
var universe_access_points: Dictionary = {}  # location_id -> universe_id

# ----- STORY TRACKING -----
var universe_stories: Dictionary = {}  # universe_id -> story_data
var crossover_events: Array = []
var player_universe_history: Array = []  # Track which universes player has visited

# ----- EVOLUTION TRACKING -----
var evolution_matrices: Dictionary = {}  # universe_id -> evolution_matrix
var core_concepts: Dictionary = {}  # concept_id -> concept_data across universes
var multiversal_constants: Array = []  # Concepts that persist across all universes
var universe_seeds: Dictionary = {}  # universe_id -> seed_value

# ----- SIGNALS -----
signal turn_advanced(new_turn, age)
signal universe_changed(from_universe, to_universe)
signal story_evolved(universe_id, old_stage, new_stage)
signal crossover_occurred(from_universe, to_universe, elements)
signal multiverse_state_changed(state)

# ----- INITIALIZATION -----
func _ready():
    # Initialize turn timer
    turn_time_remaining = evolution_turn_duration
    
    # Create initial universes
    if multiverse_enabled:
        create_initial_universes()
    
    # Initialize metanarrative
    if metanarrative_enabled:
        initialize_metanarrative()
    
    # Create timer for turn advancement
    var turn_timer = Timer.new()
    turn_timer.name = "TurnTimer"
    turn_timer.wait_time = 1.0  # Check every second
    turn_timer.one_shot = false
    turn_timer.timeout.connect(_on_turn_timer_timeout)
    add_child(turn_timer)
    turn_timer.start()
    
    # Connect to player signals
    if player_controller:
        player_controller.connect("player_moved", _on_player_moved)

# ----- UNIVERSE CREATION -----
func create_initial_universes():
    # Create specified number of universes
    for i in range(universe_count):
        create_universe(i)
    
    # Set the initial active universe
    set_active_universe(0)
    
    # Create universe access points
    create_universe_access_points()
    
    # Establish multiversal constants
    establish_multiversal_constants()

func create_universe(universe_id: int):
    # Generate a seed for this universe
    var universe_seed = hash(str(universe_id) + str(Time.get_ticks_msec()))
    universe_seeds[universe_id] = universe_seed
    
    # Set the seed for deterministic generation
    seed(universe_seed)
    
    # Generate base properties
    var base_properties = {
        "time_flow_rate": randf_range(0.7, 1.3),
        "reality_stability": randf_range(0.5, 1.0),
        "evolution_speed": randf_range(0.8, 1.2),
        "manifestation_rate": randf_range(0.6, 1.4),
        "connection_strength": randf_range(0.7, 1.3)
    }
    
    # Generate universe color palette
    var primary_color = Color(randf(), randf(), randf())
    var secondary_color = primary_color.inverted()
    var accent_color = Color(randf(), randf(), randf())
    
    # Create universe data
    var universe_data = {
        "id": universe_id,
        "name": generate_universe_name(universe_id),
        "seed": universe_seed,
        "creation_turn": current_turn,
        "creation_age": current_age,
        "properties": base_properties,
        "color_palette": {
            "primary": primary_color,
            "secondary": secondary_color,
            "accent": accent_color
        },
        "dominant_reality": choose_dominant_reality(universe_id),
        "zones": {},
        "words": {},
        "story_state": {
            "segment": "awakening",
            "arc": "beginning",
            "intensity": 0.0
        }
    }
    
    # Store the universe
    active_universes[universe_id] = universe_data
    
    # Initialize universe story
    initialize_universe_story(universe_id)
    
    # Initialize evolution matrix
    initialize_evolution_matrix(universe_id)
    
    return universe_id

func generate_universe_name(universe_id: int) -> String:
    var prefixes = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", 
                   "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", 
                   "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega"]
    
    var suffixes = ["Prime", "Secundus", "Tertius", "Nexus", "Vortex", "Continuum", 
                   "Infinitum", "Vertex", "Locus", "Horizon", "Zenith", "Nadir"]
    
    var numbers = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
    
    # Use universe_id for deterministic naming
    var prefix_index = universe_id % prefixes.size()
    var suffix_index = (universe_id * 3) % suffixes.size()
    var number_index = (universe_id * 7) % numbers.size()
    
    # Generate name patterns based on universe_id
    var pattern = universe_id % 4
    
    match pattern:
        0:
            return prefixes[prefix_index] + " " + numbers[number_index]
        1:
            return prefixes[prefix_index] + " " + suffixes[suffix_index]
        2:
            return prefixes[prefix_index] + "-" + str(universe_id * 11)
        3:
            return prefixes[prefix_index] + " " + suffixes[suffix_index] + " " + numbers[number_index]
    
    return "Universe " + str(universe_id)

func choose_dominant_reality(universe_id: int) -> String:
    var realities = ["physical", "digital", "astral"]
    
    # Use universe_id for deterministic selection
    var reality_index = universe_id % realities.size()
    
    return realities[reality_index]

func initialize_universe_story(universe_id: int):
    # Create a starting story structure for this universe
    var story_type = universe_id % 5
    var story_name = ""
    var story_theme = ""
    var story_protagonist = ""
    var story_antagonist = ""
    
    # Generate story aspects based on universe properties
    match story_type:
        0: # Creation story
            story_name = "The Birth of " + active_universes[universe_id].name
            story_theme = "creation"
            story_protagonist = "Creator"
            story_antagonist = "Void"
        1: # Conflict story
            story_name = "The War of " + active_universes[universe_id].name
            story_theme = "conflict"
            story_protagonist = "Order"
            story_antagonist = "Chaos"
        2: # Journey story
            story_name = "The Voyage Through " + active_universes[universe_id].name
            story_theme = "exploration"
            story_protagonist = "Traveler"
            story_antagonist = "Unknown"
        3: # Transformation story
            story_name = "The Metamorphosis of " + active_universes[universe_id].name
            story_theme = "transformation"
            story_protagonist = "Change"
            story_antagonist = "Stasis"
        4: # Unity story
            story_name = "The Unification of " + active_universes[universe_id].name
            story_theme = "unity"
            story_protagonist = "Harmony"
            story_antagonist = "Division"
    
    # Create story data
    var story_data = {
        "name": story_name,
        "theme": story_theme,
        "protagonist": story_protagonist,
        "antagonist": story_antagonist,
        "current_segment": "awakening",
        "segments_completed": [],
        "events": [],
        "connections": [],
        "climax_turn": current_turn + 3 + universe_id % 3, # When story reaches climax
        "resolution_turn": current_turn + 5 + universe_id % 3 # When story reaches resolution
    }
    
    # Store universe story
    universe_stories[universe_id] = story_data

func initialize_evolution_matrix(universe_id: int):
    # Create an evolution matrix that defines how concepts evolve in this universe
    var matrix = {}
    
    # Base concept categories
    var concept_categories = ["energy", "matter", "consciousness", "time", "space", "force", "form"]
    
    # For each category, define how it evolves
    for category in concept_categories:
        var evolution_path = []
        
        # Generate 5 evolution stages for this concept category
        for i in range(5):
            var stage = {
                "name": generate_evolution_stage_name(category, i),
                "level": i,
                "properties": {
                    "stability": randf(),
                    "complexity": i * 0.2 + randf() * 0.2,
                    "energy": 1.0 - (i * 0.15 + randf() * 0.1)
                }
            }
            evolution_path.append(stage)
        
        matrix[category] = evolution_path
    
    # Store the evolution matrix
    evolution_matrices[universe_id] = matrix

func generate_evolution_stage_name(category: String, level: int) -> String:
    # Generate appropriate stage names based on category and level
    var stage_names = {
        "energy": ["potential", "kinetic", "thermal", "quantum", "cosmic"],
        "matter": ["particle", "element", "compound", "structure", "organism"],
        "consciousness": ["reflex", "awareness", "thought", "reflection", "enlightenment"],
        "time": ["moment", "duration", "sequence", "cycle", "eternity"],
        "space": ["point", "plane", "dimension", "manifold", "multiverse"],
        "force": ["attraction", "repulsion", "balance", "harmony", "transcendence"],
        "form": ["chaos", "pattern", "structure", "system", "perfection"]
    }
    
    if stage_names.has(category) and level < stage_names[category].size():
        return stage_names[category][level]
    
    return "Stage " + str(level)

func establish_multiversal_constants():
    # Define concepts that persist across all universes
    var constants = ["existence", "creation", "entropy", "unity", "duality", "infinity"]
    
    for concept in constants:
        var concept_id = "constant_" + concept
        
        var concept_data = {
            "id": concept_id,
            "name": concept,
            "is_constant": true,
            "universe_manifestations": {}
        }
        
        # Create manifestation in each universe
        for universe_id in active_universes:
            concept_data.universe_manifestations[universe_id] = {
                "word_id": "",  # Will be filled when manifested
                "stability": 1.0,  # Constants are fully stable
                "influence": 0.8 + randf() * 0.2  # High influence
            }
        
        # Add to core concepts
        core_concepts[concept_id] = concept_data
        
        # Add to multiversal constants
        multiversal_constants.append(concept_id)

func create_universe_access_points():
    # Create access points between universes
    for universe_id in active_universes:
        # Determine how many access points to create from this universe
        var access_count = 1 + universe_id % 3  # 1-3 access points
        
        for i in range(access_count):
            # Choose target universe (not self)
            var target_universes = active_universes.keys()
            target_universes.erase(universe_id)
            
            if target_universes.size() == 0:
                continue
            
            var target_id = target_universes[i % target_universes.size()]
            
            # Generate a unique ID for this access point
            var access_id = "access_" + str(universe_id) + "_to_" + str(target_id)
            
            # Create access point data
            universe_access_points[access_id] = {
                "id": access_id,
                "from_universe": universe_id,
                "to_universe": target_id,
                "position": Vector3(10 + universe_id * 5, 0, 10 + target_id * 5),  # Placeholder position
                "stability": 0.7 + randf() * 0.3,
                "energy_cost": 25.0 + randf() * 25.0,
                "active": true
            }

# ----- METANARRATIVE -----
func initialize_metanarrative():
    # Create an overarching narrative that connects all universes
    metanarrative = {
        "name": "The Cosmic Symphony",
        "current_act": 0,
        "acts": [
            {
                "name": "The Divergence",
                "description": "The splitting of the one into the many.",
                "required_turns": 2,
                "completion_conditions": ["visit_universes_count", 3],
                "completed": false
            },
            {
                "name": "The Patterns Emerge",
                "description": "Finding order in the chaotic multiverse.",
                "required_turns": 3,
                "completion_conditions": ["core_concepts_manifested", 4],
                "completed": false
            },
            {
                "name": "The Great Crossroads",
                "description": "Paths between universes begin to form.",
                "required_turns": 2,
                "completion_conditions": ["crossover_events_count", 3],
                "completed": false
            },
            {
                "name": "The Cosmic Alignment",
                "description": "Universes begin to synchronize along certain axes.",
                "required_turns": 3,
                "completion_conditions": ["alignment_level", 0.7],
                "completed": false
            },
            {
                "name": "The Great Convergence",
                "description": "The many begin to return to the one.",
                "required_turns": 2,
                "completion_conditions": ["synchronization_level", 0.8],
                "completed": false
            },
            {
                "name": "The Ultimate Reality",
                "description": "The emergence of the true nature of existence.",
                "required_turns": 3,
                "completion_conditions": ["core_concepts_evolved", 7],
                "completed": false
            },
            {
                "name": "Beyond Understanding",
                "description": "That which transcends all description.",
                "required_turns": 1,
                "completion_conditions": ["all_previous_acts_completed"],
                "completed": false
            }
        ],
        "events": [],
        "player_influence": 0.0
    }

# ----- TURN MANAGEMENT -----
func _on_turn_timer_timeout():
    if !multiverse_enabled:
        return
    
    # Update turn timer
    turn_time_remaining -= 1.0
    
    # Check if it's time to advance to next turn
    if turn_time_remaining <= 0 and auto_advance_turns and !is_transitioning_turn:
        begin_turn_transition()

func begin_turn_transition():
    if is_transitioning_turn:
        return
    
    is_transitioning_turn = true
    turn_transition_progress = 0.0
    
    # Notify about turn transition
    if game_controller and game_controller.has_method("show_notification"):
        game_controller.show_notification("Cosmic Turn " + str(current_turn) + " ending...", 3.0)

func process_turn_transition(delta):
    if !is_transitioning_turn:
        return
    
    # Update transition progress
    turn_transition_progress += delta / turn_transition_duration
    
    # Perform transition effects
    apply_turn_transition_effects()
    
    # Check if transition is complete
    if turn_transition_progress >= 1.0:
        complete_turn_transition()

func apply_turn_transition_effects():
    # Apply visual and gameplay effects during turn transition
    var intensity = sin(turn_transition_progress * PI)
    
    # Apply universe-wide effects
    for universe_id in active_universes:
        if universe_id == current_universe_id:
            # Apply effects in current universe
            
            # Time dilation during transition
            if time_progression_system:
                time_progression_system.time_multiplier = 1.0 + intensity * 2.0
            
            # Evolution acceleration
            var universe_data = active_universes[universe_id]
            universe_data.properties.evolution_speed = universe_data.properties.evolution_speed * (1.0 + intensity)
            
            # Trigger word evolutions if we're in this universe
            if word_seed_evolution:
                var evolution_count = max(3, 5 * intensity) as int
                trigger_word_evolutions(evolution_count)

func complete_turn_transition():
    # Advance to the next turn
    current_turn += 1
    
    # Check if we've entered a new age
    if current_turn % turns_per_age == 1:
        current_age = min(current_age + 1, cosmic_ages.size() - 1)
    
    # Reset timer
    turn_time_remaining = evolution_turn_duration
    is_transitioning_turn = false
    
    # Apply turn advancement effects
    apply_turn_advancement()
    
    # Notify about new turn
    if game_controller and game_controller.has_method("show_notification"):
        game_controller.show_notification(
            "Cosmic Turn " + str(current_turn) + " begins - Age of " + cosmic_ages[current_age],
            3.0
        )
    
    # Emit signal
    emit_signal("turn_advanced", current_turn, cosmic_ages[current_age])

func apply_turn_advancement():
    # Apply changes that happen when a turn advances
    
    # Update story progress in each universe
    for universe_id in universe_stories:
        advance_universe_story(universe_id)
    
    # Update metanarrative
    if metanarrative_enabled:
        advance_metanarrative()
    
    # Chance for universe evolution
    evolve_universes()
    
    # Chance for crossover events
    generate_crossover_events()
    
    # Evolve core concepts
    evolve_core_concepts()
    
    # Update universe properties
    update_universe_properties()

# ----- UNIVERSE NAVIGATION -----
func set_active_universe(universe_id: int):
    if !active_universes.has(universe_id):
        return
    
    var old_universe_id = current_universe_id
    current_universe_id = universe_id
    
    # Track player's universe history
    if !player_universe_history.has(universe_id):
        player_universe_history.append(universe_id)
    
    # Apply universe-specific settings
    apply_universe_settings(universe_id)
    
    # Emit signal
    emit_signal("universe_changed", old_universe_id, universe_id)
    
    # Notify via GUI
    if game_controller and game_controller.has_method("show_notification"):
        game_controller.show_notification(
            "Entered " + active_universes[universe_id].name + " Universe",
            3.0
        )

func apply_universe_settings(universe_id: int):
    if !active_universes.has(universe_id):
        return
    
    var universe_data = active_universes[universe_id]
    
    # Apply universe properties to various systems
    
    # Apply to time progression
    if time_progression_system:
        time_progression_system.base_time_scale = universe_data.properties.time_flow_rate
    
    # Apply dominant reality
    if game_controller and game_controller.has_method("set_reality"):
        game_controller.set_reality(universe_data.dominant_reality)
    
    # Apply color palette
    if game_controller and game_controller.has_method("set_color_palette"):
        game_controller.set_color_palette(
            universe_data.color_palette.primary,
            universe_data.color_palette.secondary,
            universe_data.color_palette.accent
        )
    
    # Apply zone properties if zone system exists
    if zone_scale_system:
        apply_universe_zone_properties(universe_id)

func apply_universe_zone_properties(universe_id: int):
    if !zone_scale_system or !active_universes.has(universe_id):
        return
    
    var universe_data = active_universes[universe_id]
    
    # Apply universe properties to all zones
    for zone_id in zone_scale_system.active_zones:
        var zone = zone_scale_system.active_zones[zone_id]
        
        # Adjust evolution factor
        zone.evolution_factor *= universe_data.properties.evolution_speed
        
        # Adjust manifestation factor
        zone.manifestation_factor *= universe_data.properties.manifestation_rate
        
        # Adjust time dilation
        zone.time_dilation *= universe_data.properties.time_flow_rate

func travel_between_universes(access_id: String):
    if !universe_access_points.has(access_id):
        return false
    
    var access_point = universe_access_points[access_id]
    
    if !access_point.active:
        return false
    
    // Check if player has enough energy
    if player_controller and player_controller.energy < access_point.energy_cost:
        if game_controller and game_controller.has_method("show_notification"):
            game_controller.show_notification(
                "Not enough energy to travel between universes!",
                2.0
            )
        return false
    
    // Consume energy
    if player_controller:
        player_controller.set_energy_level(player_controller.energy - access_point.energy_cost)
    
    // Set new active universe
    set_active_universe(access_point.to_universe)
    
    // Teleport player to access point exit
    if player_controller:
        player_controller.teleport_to(access_point.position)
    
    // Record crossover event
    record_crossover_event(access_point.from_universe, access_point.to_universe, ["player_travel"])
    
    return true

# ----- STORY MANAGEMENT -----
func advance_universe_story(universe_id: int):
    if !universe_stories.has(universe_id):
        return
    
    var story = universe_stories[universe_id]
    var progress_factor = 0.0
    
    // Calculate story progress based on turn
    if story.climax_turn > story.resolution_turn:
        // Handle invalid turn configuration
        story.resolution_turn = story.climax_turn + 2
    
    if current_turn < story.climax_turn:
        // Before climax - rising action
        progress_factor = float(current_turn - story.current_segment) / float(story.climax_turn - 1)
        story.current_stage = "rising_action"
    elif current_turn == story.climax_turn:
        // At climax
        progress_factor = 1.0
        story.current_stage = "climax"
    elif current_turn < story.resolution_turn:
        // After climax, before resolution - falling action
        progress_factor = 1.0 - float(current_turn - story.climax_turn) / float(story.resolution_turn - story.climax_turn)
        story.current_stage = "falling_action"
    else:
        // At or after resolution
        progress_factor = 0.0
        story.current_stage = "resolution"
    
    // Determine story segment based on progress
    var old_segment = story.current_segment
    var segments = ["awakening", "exploration", "connection", "transformation", "conflict", "resolution", "transcendence", "rebirth"]
    
    // Calculate segment index (0-7)
    var segment_index = 0
    
    if story.current_stage == "rising_action":
        segment_index = int(progress_factor * 4)  // 0-3
    elif story.current_stage == "climax":
        segment_index = 4  // Conflict is always at climax
    elif story.current_stage == "falling_action":
        segment_index = 5  // Resolution during falling action
    elif story.current_stage == "resolution":
        segment_index = 6 + (current_turn - story.resolution_turn) % 2  // Alternate between transcendence and rebirth
    
    segment_index = clamp(segment_index, 0, segments.size() - 1)
    story.current_segment = segments[segment_index]
    
    // If segment changed, record it and emit signal
    if old_segment != story.current_segment:
        story.segments_completed.append(old_segment)
        
        // Create a story event
        var event = {
            "type": "segment_change",
            "from": old_segment,
            "to": story.current_segment,
            "turn": current_turn,
            "universe": universe_id
        }
        story.events.append(event)
        
        // Emit signal
        emit_signal("story_evolved", universe_id, old_segment, story.current_segment)
        
        // Apply story segment effects if we're in this universe
        if universe_id == current_universe_id:
            apply_story_segment_effects(story.current_segment)

func apply_story_segment_effects(segment: String):
    // Apply effects based on story segment
    match segment:
        "awakening":
            // Create initial core words
            manifest_core_concepts(["existence", "creation"], 3)
        
        "exploration":
            // Create exploration-themed words
            manifest_themed_words("exploration", 5)
            
        "connection":
            // Increase connection visibility and create connections
            connect_existing_words(10)
            
        "transformation":
            // Evolve existing words
            trigger_word_evolutions(7)
            
        "conflict":
            // Create opposing forces
            create_opposing_forces()
            
        "resolution":
            // Harmonize opposing forces
            connect_opposing_words()
            
        "transcendence":
            // Create transcendence-themed words
            manifest_themed_words("transcendence", 5)
            
        "rebirth":
            // Reset some aspects and prepare for next cycle
            prepare_for_rebirth()

func manifest_core_concepts(concept_names: Array, count: int):
    if !word_seed_evolution:
        return
    
    var manifested_count = 0
    
    // First manifest specific named concepts
    for concept_name in concept_names:
        var concept_id = "constant_" + concept_name
        
        if core_concepts.has(concept_id):
            var concept = core_concepts[concept_id]
            
            // Check if already manifested in this universe
            if concept.universe_manifestations.has(current_universe_id) and concept.universe_manifestations[current_universe_id].word_id != "":
                continue
            
            // Manifest the concept
            var position = Vector3(randf_range(-5, 5), randf_range(-1, 3), randf_range(-5, 5))
            var word_id = word_seed_evolution.plant_seed(concept_name, position, "concept")
            
            // Record manifestation
            if word_id != "":
                concept.universe_manifestations[current_universe_id].word_id = word_id
                manifested_count += 1
                
                // Add visual effects
                if game_controller and game_controller.has_method("create_word_hologram"):
                    game_controller.create_word_hologram(word_id)
    
    // Then manifest additional random core concepts up to count
    while manifested_count < count:
        // Choose a concept category
        var categories = ["energy", "matter", "consciousness", "time", "space", "force", "form"]
        var category = categories[randi() % categories.size()]
        
        // Get first evolution stage for this category
        if evolution_matrices.has(current_universe_id) and evolution_matrices[current_universe_id].has(category):
            var first_stage = evolution_matrices[current_universe_id][category][0]
            
            // Manifest this concept
            var position = Vector3(randf_range(-10, 10), randf_range(-1, 3), randf_range(-10, 10))
            word_seed_evolution.plant_seed(first_stage.name, position, "concept")
            manifested_count += 1

func manifest_themed_words(theme: String, count: int):
    if !word_seed_evolution:
        return
    
    var theme_words = {
        "exploration": ["discover", "journey", "explore", "search", "path", "find", "adventure", "frontier", "unknown", "horizon"],
        "conflict": ["conflict", "tension", "opposition", "clash", "struggle", "challenge", "battle", "war", "contest", "fight"],
        "transcendence": ["transcend", "ascend", "elevate", "surpass", "beyond", "higher", "enlighten", "evolve", "transform", "exceed"],
        "unity": ["unity", "harmony", "oneness", "wholeness", "integration", "synthesis", "coherence", "union", "merge", "blend"]
    }
    
    if !theme_words.has(theme):
        return
    
    var words = theme_words[theme]
    words.shuffle()
    
    // Manifest words in a pattern
    for i in range(min(count, words.size())):
        var angle = (2 * PI / count) * i
        var radius = 10.0
        var position = Vector3(cos(angle) * radius, randf_range(0, 3), sin(angle) * radius)
        
        word_seed_evolution.plant_seed(words[i], position, "concept")

func connect_existing_words(connection_count: int):
    if !word_seed_evolution:
        return
    
    var connections_made = 0
    var existing_words = []
    
    // Get all existing words
    if word_seed_evolution.has_method("get_all_words"):
        existing_words = word_seed_evolution.get_all_words()
    elif word_seed_evolution.active_seeds:
        existing_words = word_seed_evolution.active_seeds.keys()
    
    if existing_words.size() < 2:
        return
    
    // Shuffle words for random connections
    existing_words.shuffle()
    
    // Connect words
    for i in range(min(connection_count, existing_words.size() - 1)):
        var word1 = existing_words[i]
        var word2 = existing_words[(i + 1) % existing_words.size()]
        
        if word_seed_evolution.has_method("connect_words"):
            if word_seed_evolution.connect_words(word1, word2):
                connections_made += 1

func trigger_word_evolutions(count: int):
    if !word_seed_evolution or !word_seed_evolution.has_method("_evolve_seed") or !word_seed_evolution.active_seeds:
        return
    
    var seeds = word_seed_evolution.active_seeds.keys()
    if seeds.size() == 0:
        return
    
    // Shuffle seeds for random selection
    seeds.shuffle()
    
    // Evolve words
    for i in range(min(count, seeds.size())):
        word_seed_evolution._evolve_seed(seeds[i])

func create_opposing_forces():
    if !zone_scale_system:
        return
    
    // Create two opposing zones
    var order_zone_id = zone_scale_system.create_custom_zone(
        Vector3(15, 0, 0),
        5.0,
        "human",
        "STABLE",
        {"force": "order", "polarity": 1}
    )
    
    var chaos_zone_id = zone_scale_system.create_custom_zone(
        Vector3(-15, 0, 0),
        5.0,
        "human",
        "CHAOTIC",
        {"force": "chaos", "polarity": -1}
    )
    
    // Create words in each zone
    if word_seed_evolution:
        var order_words = ["order", "structure", "system", "pattern", "discipline"]
        var chaos_words = ["chaos", "entropy", "freedom", "chance", "spontaneity"]
        
        // Manifest order words
        for word in order_words:
            var pos = zone_scale_system.active_zones[order_zone_id].position + Vector3(randf_range(-3, 3), randf_range(0, 3), randf_range(-3, 3))
            word_seed_evolution.plant_seed(word, pos, "concept")
        
        // Manifest chaos words
        for word in chaos_words:
            var pos = zone_scale_system.active_zones[chaos_zone_id].position + Vector3(randf_range(-3, 3), randf_range(0, 3), randf_range(-3, 3))
            word_seed_evolution.plant_seed(word, pos, "concept")

func connect_opposing_words():
    if !word_seed_evolution:
        return
    
    var order_words = []
    var chaos_words = []
    
    // Find opposing concept words
    for word_id in word_seed_evolution.active_seeds:
        var word_text = word_seed_evolution.active_seeds[word_id].text.to_lower()
        
        if word_text in ["order", "structure", "system", "pattern", "discipline"]:
            order_words.append(word_id)
        
        if word_text in ["chaos", "entropy", "freedom", "chance", "spontaneity"]:
            chaos_words.append(word_id)
    
    // Connect opposing concepts
    for order_id in order_words:
        for chaos_id in chaos_words:
            if word_seed_evolution.has_method("connect_words"):
                word_seed_evolution.connect_words(order_id, chaos_id)

func prepare_for_rebirth():
    // Reset some aspects while maintaining core structures
    
    // Clear temporary zones but keep core zones
    if zone_scale_system:
        var zones_to_remove = []
        
        for zone_id in zone_scale_system.active_zones:
            var zone = zone_scale_system.active_zones[zone_id]
            
            // Keep core zones (usually those without custom properties)
            if !zone.has("properties") or !zone.properties.has("force"):
                continue
            
            zones_to_remove.append(zone_id)
        
        // Remove temporary zones
        for zone_id in zones_to_remove:
            zone_scale_system.delete_zone(zone_id)
    
    // Manifest new seed words for next cycle
    manifest_themed_words("unity", 3)
    
    // Create a special rebirth zone
    if zone_scale_system:
        zone_scale_system.create_custom_zone(
            Vector3(0, 5, 0),
            10.0,
            "cosmic",
            "CREATIVE",
            {"rebirth": true, "manifestation_boost": 2.0}
        )

func advance_metanarrative():
    if !metanarrative_enabled:
        return
    
    // Update player influence on metanarrative
    update_player_influence()
    
    // Check current act completion
    var current_act_index = metanarrative.current_act
    if current_act_index >= metanarrative.acts.size():
        return
    
    var current_act = metanarrative.acts[current_act_index]
    
    // Check if act has been active for enough turns
    if !current_act.has("active_turns"):
        current_act.active_turns = 1
    else:
        current_act.active_turns += 1
    
    // Check completion conditions
    if current_act.active_turns >= current_act.required_turns and check_act_completion(current_act):
        // Mark act as completed
        current_act.completed = true
        
        // Add event
        var event = {
            "type": "act_completion",
            "act": current_act.name,
            "turn": current_turn,
            "player_influence": metanarrative.player_influence
        }
        metanarrative.events.append(event)
        
        // Move to next act
        metanarrative.current_act += 1
        
        // Show notification
        if game_controller and game_controller.has_method("show_notification"):
            game_controller.show_notification(
                "Metanarrative Act Complete: " + current_act.name,
                5.0
            )
        
        // Apply act completion effects
        apply_act_completion_effects(current_act)

func check_act_completion(act) -> bool:
    if !act.has("completion_conditions"):
        return true
    
    var condition_type = act.completion_conditions[0]
    var condition_value = act.completion_conditions[1] if act.completion_conditions.size() > 1 else 0
    
    match condition_type:
        "visit_universes_count":
            return player_universe_history.size() >= condition_value
        
        "core_concepts_manifested":
            var manifested_count = 0
            for concept_id in core_concepts:
                var concept = core_concepts[concept_id]
                if concept.universe_manifestations.has(current_universe_id) and concept.universe_manifestations[current_universe_id].word_id != "":
                    manifested_count += 1
            return manifested_count >= condition_value
        
        "crossover_events_count":
            return crossover_events.size() >= condition_value
        
        "alignment_level":
            return calculate_universe_alignment() >= condition_value
        
        "synchronization_level":
            return calculate_story_synchronization() >= condition_value
        
        "core_concepts_evolved":
            return count_evolved_core_concepts() >= condition_value
        
        "all_previous_acts_completed":
            for i in range(metanarrative.current_act):
                if !metanarrative.acts[i].completed:
                    return false
            return true
    
    return false

func apply_act_completion_effects(act):
    // Apply effects based on completed act
    match act.name:
        "The Divergence":
            // Create more access points between universes
            create_additional_access_points(3)
        
        "The Patterns Emerge":
            // Strengthen core concepts
            strengthen_core_concepts()
        
        "The Great Crossroads":
            // Increase crossover chance
            crossover_probability *= 1.5
        
        "The Cosmic Alignment":
            // Align universe properties
            align_universe_properties()
        
        "The Great Convergence":
            // Begin merging some universes
            begin_universe_convergence()
        
        "The Ultimate Reality":
            // Reveal the ultimate reality
            reveal_ultimate_reality()
        
        "Beyond Understanding":
            // Complete the metanarrative cycle
            complete_metanarrative_cycle()

func update_player_influence():
    // Calculate how much the player has influenced the metanarrative
    var base_influence = 0.0
    
    // Influence based on universes visited
    base_influence += min(1.0, player_universe_history.size() / float(universe_count)) * 0.3
    
    // Influence based on crossovers participated in
    var player_crossover_count = 0
    for event in crossover_events:
        if event.elements.has("player_travel"):
            player_crossover_count += 1
    
    base_influence += min(1.0, player_crossover_count / 5.0) * 0.3
    
    // Influence based on words manifested
    if word_seed_evolution and word_seed_evolution.active_seeds:
        var word_count = word_seed_evolution.active_seeds.size()
        base_influence += min(1.0, word_count / 20.0) * 0.2
    
    // Influence based on turn progression
    base_influence += min(1.0, current_turn / 10.0) * 0.2
    
    // Update metanarrative player influence
    metanarrative.player_influence = base_influence * player_story_influence

# ----- CROSSOVER EVENTS -----
func generate_crossover_events():
    // Chance to generate crossover events between universes
    if randf() >= crossover_probability:
        return
    
    // Choose two random universes
    var universe_ids = active_universes.keys()
    if universe_ids.size() < 2:
        return
    
    universe_ids.shuffle()
    var universe1 = universe_ids[0]
    var universe2 = universe_ids[1]
    
    // Determine what elements cross over
    var crossover_elements = []
    
    var possible_elements = ["word", "story_element", "zone_property", "concept", "reality"]
    possible_elements.shuffle()
    
    // Choose 1-3 elements to cross over
    var element_count = 1 + randi() % 3
    for i in range(element_count):
        if i < possible_elements.size():
            crossover_elements.append(possible_elements[i])
    
    // Create the crossover
    create_crossover(universe1, universe2, crossover_elements)

func create_crossover(from_universe: int, to_universe: int, elements: Array):
    if !active_universes.has(from_universe) or !active_universes.has(to_universe):
        return
    
    // Process each crossover element
    for element_type in elements:
        match element_type:
            "word":
                crossover_word(from_universe, to_universe)
            "story_element":
                crossover_story_element(from_universe, to_universe)
            "zone_property":
                crossover_zone_property(from_universe, to_universe)
            "concept":
                crossover_concept(from_universe, to_universe)
            "reality":
                crossover_reality(from_universe, to_universe)
    
    // Record the crossover event
    record_crossover_event(from_universe, to_universe, elements)
    
    // Notify if we're in one of these universes
    if current_universe_id == from_universe or current_universe_id == to_universe:
        if game_controller and game_controller.has_method("show_notification"):
            game_controller.show_notification(
                "Multiverse Crossover Detected!",
                3.0
            )

func crossover_word(from_universe: int, to_universe: int):
    // Copy a word from one universe to another
    if current_universe_id != from_universe or !word_seed_evolution or !word_seed_evolution.active_seeds:
        return
    
    // Choose a random word
    var words = word_seed_evolution.active_seeds.keys()
    if words.size() == 0:
        return
    
    var word_id = words[randi() % words.size()]
    var word_data = word_seed_evolution.active_seeds[word_id]
    
    // Store this word in the target universe's data
    active_universes[to_universe].words[word_id] = {
        "text": word_data.text,
        "position": word_data.position,
        "category": word_data.category,
        "origin_universe": from_universe
    }
    
    // If we're in the target universe, manifest the word
    if current_universe_id == to_universe and word_seed_evolution.has_method("plant_seed"):
        var position = word_data.position + Vector3(randf_range(-5, 5), randf_range(0, 3), randf_range(-5, 5))
        var crossover_word_id = word_seed_evolution.plant_seed(word_data.text, position, word_data.category)
        
        // Apply special crossover effects
        if crossover_word_id != "" and game_controller and game_controller.has_method("create_word_hologram"):
            game_controller.create_word_hologram(crossover_word_id)

func crossover_story_element(from_universe: int, to_universe: int):
    if !universe_stories.has(from_universe) or !universe_stories.has(to_universe):
        return
    
    var from_story = universe_stories[from_universe]
    var to_story = universe_stories[to_universe]
    
    // Choose an element to cross over
    var element_type = randi() % 3
    
    match element_type:
        0: // Theme influence
            to_story.theme = from_story.theme
        
        1: // Character influence
            if randf() < 0.5:
                to_story.protagonist = from_story.protagonist
            else:
                to_story.antagonist = from_story.antagonist
        
        2: // Event influence
            if from_story.events.size() > 0:
                var event = from_story.events[randi() % from_story.events.size()].duplicate()
                event.universe = to_universe
                event.crossover = true
                event.origin_universe = from_universe
                to_story.events.append(event)

func crossover_zone_property(from_universe: int, to_universe: int):
    if !active_universes.has(from_universe) or !active_universes.has(to_universe):
        return
    
    var from_props = active_universes[from_universe].properties
    var to_props = active_universes[to_universe].properties
    
    // Choose a property to cross over
    var properties = ["time_flow_rate", "reality_stability", "evolution_speed", "manifestation_rate", "connection_strength"]
    var property = properties[randi() % properties.size()]
    
    // Transfer the property
    to_props[property] = from_props[property]
    
    // Apply if we're in the target universe
    if current_universe_id == to_universe:
        apply_universe_settings(to_universe)

func crossover_concept(from_universe: int, to_universe: int):
    // Find a concept that exists in the source universe and transfer it
    for concept_id in core_concepts:
        var concept = core_concepts[concept_id]
        
        if concept.universe_manifestations.has(from_universe) and concept.universe_manifestations[from_universe].word_id != "":
            // This concept exists in the source universe
            
            // Make it available in the target universe
            if !concept.universe_manifestations.has(to_universe):
                concept.universe_manifestations[to_universe] = {
                    "word_id": "",
                    "stability": 0.7,
                    "influence": 0.6
                }
            
            // If we're in the target universe, manifest it
            if current_universe_id == to_universe and word_seed_evolution and word_seed_evolution.has_method("plant_seed"):
                var position = Vector3(randf_range(-10, 10), randf_range(0, 5), randf_range(-10, 10))
                var word_id = word_seed_evolution.plant_seed(concept.name, position, "concept")
                
                if word_id != "":
                    concept.universe_manifestations[to_universe].word_id = word_id
                    
                    // Add visual effects
                    if game_controller and game_controller.has_method("create_word_hologram"):
                        game_controller.create_word_hologram(word_id)
            
            // Only do one concept per crossover
            break

func crossover_reality(from_universe: int, to_universe: int):
    if !active_universes.has(from_universe) or !active_universes.has(to_universe):
        return
    
    // Transfer dominant reality
    var from_reality = active_universes[from_universe].dominant_reality
    active_universes[to_universe].dominant_reality = from_reality
    
    // Apply if we're in the target universe
    if current_universe_id == to_universe:
        if game_controller and game_controller.has_method("set_reality"):
            game_controller.set_reality(from_reality)

func record_crossover_event(from_universe: int, to_universe: int, elements: Array):
    var event = {
        "type": "crossover",
        "from_universe": from_universe,
        "to_universe": to_universe,
        "elements": elements,
        "turn": current_turn,
        "time": Time.get_ticks_msec() / 1000.0
    }
    
    // Add to crossover events
    crossover_events.append(event)
    
    // Emit signal
    emit_signal("crossover_occurred", from_universe, to_universe, elements)

# ----- UNIVERSE EVOLUTION -----
func evolve_universes():
    // Make incremental changes to universes each turn
    for universe_id in active_universes:
        var universe = active_universes[universe_id]
        
        // Small random variations in properties
        for prop in universe.properties:
            var variation = randf_range(-0.05, 0.05)
            universe.properties[prop] = clamp(universe.properties[prop] + variation, 0.1, 2.0)
        
        // Chance to change dominant reality
        if randf() < 0.1:
            var realities = ["physical", "digital", "astral"]
            var current_index = realities.find(universe.dominant_reality)
            var new_index = (current_index + 1 + randi() % 2) % realities.size()
            universe.dominant_reality = realities[new_index]
    
    // Chance to create a new universe
    if universe_count < 9 and randf() < 0.15:
        var new_universe_id = universe_count
        create_universe(new_universe_id)
        universe_count += 1
        
        // Create access points to the new universe
        create_access_points_for_universe(new_universe_id)

func create_access_points_for_universe(universe_id: int):
    if !active_universes.has(universe_id):
        return
    
    // Create 1-3 access points to existing universes
    var access_count = 1 + randi() % 3
    var existing_universes = active_universes.keys()
    existing_universes.erase(universe_id)
    
    for i in range(min(access_count, existing_universes.size())):
        var target_id = existing_universes[i]
        
        // Generate a unique ID for this access point
        var access_id = "access_" + str(universe_id) + "_to_" + str(target_id)
        
        // Create access point data
        universe_access_points[access_id] = {
            "id": access_id,
            "from_universe": universe_id,
            "to_universe": target_id,
            "position": Vector3(10 + universe_id * 5, 0, 10 + target_id * 5),  // Placeholder position
            "stability": 0.7 + randf() * 0.3,
            "energy_cost": 25.0 + randf() * 25.0,
            "active": true
        }
        
        // Create reverse access point
        var reverse_id = "access_" + str(target_id) + "_to_" + str(universe_id)
        universe_access_points[reverse_id] = {
            "id": reverse_id,
            "from_universe": target_id,
            "to_universe": universe_id,
            "position": Vector3(10 + target_id * 5, 0, 10 + universe_id * 5),  // Placeholder position
            "stability": 0.7 + randf() * 0.3,
            "energy_cost": 25.0 + randf() * 25.0,
            "active": true
        }

func create_additional_access_points(count: int):
    var universe_ids = active_universes.keys()
    if universe_ids.size() < 2:
        return
    
    for i in range(count):
        // Choose two random universes
        universe_ids.shuffle()
        var universe1 = universe_ids[0]
        var universe2 = universe_ids[1]
        
        // Generate a unique ID for this access point
        var access_id = "access_" + str(universe1) + "_to_" + str(universe2) + "_" + str(i)
        
        // Create access point data
        universe_access_points[access_id] = {
            "id": access_id,
            "from_universe": universe1,
            "to_universe": universe2,
            "position": Vector3(randf_range(-20, 20), randf_range(0, 10), randf_range(-20, 20)),
            "stability": 0.7 + randf() * 0.3,
            "energy_cost": 25.0 + randf() * 25.0,
            "active": true
        }

func evolve_core_concepts():
    // Evolve concepts across universes
    for concept_id in core_concepts:
        var concept = core_concepts[concept_id]
        
        for universe_id in concept.universe_manifestations:
            var manifestation = concept.universe_manifestations[universe_id]
            
            // Skip if not manifested yet
            if manifestation.word_id == "":
                continue
            
            // Chance to increase influence
            if randf() < 0.2:
                manifestation.influence = min(1.0, manifestation.influence + 0.1)
            
            // Apply influence to universe properties
            if active_universes.has(universe_id):
                var universe = active_universes[universe_id]
                
                // Core concepts stabilize reality
                universe.properties.reality_stability = lerp(
                    universe.properties.reality_stability,
                    1.0,
                    manifestation.influence * 0.1
                )

func update_universe_properties():
    // Apply turn-based changes to universe properties
    for universe_id in active_universes:
        var universe = active_universes[universe_id]
        
        // Adjust properties based on age progression
        var age_factor = float(current_age) / max(1, cosmic_ages.size() - 1)
        
        // As ages progress:
        // - Time flow becomes more unified
        // - Reality stability increases
        // - Evolution becomes more directed
        universe.properties.time_flow_rate = lerp(universe.properties.time_flow_rate, 1.0, age_factor * 0.1)
        universe.properties.reality_stability = lerp(universe.properties.reality_stability, 1.0, age_factor * 0.1)
        
        // Apply story influence
        if universe_stories.has(universe_id):
            var story = universe_stories[universe_id]
            
            // Story stage affects properties
            match story.current_stage:
                "rising_action":
                    // Increasing evolution and manifestation
                    universe.properties.evolution_speed *= 1.01
                    universe.properties.manifestation_rate *= 1.01
                
                "climax":
                    // Peak activity
                    universe.properties.evolution_speed = max(universe.properties.evolution_speed, 1.2)
                    universe.properties.manifestation_rate = max(universe.properties.manifestation_rate, 1.2)
                
                "falling_action":
                    // Decreasing activity
                    universe.properties.evolution_speed *= 0.99
                    universe.properties.manifestation_rate *= 0.99
                
                "resolution":
                    // Stabilizing
                    universe.properties.reality_stability = max(universe.properties.reality_stability, 0.9)
        
        // Apply to current universe if needed
        if universe_id == current_universe_id:
            apply_universe_settings(universe_id)

# ----- METANARRATIVE EFFECTS -----
func strengthen_core_concepts():
    // Strengthen the manifestation of core concepts
    for concept_id in core_concepts:
        var concept = core_concepts[concept_id]
        
        for universe_id in concept.universe_manifestations:
            var manifestation = concept.universe_manifestations[universe_id]
            
            // Increase stability and influence
            manifestation.stability = min(1.0, manifestation.stability + 0.2)
            manifestation.influence = min(1.0, manifestation.influence + 0.2)
            
            // If we're in this universe and the concept is manifested
            if universe_id == current_universe_id and manifestation.word_id != "" and word_seed_evolution:
                // Strengthen the word
                if word_seed_evolution.has_method("_evolve_seed"):
                    word_seed_evolution._evolve_seed(manifestation.word_id)
                
                // Add visual effects
                if game_controller and game_controller.has_method("create_word_hologram"):
                    game_controller.create_word_hologram(manifestation.word_id)

func align_universe_properties():
    // Align certain properties across universes
    var avg_time_flow = 0.0
    var avg_evolution_speed = 0.0
    
    // Calculate averages
    for universe_id in active_universes:
        var universe = active_universes[universe_id]
        avg_time_flow += universe.properties.time_flow_rate
        avg_evolution_speed += universe.properties.evolution_speed
    
    avg_time_flow /= active_universes.size()
    avg_evolution_speed /= active_universes.size()
    
    // Move properties toward average
    for universe_id in active_universes:
        var universe = active_universes[universe_id]
        universe.properties.time_flow_rate = lerp(universe.properties.time_flow_rate, avg_time_flow, 0.3)
        universe.properties.evolution_speed = lerp(universe.properties.evolution_speed, avg_evolution_speed, 0.3)
    
    // Apply to current universe
    apply_universe_settings(current_universe_id)

func begin_universe_convergence():
    // Start process of universe convergence
    // Increase connection strength between universes
    for access_id in universe_access_points:
        var access_point = universe_access_points[access_id]
        
        // Reduce energy cost
        access_point.energy_cost *= 0.7
        
        // Increase stability
        access_point.stability = min(1.0, access_point.stability + 0.2)
    
    // Increase story synchronization
    story_synchronization *= 1.5
    
    // Manifest convergence-themed words
    if current_universe_id >= 0 and word_seed_evolution:
        var convergence_words = ["convergence", "unification", "merge", "synthesis", "reunion"]
        
        for word in convergence_words:
            var pos = Vector3(randf_range(-10, 10), randf_range(1, 5), randf_range(-10, 10))
            word_seed_evolution.plant_seed(word, pos, "concept")

func reveal_ultimate_reality():
    // Create a special zone representing the ultimate reality
    if zone_scale_system:
        var ultimate_zone_id = zone_scale_system.create_custom_zone(
            Vector3(0, 20, 0),
            15.0,
            "cosmic",
            "STABLE",
            {
                "ultimate_reality": true,
                "time_dilation": 0.1,  // Time nearly stops
                "evolution_boost": 5.0,
                "manifestation_boost": 5.0
            }
        )
        
        // Manifest the ultimate concepts
        if word_seed_evolution:
            var ultimate_concepts = ["absolute", "eternal", "infinite", "one", "all", "ultimate", "perfect"]
            
            for concept in ultimate_concepts:
                var pos = zone_scale_system.active_zones[ultimate_zone_id].position + Vector3(randf_range(-10, 10), randf_range(0, 5), randf_range(-10, 10))
                var word_id = word_seed_evolution.plant_seed(concept, pos, "concept")
                
                if word_id != "" and game_controller and game_controller.has_method("create_word_hologram"):
                    game_controller.create_word_hologram(word_id)

func complete_metanarrative_cycle():
    // Reset some aspects while preserving progress
    current_turn = 1
    
    // Start a new age if not at max
    if current_age < cosmic_ages.size() - 1:
        current_age += 1
    
    // Reset turn timer
    turn_time_remaining = evolution_turn_duration
    
    // Create a new metanarrative cycle
    initialize_metanarrative()
    
    // Show epic notification
    if game_controller and game_controller.has_method("show_notification"):
        game_controller.show_notification(
            "The Cosmic Cycle Begins Anew - Age of " + cosmic_ages[current_age],
            10.0
        )

# ----- HELPER FUNCTIONS -----
func calculate_universe_alignment() -> float:
    // Calculate how aligned universes are in terms of properties
    if active_universes.size() < 2:
        return 1.0
    
    var total_deviation = 0.0
    var prop_count = 0
    
    // For each property, calculate average deviation
    var properties = ["time_flow_rate", "reality_stability", "evolution_speed", "manifestation_rate", "connection_strength"]
    
    for prop in properties:
        var values = []
        
        for universe_id in active_universes:
            if active_universes[universe_id].properties.has(prop):
                values.append(active_universes[universe_id].properties[prop])
        
        if values.size() > 1:
            // Calculate average
            var avg = 0.0
            for val in values:
                avg += val
            avg /= values.size()
            
            // Calculate average deviation
            var deviation = 0.0
            for val in values:
                deviation += abs(val - avg)
            deviation /= values.size()
            
            // Add to total
            total_deviation += deviation
            prop_count += 1
    
    if prop_count == 0:
        return 1.0
    
    // Calculate average deviation across all properties
    var avg_deviation = total_deviation / prop_count
    
    // Convert to alignment (0-1, where 1 is perfect alignment)
    return max(0.0, 1.0 - avg_deviation)

func calculate_story_synchronization() -> float:
    // Calculate how synchronized stories are across universes
    if universe_stories.size() < 2:
        return 1.0
    
    var same_segment_count = 0
    var total_comparisons = 0
    
    // Compare segments across universes
    var universe_ids = universe_stories.keys()
    
    for i in range(universe_ids.size()):
        for j in range(i + 1, universe_ids.size()):
            var story1 = universe_stories[universe_ids[i]]
            var story2 = universe_stories[universe_ids[j]]
            
            if story1.current_segment == story2.current_segment:
                same_segment_count += 1
            
            total_comparisons += 1
    
    if total_comparisons == 0:
        return 1.0
    
    return float(same_segment_count) / total_comparisons

func count_evolved_core_concepts() -> int:
    var evolved_count = 0
    
    // Count evolved core concepts
    for concept_id in core_concepts:
        if core_concepts[concept_id].is_constant:
            // Check if evolved in multiple universes
            var universe_count = 0
            
            for universe_id in core_concepts[concept_id].universe_manifestations:
                if core_concepts[concept_id].universe_manifestations[universe_id].word_id != "":
                    universe_count += 1
            
            if universe_count >= 3:
                evolved_count += 1
    
    return evolved_count

# ----- EVENT HANDLERS -----
func _on_player_moved(distance, velocity):
    // Update multiverse state based on player movement
    
    // Movement can trigger crossover events
    if distance > 2.0 and randf() < 0.01 * distance:
        // Chance for random crossover based on movement
        var universe_ids = active_universes.keys()
        if universe_ids.size() >= 2:
            universe_ids.erase(current_universe_id)
            var target_universe = universe_ids[randi() % universe_ids.size()]
            create_crossover(current_universe_id, target_universe, ["word"])
    
    // Movement in high-velocity can cause reality shifts
    if velocity.length() > 15.0 and randf() < 0.05:
        // Chance to trigger reality shift near universe boundaries
        check_for_reality_boundary()

func check_for_reality_boundary():
    // Check if player is near a universe boundary
    for access_id in universe_access_points:
        var access_point = universe_access_points[access_id]
        
        // Only check access points from current universe
        if access_point.from_universe != current_universe_id:
            continue
        
        var distance = player_controller.global_position.distance_to(access_point.position)
        
        // If near access point, chance of reality distortion
        if distance < 5.0 and randf() < access_point.stability:
            // Trigger reality effect
            if game_controller and game_controller.has_method("show_notification"):
                game_controller.show_notification(
                    "Reality boundary detected - " + active_universes[access_point.to_universe].name + " Universe",
                    2.0
                )
            
            // Create visual distortion
            if game_controller and game_controller.has_method("create_reality_distortion"):
                game_controller.create_reality_distortion(access_point.position, access_point.to_universe)

# ----- PUBLIC API -----
func get_current_universe_id() -> int:
    return current_universe_id

func get_current_universe_name() -> String:
    if active_universes.has(current_universe_id):
        return active_universes[current_universe_id].name
    return "Unknown Universe"

func get_current_turn() -> int:
    return current_turn

func get_current_age() -> String:
    if current_age < cosmic_ages.size():
        return cosmic_ages[current_age]
    return "Unknown Age"

func get_universe_count() -> int:
    return active_universes.size()

func get_metanarrative_progress() -> float:
    if !metanarrative_enabled or metanarrative.acts.size() == 0:
        return 0.0
    
    return float(metanarrative.current_act) / metanarrative.acts.size()

func get_accessible_universes() -> Array:
    var accessible = []
    
    for access_id in universe_access_points:
        var access_point = universe_access_points[access_id]
        
        if access_point.from_universe == current_universe_id and access_point.active:
            accessible.append(access_point.to_universe)
    
    return accessible

func get_universe_stories() -> Dictionary:
    return universe_stories

func get_current_story_segment() -> String:
    if universe_stories.has(current_universe_id):
        return universe_stories[current_universe_id].current_segment
    return ""

func get_multiverse_state() -> Dictionary:
    return {
        "current_universe": current_universe_id,
        "universe_count": active_universes.size(),
        "current_turn": current_turn,
        "current_age": cosmic_ages[current_age],
        "crossover_events": crossover_events.size(),
        "metanarrative_progress": get_metanarrative_progress(),
        "universe_alignment": calculate_universe_alignment(),
        "story_synchronization": calculate_story_synchronization()
    }

func set_references(game_ctrl, time_prog, word_seed, zone_scale, player):
    game_controller = game_ctrl
    time_progression_system = time_prog
    word_seed_evolution = word_seed
    zone_scale_system = zone_scale
    player_controller = player