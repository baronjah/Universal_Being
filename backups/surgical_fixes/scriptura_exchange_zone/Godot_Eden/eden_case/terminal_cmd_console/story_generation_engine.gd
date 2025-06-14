extends Node
class_name StoryGenerationEngine

"""
Story Generation Engine
----------------------
Creates dynamic game narratives based on the user's personal data repository.
Uses a combination of personal history, preferences, and AI-generated content.

Features:
- Dynamic story generation based on personal data inputs
- Multi-dimensional narrative paths (corresponding to the 12-turn system)
- Theme detection and emotional analysis
- Procedural character and plot generation
- Integration with word visualization system
- Support for branching and non-linear storytelling
- Memory-based narrative callbacks (references to past choices/actions)
"""

# Story structure elements
enum StoryStage {
    SETUP,
    CONFLICT,
    RISING_ACTION,
    CLIMAX,
    FALLING_ACTION,
    RESOLUTION
}

enum StoryTone {
    HOPEFUL,
    DARK,
    MYSTERIOUS,
    HUMOROUS,
    DRAMATIC,
    REFLECTIVE,
    SURREAL,
    NEUTRAL,
    PERSONALIZED
}

enum StoryTheme {
    IDENTITY,
    TRANSFORMATION,
    MYSTERY,
    ADVENTURE,
    CONFLICT,
    CONNECTION,
    DISCOVERY,
    REDEMPTION,
    CREATION,
    DESTRUCTION,
    BALANCE,
    TRANSCENDENCE
}

enum CharacterRole {
    PROTAGONIST,
    ANTAGONIST,
    MENTOR,
    ALLY,
    SHADOW,
    THRESHOLD_GUARDIAN,
    SHAPESHIFTER,
    TRICKSTER,
    MESSENGER
}

enum DimensionalInfluence {
    REALITY,      # 1D: Point - Basic factual data
    LINEAR,       # 2D: Line - Direct cause/effect
    SPATIAL,      # 3D: Space - Environmental context
    TEMPORAL,     # 4D: Time - Historical progression
    CONSCIOUS,    # 5D: Consciousness - Self-awareness
    CONNECTION,   # 6D: Connection - Relationships
    CREATION,     # 7D: Creation - Creative expression
    NETWORK,      # 8D: Network - Community elements
    HARMONY,      # 9D: Harmony - Balance between forces
    UNITY,        # 10D: Unity - Wholeness and integration
    TRANSCENDENT, # 11D: Transcendence - Beyond limitations
    BEYOND        # 12D: Beyond - Ineffable elements
}

class StoryCharacter:
    var id: String
    var name: String
    var description: String
    var role: int  # CharacterRole
    var traits = []
    var backstory: String
    var goals = []
    var connections = {}  # Other character IDs -> relationship
    var visual_keywords = []  # Words that define visual appearance
    var voice_style: String
    var dimensional_alignment: int  # DimensionalInfluence
    var personal_data_sources = []  # Sources from user data that influenced this character
    var metadata = {}
    
    func _init(p_id: String, p_name: String, p_role: int):
        id = p_id
        name = p_name
        role = p_role
    
    func add_connection(char_id: String, relationship: String):
        connections[char_id] = relationship
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "description": description,
            "role": role,
            "traits": traits,
            "backstory": backstory,
            "goals": goals,
            "connections": connections,
            "visual_keywords": visual_keywords,
            "voice_style": voice_style,
            "dimensional_alignment": dimensional_alignment
        }

class StoryLocation:
    var id: String
    var name: String
    var description: String
    var mood: String
    var elements = []  # Key features of the location
    var connected_locations = []  # IDs of connected locations
    var visual_keywords = []
    var dimensional_influence: int  # DimensionalInfluence
    var time_properties = {}  # How time behaves in this location
    var metadata = {}
    
    func _init(p_id: String, p_name: String):
        id = p_id
        name = p_name
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "description": description,
            "mood": mood,
            "elements": elements,
            "connected_locations": connected_locations,
            "visual_keywords": visual_keywords,
            "dimensional_influence": dimensional_influence,
            "time_properties": time_properties
        }

class StoryEvent:
    var id: String
    var title: String
    var description: String
    var stage: int  # StoryStage
    var characters_involved = []  # Character IDs
    var location_id: String
    var consequences = []  # Resulting events or state changes
    var choices = []  # Possible player choices
    var requirements = {}  # Conditions for this event to trigger
    var dimensional_influence: int  # DimensionalInfluence
    var visual_representation: String  # How this might be visualized
    var metadata = {}
    
    func _init(p_id: String, p_title: String, p_stage: int):
        id = p_id
        title = p_title
        stage = p_stage
    
    func add_choice(choice_text: String, next_event_id: String):
        choices.append({
            "text": choice_text,
            "next_event_id": next_event_id
        })
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "title": title,
            "description": description,
            "stage": stage,
            "characters_involved": characters_involved,
            "location_id": location_id,
            "consequences": consequences,
            "choices": choices,
            "requirements": requirements,
            "dimensional_influence": dimensional_influence,
            "visual_representation": visual_representation
        }

class StoryArc:
    var id: String
    var title: String
    var theme: int  # StoryTheme
    var tone: int  # StoryTone
    var events = []  # Event IDs in order
    var branching_paths = {}  # Decision points -> possible next event IDs
    var characters = {}  # Character IDs -> StoryCharacter
    var locations = {}  # Location IDs -> StoryLocation
    var primary_dimension: int  # DimensionalInfluence
    var metadata = {}
    
    func _init(p_id: String, p_title: String, p_theme: int, p_tone: int):
        id = p_id
        title = p_title
        theme = p_theme
        tone = p_tone
    
    func add_character(character: StoryCharacter):
        characters[character.id] = character
    
    func add_location(location: StoryLocation):
        locations[location.id] = location
    
    func add_event(event: StoryEvent):
        events.append(event.id)
    
    func to_dict() -> Dictionary:
        var char_dicts = {}
        for char_id in characters:
            char_dicts[char_id] = characters[char_id].to_dict()
        
        var loc_dicts = {}
        for loc_id in locations:
            loc_dicts[loc_id] = locations[loc_id].to_dict()
        
        return {
            "id": id,
            "title": title,
            "theme": theme,
            "tone": tone,
            "events": events,
            "branching_paths": branching_paths,
            "characters": char_dicts,
            "locations": loc_dicts,
            "primary_dimension": primary_dimension
        }

class Story:
    var id: String
    var title: String
    var description: String
    var arcs = {}  # Arc IDs -> StoryArc
    var all_events = {}  # Event IDs -> StoryEvent
    var current_event_id: String
    var history = []  # Past event IDs in order experienced
    var player_choices = {}  # Event ID -> choice made
    var created_at: int
    var last_updated: int
    var dimensional_composition = {}  # Dimension -> influence weight (0-100)
    var metadata = {}
    
    func _init(p_id: String, p_title: String):
        id = p_id
        title = p_title
        created_at = OS.get_unix_time()
        last_updated = created_at
    
    func add_arc(arc: StoryArc):
        arcs[arc.id] = arc
        
        # Also add all events from this arc
        for event_id in arc.events:
            # Get the event from the arc's events
            var event = null
            for evt in arc.events:
                if evt.id == event_id:
                    event = evt
                    break
            
            if event:
                all_events[event_id] = event
    
    func get_current_event() -> StoryEvent:
        if all_events.has(current_event_id):
            return all_events[current_event_id]
        return null
    
    func make_choice(choice_index: int) -> String:
        var current_event = get_current_event()
        if not current_event or choice_index >= current_event.choices.size():
            return ""
        
        var choice = current_event.choices[choice_index]
        player_choices[current_event_id] = choice_index
        
        # Add to history
        history.append(current_event_id)
        
        # Update current event
        current_event_id = choice.next_event_id
        last_updated = OS.get_unix_time()
        
        return current_event_id
    
    func to_dict() -> Dictionary:
        var arc_dicts = {}
        for arc_id in arcs:
            arc_dicts[arc_id] = arcs[arc_id].to_dict()
            
        var event_dicts = {}
        for event_id in all_events:
            event_dicts[event_id] = all_events[event_id].to_dict()
            
        return {
            "id": id,
            "title": title,
            "description": description,
            "arcs": arc_dicts,
            "all_events": event_dicts,
            "current_event_id": current_event_id,
            "history": history,
            "player_choices": player_choices,
            "created_at": created_at,
            "last_updated": last_updated,
            "dimensional_composition": dimensional_composition
        }

# Personal data storage
class PersonalDataRepository:
    var word_frequency = {}  # Word -> count
    var themes = {}  # Theme -> strength (0-100)
    var preferences = {}  # Category -> preferences
    var temporal_patterns = {}  # Time pattern -> activity
    var emotional_data = {}  # Content -> emotional response
    var relationship_data = {}  # Person/entity -> relationship data
    var creative_expressions = []  # User's creative outputs
    var activity_history = []  # Historical activities
    var metadata = {}
    
    func add_word(word: String, count: int = 1):
        if word_frequency.has(word):
            word_frequency[word] += count
        else:
            word_frequency[word] = count
    
    func get_top_words(limit: int = 20) -> Array:
        var words = []
        for word in word_frequency:
            words.append({"word": word, "count": word_frequency[word]})
        
        # Sort by frequency
        words.sort_custom(self, "_sort_by_count")
        
        # Limit results
        if words.size() > limit:
            words = words.slice(0, limit - 1)
        
        return words
    
    func _sort_by_count(a, b):
        return a.count > b.count
    
    func add_theme(theme: int, strength: int):
        themes[theme] = strength
    
    func get_dominant_themes(limit: int = 3) -> Array:
        var theme_list = []
        for theme in themes:
            theme_list.append({"theme": theme, "strength": themes[theme]})
        
        # Sort by strength
        theme_list.sort_custom(self, "_sort_by_strength")
        
        # Limit results
        if theme_list.size() > limit:
            theme_list = theme_list.slice(0, limit - 1)
        
        return theme_list
    
    func _sort_by_strength(a, b):
        return a.strength > b.strength
    
    func to_dict() -> Dictionary:
        return {
            "word_frequency": word_frequency,
            "themes": themes,
            "preferences": preferences,
            "temporal_patterns": temporal_patterns,
            "emotional_data": emotional_data,
            "relationship_data": relationship_data,
            "creative_expressions": creative_expressions,
            "activity_history": activity_history
        }

# Data analyzers
class ThemeAnalyzer:
    func analyze_text(text: String) -> Dictionary:
        var results = {}
        var words = text.split(" ", false)
        
        # Super simplified theme detection example
        var theme_keywords = {
            StoryTheme.IDENTITY: ["identity", "self", "who", "am", "I", "me", "myself", "personal"],
            StoryTheme.TRANSFORMATION: ["change", "transform", "become", "evolve", "growth", "development"],
            StoryTheme.MYSTERY: ["mystery", "unknown", "secret", "hidden", "reveal", "discover", "clue"],
            StoryTheme.ADVENTURE: ["adventure", "journey", "quest", "explore", "discover", "expedition"],
            StoryTheme.CONFLICT: ["conflict", "battle", "fight", "struggle", "war", "opposition", "clash"],
            StoryTheme.CONNECTION: ["connection", "relationship", "bond", "link", "together", "connect"],
            StoryTheme.DISCOVERY: ["discovery", "find", "learn", "uncover", "reveal", "insight"],
            StoryTheme.REDEMPTION: ["redemption", "forgive", "atone", "sorry", "amends", "restore"],
            StoryTheme.CREATION: ["creation", "make", "build", "create", "craft", "design", "invent"],
            StoryTheme.DESTRUCTION: ["destruction", "destroy", "ruin", "demolish", "end", "collapse"],
            StoryTheme.BALANCE: ["balance", "harmony", "equilibrium", "center", "stabilize", "middle"],
            StoryTheme.TRANSCENDENCE: ["transcend", "beyond", "higher", "elevate", "surpass", "exceed"]
        }
        
        # Count theme keywords
        var theme_counts = {}
        for theme in theme_keywords:
            theme_counts[theme] = 0
        
        for word in words:
            var lower_word = word.to_lower()
            for theme in theme_keywords:
                if theme_keywords[theme].has(lower_word):
                    theme_counts[theme] += 1
        
        # Calculate percentages
        var total_theme_words = 0
        for theme in theme_counts:
            total_theme_words += theme_counts[theme]
        
        if total_theme_words > 0:
            for theme in theme_counts:
                results[theme] = (theme_counts[theme] * 100) / total_theme_words
        
        return results
    
    func detect_dominant_theme(themes: Dictionary) -> int:
        var max_theme = StoryTheme.IDENTITY
        var max_value = 0
        
        for theme in themes:
            if themes[theme] > max_value:
                max_value = themes[theme]
                max_theme = theme
        
        return max_theme

class EmotionalAnalyzer:
    func analyze_text(text: String) -> Dictionary:
        var results = {}
        
        # Simplified emotional analysis
        var emotion_keywords = {
            "joy": ["happy", "joy", "delight", "excited", "glad", "pleased"],
            "sadness": ["sad", "unhappy", "depressed", "gloomy", "heartbroken"],
            "anger": ["angry", "mad", "furious", "rage", "outraged", "annoyed"],
            "fear": ["afraid", "scared", "terrified", "anxious", "worried"],
            "surprise": ["surprised", "amazed", "astonished", "shocked", "startled"],
            "disgust": ["disgusted", "revolted", "repulsed", "abhorred"],
            "trust": ["trust", "belief", "faith", "confidence", "reliance"],
            "anticipation": ["anticipate", "expect", "look forward", "awaiting"]
        }
        
        # Count emotion keywords
        var emotion_counts = {}
        for emotion in emotion_keywords:
            emotion_counts[emotion] = 0
        
        # Simplified counting for demo
        for emotion in emotion_keywords:
            for keyword in emotion_keywords[emotion]:
                if text.find(keyword) != -1:
                    emotion_counts[emotion] += 1
        
        # Calculate intensity (simplified)
        for emotion in emotion_counts:
            results[emotion] = min(100, emotion_counts[emotion] * 20)
        
        return results
    
    func determine_tone(emotions: Dictionary) -> int:
        # Simplistic tone determination
        if emotions.get("joy", 0) > 70:
            return StoryTone.HOPEFUL
        elif emotions.get("sadness", 0) > 70 or emotions.get("fear", 0) > 70:
            return StoryTone.DARK
        elif emotions.get("surprise", 0) > 70:
            return StoryTone.MYSTERIOUS
        elif emotions.get("trust", 0) > 70:
            return StoryTone.REFLECTIVE
        
        # Default
        return StoryTone.NEUTRAL

# Main engine variables
var _data_repository: PersonalDataRepository
var _theme_analyzer: ThemeAnalyzer
var _emotional_analyzer: EmotionalAnalyzer
var _current_stories = {}  # ID -> Story
var _story_templates = {}  # ID -> Template dict
var _character_templates = {}  # ID -> Template dict
var _location_templates = {}  # ID -> Template dict

var _memory_system = null
var _word_visualizer = null
var _dimensional_system = null
var _api_integrator = null

var _config = {
    "story_word_limit": 5000,
    "character_depth": 3,  # 1-5 scale
    "narrative_complexity": 3,  # 1-5 scale
    "memory_influence": 0.7,  # 0-1 scale
    "enable_ai_generation": true,
    "current_dimension": 3,  # Current dimensional influence
    "language": "en",
    "personal_data_path": "user://story_data/"
}

# Signals
signal story_created(story_id, title)
signal story_updated(story_id)
signal story_event_changed(story_id, event_id)
signal story_choice_made(story_id, event_id, choice_index)
signal character_created(story_id, character_id)
signal data_imported(source, count)

func _ready():
    _data_repository = PersonalDataRepository.new()
    _theme_analyzer = ThemeAnalyzer.new()
    _emotional_analyzer = EmotionalAnalyzer.new()
    
    # Initialize
    _load_templates()
    _load_personal_data()

func initialize(memory_system = null, word_visualizer = null, dimensional_system = null, api_integrator = null):
    _memory_system = memory_system
    _word_visualizer = word_visualizer
    _dimensional_system = dimensional_system
    _api_integrator = api_integrator
    
    print("Story Generation Engine initialized")

# Core functions
func create_story(title: String, base_theme: int = -1, base_tone: int = -1) -> String:
    var story_id = generate_unique_id()
    var story = Story.new(story_id, title)
    
    # Generate description
    story.description = "A tale of " + get_theme_name(base_theme if base_theme >= 0 else determine_personal_theme())
    
    # Set dimensional composition based on current dimension
    var current_dim = _config.current_dimension
    story.dimensional_composition = generate_dimensional_composition(current_dim)
    
    # Determine theme and tone if not specified
    if base_theme < 0:
        base_theme = determine_personal_theme()
    
    if base_tone < 0:
        base_tone = determine_personal_tone()
    
    # Generate arcs
    var arc = generate_story_arc(story_id + "_arc_1", "Main Arc", base_theme, base_tone)
    story.add_arc(arc)
    
    # Set initial event
    if arc.events.size() > 0:
        story.current_event_id = arc.events[0]
    
    # Store the story
    _current_stories[story_id] = story
    
    emit_signal("story_created", story_id, title)
    
    return story_id

func determine_personal_theme() -> int:
    # Get dominant themes from personal data
    var themes = _data_repository.get_dominant_themes()
    if themes.size() > 0:
        return themes[0].theme
    
    # Default
    return StoryTheme.ADVENTURE

func determine_personal_tone() -> int:
    # Simplified - in real implementation, would analyze emotional data
    return StoryTone.PERSONALIZED

func generate_dimensional_composition(primary_dimension: int) -> Dictionary:
    var composition = {}
    
    # Set the primary dimension
    composition[primary_dimension] = 60 + randi() % 30  # 60-89%
    
    # Set adjacent dimensions
    if primary_dimension > 1:
        composition[primary_dimension - 1] = 10 + randi() % 20  # 10-29%
    
    if primary_dimension < 12:
        composition[primary_dimension + 1] = 10 + randi() % 20  # 10-29%
    
    # Add one random distant dimension for complexity
    var distant_dim = (primary_dimension + 3 + randi() % 5) % 12 + 1
    composition[distant_dim] = 5 + randi() % 10  # 5-14%
    
    return composition

func generate_story_arc(arc_id: String, title: String, theme: int, tone: int) -> StoryArc:
    var arc = StoryArc.new(arc_id, title, theme, tone)
    
    # Determine primary dimension based on theme
    var primary_dimension = theme_to_dimension(theme)
    arc.primary_dimension = primary_dimension
    
    # Generate characters
    var protagonist = generate_character(arc_id + "_char_1", "Protagonist", CharacterRole.PROTAGONIST, primary_dimension)
    var antagonist = generate_character(arc_id + "_char_2", "Antagonist", CharacterRole.ANTAGONIST, primary_dimension)
    var mentor = generate_character(arc_id + "_char_3", "Mentor", CharacterRole.MENTOR, primary_dimension)
    
    arc.add_character(protagonist)
    arc.add_character(antagonist)
    arc.add_character(mentor)
    
    # Connect characters
    protagonist.add_connection(antagonist.id, "opposition")
    protagonist.add_connection(mentor.id, "guidance")
    antagonist.add_connection(protagonist.id, "target")
    mentor.add_connection(protagonist.id, "pupil")
    
    # Generate locations
    var main_location = generate_location(arc_id + "_loc_1", "Main Setting", primary_dimension)
    var secondary_location = generate_location(arc_id + "_loc_2", "Secondary Setting", primary_dimension)
    
    arc.add_location(main_location)
    arc.add_location(secondary_location)
    
    # Connect locations
    main_location.connected_locations.append(secondary_location.id)
    secondary_location.connected_locations.append(main_location.id)
    
    # Generate events
    var events = []
    
    # Opening event
    var setup_event = generate_event(arc_id + "_evt_1", "Beginning", StoryStage.SETUP)
    setup_event.location_id = main_location.id
    setup_event.characters_involved = [protagonist.id, mentor.id]
    setup_event.dimensional_influence = primary_dimension
    
    # Add choices
    setup_event.add_choice("Accept the call to adventure", arc_id + "_evt_2")
    setup_event.add_choice("Reluctantly follow the path", arc_id + "_evt_2")
    
    events.append(setup_event)
    
    # Middle event - conflict
    var conflict_event = generate_event(arc_id + "_evt_2", "Confrontation", StoryStage.CONFLICT)
    conflict_event.location_id = secondary_location.id
    conflict_event.characters_involved = [protagonist.id, antagonist.id]
    conflict_event.dimensional_influence = primary_dimension
    
    # Add choices
    conflict_event.add_choice("Face the challenge directly", arc_id + "_evt_3")
    conflict_event.add_choice("Find an alternative approach", arc_id + "_evt_3")
    
    events.append(conflict_event)
    
    # Resolution event
    var resolution_event = generate_event(arc_id + "_evt_3", "Resolution", StoryStage.RESOLUTION)
    resolution_event.location_id = main_location.id
    resolution_event.characters_involved = [protagonist.id, antagonist.id, mentor.id]
    resolution_event.dimensional_influence = primary_dimension
    
    # Add choices
    resolution_event.add_choice("Complete the journey", arc_id + "_evt_1")  # Loop back for demo
    resolution_event.add_choice("Start a new chapter", arc_id + "_evt_1")  # Loop back for demo
    
    events.append(resolution_event)
    
    # Add events to arc
    for event in events:
        arc.add_event(event)
    
    return arc

func generate_character(id: String, base_name: String, role: int, dimension: int) -> StoryCharacter:
    # In a real implementation, we would use templates and personal data
    # For now, we'll create basic characters
    
    var name = base_name
    if _character_templates.size() > 0:
        var template = _character_templates.values()[randi() % _character_templates.size()]
        name = template.get("name", base_name)
    
    var character = StoryCharacter.new(id, name, role)
    
    # Basic character description based on role
    match role:
        CharacterRole.PROTAGONIST:
            character.description = "The main character of the story, seeking to achieve their goals and overcome challenges."
            character.traits = ["determined", "resourceful"]
            character.goals = ["succeed", "overcome", "achieve"]
        CharacterRole.ANTAGONIST:
            character.description = "The opposing force that creates conflict for the protagonist."
            character.traits = ["ambitious", "formidable"]
            character.goals = ["obtain", "prevent", "control"]
        CharacterRole.MENTOR:
            character.description = "A guide who helps the protagonist with wisdom and support."
            character.traits = ["wise", "experienced"]
            character.goals = ["teach", "guide", "protect"]
        _:
            character.description = "A character in the story."
            character.traits = ["interesting", "complex"]
            character.goals = ["survive", "thrive"]
    
    # Set dimensional alignment
    character.dimensional_alignment = dimension
    
    # Visual keywords based on role and dimension
    character.visual_keywords = generate_visual_keywords_for_character(role, dimension)
    
    emit_signal("character_created", id.split("_")[0], id)
    
    return character

func generate_visual_keywords_for_character(role: int, dimension: int) -> Array:
    var keywords = []
    
    # Basic role keywords
    match role:
        CharacterRole.PROTAGONIST:
            keywords = ["hero", "focus", "central", "bright"]
        CharacterRole.ANTAGONIST:
            keywords = ["shadow", "contrast", "opposition", "dark"]
        CharacterRole.MENTOR:
            keywords = ["wise", "elder", "guide", "calm"]
        CharacterRole.ALLY:
            keywords = ["support", "friend", "companion", "loyal"]
        _:
            keywords = ["complex", "nuanced", "layered", "detailed"]
    
    # Add dimension-specific keywords
    match dimension:
        DimensionalInfluence.REALITY:
            keywords.append_array(["simple", "basic", "foundational", "singular"])
        DimensionalInfluence.LINEAR:
            keywords.append_array(["direct", "linear", "straight", "sequential"])
        DimensionalInfluence.SPATIAL:
            keywords.append_array(["volumetric", "spatial", "dimensional", "solid"])
        DimensionalInfluence.TEMPORAL:
            keywords.append_array(["evolving", "changing", "temporal", "sequential"])
        DimensionalInfluence.CONSCIOUS:
            keywords.append_array(["aware", "reflexive", "mirrored", "conscious"])
        DimensionalInfluence.CONNECTION:
            keywords.append_array(["connected", "interlinked", "networked", "bound"])
        DimensionalInfluence.CREATION:
            keywords.append_array(["creative", "generative", "imaginative", "artistic"])
        DimensionalInfluence.NETWORK:
            keywords.append_array(["networked", "webbed", "interconnected", "systematic"])
        DimensionalInfluence.HARMONY:
            keywords.append_array(["balanced", "harmonious", "aligned", "peaceful"])
        DimensionalInfluence.UNITY:
            keywords.append_array(["unified", "whole", "complete", "integrated"])
        DimensionalInfluence.TRANSCENDENT:
            keywords.append_array(["transcendent", "elevated", "enlightened", "ascended"])
        DimensionalInfluence.BEYOND:
            keywords.append_array(["mystical", "otherworldly", "ineffable", "cosmic"])
    
    return keywords

func generate_location(id: String, base_name: String, dimension: int) -> StoryLocation:
    var name = base_name
    if _location_templates.size() > 0:
        var template = _location_templates.values()[randi() % _location_templates.size()]
        name = template.get("name", base_name)
    
    var location = StoryLocation.new(id, name)
    
    # Basic location description based on dimension
    match dimension:
        DimensionalInfluence.REALITY:
            location.description = "A singular point in space, condensed to its essence."
            location.mood = "concentrated"
            location.elements = ["point", "singularity", "essence"]
        DimensionalInfluence.LINEAR:
            location.description = "A pathway stretching between important points."
            location.mood = "directional"
            location.elements = ["path", "line", "direction"]
        DimensionalInfluence.SPATIAL:
            location.description = "A three-dimensional environment with space to explore."
            location.mood = "expansive"
            location.elements = ["volume", "space", "environment"]
        DimensionalInfluence.TEMPORAL:
            location.description = "A place where time flows in interesting ways."
            location.mood = "shifting"
            location.elements = ["clock", "temporal", "flowing"]
        DimensionalInfluence.CONSCIOUS:
            location.description = "A reflective space that mirrors those within it."
            location.mood = "reflective"
            location.elements = ["mirror", "reflection", "awareness"]
        DimensionalInfluence.CONNECTION:
            location.description = "A nexus where many paths and relationships intersect."
            location.mood = "connected"
            location.elements = ["nexus", "intersection", "linked"]
        DimensionalInfluence.CREATION:
            location.description = "A generative space where new things come into being."
            location.mood = "creative"
            location.elements = ["workshop", "studio", "forge"]
        DimensionalInfluence.NETWORK:
            location.description = "A complex network of interrelated spaces and passages."
            location.mood = "intricate"
            location.elements = ["web", "network", "system"]
        DimensionalInfluence.HARMONY:
            location.description = "A balanced environment where opposing forces find peace."
            location.mood = "harmonious"
            location.elements = ["balance", "harmony", "peace"]
        DimensionalInfluence.UNITY:
            location.description = "A unified space where all elements are integrated."
            location.mood = "whole"
            location.elements = ["unity", "wholeness", "integration"]
        DimensionalInfluence.TRANSCENDENT:
            location.description = "An elevated place that rises beyond ordinary limitations."
            location.mood = "transcendent"
            location.elements = ["spire", "beyond", "elevated"]
        DimensionalInfluence.BEYOND:
            location.description = "A mysterious realm beyond conventional understanding."
            location.mood = "mystical"
            location.elements = ["mystery", "otherness", "ineffable"]
    
    # Set dimensional influence
    location.dimensional_influence = dimension
    
    # Visual keywords based on dimension
    location.visual_keywords = location.elements
    
    return location

func generate_event(id: String, base_title: String, stage: int) -> StoryEvent:
    var title = base_title
    
    var event = StoryEvent.new(id, title, stage)
    
    # Basic event description based on stage
    match stage:
        StoryStage.SETUP:
            event.description = "The beginning of the journey, where the world and characters are introduced."
        StoryStage.CONFLICT:
            event.description = "A challenge arises that creates the central problem to overcome."
        StoryStage.RISING_ACTION:
            event.description = "The tension increases as complications develop."
        StoryStage.CLIMAX:
            event.description = "The pivotal moment where the main conflict comes to a head."
        StoryStage.FALLING_ACTION:
            event.description = "The consequences of the climax unfold."
        StoryStage.RESOLUTION:
            event.description = "The story concludes with closure for the main elements."
    
    # Visual representation
    event.visual_representation = "A scene depicting " + event.description
    
    return event

func get_story(story_id: String) -> Story:
    if _current_stories.has(story_id):
        return _current_stories[story_id]
    return null

func get_event(story_id: String, event_id: String) -> StoryEvent:
    var story = get_story(story_id)
    if story and story.all_events.has(event_id):
        return story.all_events[event_id]
    return null

func make_choice(story_id: String, choice_index: int) -> String:
    var story = get_story(story_id)
    if not story:
        return ""
    
    var next_event_id = story.make_choice(choice_index)
    
    if next_event_id:
        emit_signal("story_choice_made", story_id, story.history[-1], choice_index)
        emit_signal("story_event_changed", story_id, next_event_id)
    
    return next_event_id

func get_current_event(story_id: String) -> StoryEvent:
    var story = get_story(story_id)
    if story:
        return story.get_current_event()
    return null

func import_text_data(text: String, source: String = "manual"):
    # Analyze text for themes
    var theme_results = _theme_analyzer.analyze_text(text)
    
    # Update repository with theme data
    for theme in theme_results:
        _data_repository.add_theme(theme, theme_results[theme])
    
    # Extract and store words
    var words = text.split(" ", false)
    var word_count = 0
    
    for word in words:
        # Clean the word (remove punctuation, lowercase)
        var clean_word = word.strip_edges().to_lower()
        clean_word = clean_word.replace(",", "").replace(".", "").replace("!", "").replace("?", "")
        
        if clean_word.length() > 2:  # Ignore very short words
            _data_repository.add_word(clean_word)
            word_count += 1
    
    # Signal the completion
    emit_signal("data_imported", source, word_count)

func import_file_data(file_path: String):
    var file = File.new()
    if file.open(file_path, File.READ) == OK:
        var content = file.get_as_text()
        file.close()
        
        import_text_data(content, file_path.get_file())
        return true
    
    return false

func _load_templates():
    # In a real implementation, these would be loaded from files
    # For now, we'll just create some basic templates
    
    # Character templates
    _character_templates["hero_template"] = {
        "name": "Hero",
        "role": CharacterRole.PROTAGONIST,
        "traits": ["brave", "determined", "compassionate"],
        "visual_keywords": ["light", "strong", "central"]
    }
    
    _character_templates["villain_template"] = {
        "name": "Villain",
        "role": CharacterRole.ANTAGONIST,
        "traits": ["ambitious", "ruthless", "intelligent"],
        "visual_keywords": ["dark", "shadow", "imposing"]
    }
    
    # Location templates
    _location_templates["forest_template"] = {
        "name": "Mystical Forest",
        "mood": "mysterious",
        "elements": ["trees", "mist", "ancient"],
        "visual_keywords": ["green", "shadowy", "organic"]
    }
    
    _location_templates["city_template"] = {
        "name": "Bustling City",
        "mood": "energetic",
        "elements": ["buildings", "crowds", "activity"],
        "visual_keywords": ["urban", "structured", "busy"]
    }
    
    # Story templates would be more complex and loaded from actual files

func _load_personal_data():
    # In a real implementation, this would load data from files or databases
    # For now, we'll just use placeholder data
    
    # Add some basic theme preferences
    _data_repository.add_theme(StoryTheme.ADVENTURE, 80)
    _data_repository.add_theme(StoryTheme.MYSTERY, 65)
    _data_repository.add_theme(StoryTheme.TRANSFORMATION, 60)

func set_current_dimension(dimension: int):
    _config.current_dimension = dimension

func theme_to_dimension(theme: int) -> int:
    # Map themes to most appropriate dimensions
    match theme:
        StoryTheme.IDENTITY:
            return DimensionalInfluence.CONSCIOUS
        StoryTheme.TRANSFORMATION:
            return DimensionalInfluence.TEMPORAL
        StoryTheme.MYSTERY:
            return DimensionalInfluence.BEYOND
        StoryTheme.ADVENTURE:
            return DimensionalInfluence.SPATIAL
        StoryTheme.CONFLICT:
            return DimensionalInfluence.REALITY
        StoryTheme.CONNECTION:
            return DimensionalInfluence.CONNECTION
        StoryTheme.DISCOVERY:
            return DimensionalInfluence.CREATION
        StoryTheme.REDEMPTION:
            return DimensionalInfluence.TRANSCENDENT
        StoryTheme.CREATION:
            return DimensionalInfluence.CREATION
        StoryTheme.DESTRUCTION:
            return DimensionalInfluence.LINEAR
        StoryTheme.BALANCE:
            return DimensionalInfluence.HARMONY
        StoryTheme.TRANSCENDENCE:
            return DimensionalInfluence.TRANSCENDENT
        _:
            return DimensionalInfluence.SPATIAL

func get_theme_name(theme: int) -> String:
    match theme:
        StoryTheme.IDENTITY:
            return "identity"
        StoryTheme.TRANSFORMATION:
            return "transformation"
        StoryTheme.MYSTERY:
            return "mystery"
        StoryTheme.ADVENTURE:
            return "adventure"
        StoryTheme.CONFLICT:
            return "conflict"
        StoryTheme.CONNECTION:
            return "connection"
        StoryTheme.DISCOVERY:
            return "discovery"
        StoryTheme.REDEMPTION:
            return "redemption"
        StoryTheme.CREATION:
            return "creation"
        StoryTheme.DESTRUCTION:
            return "destruction"
        StoryTheme.BALANCE:
            return "balance"
        StoryTheme.TRANSCENDENCE:
            return "transcendence"
        _:
            return "unknown"

func get_dimension_name(dimension: int) -> String:
    match dimension:
        DimensionalInfluence.REALITY:
            return "Reality"
        DimensionalInfluence.LINEAR:
            return "Linear"
        DimensionalInfluence.SPATIAL:
            return "Spatial"
        DimensionalInfluence.TEMPORAL:
            return "Temporal"
        DimensionalInfluence.CONSCIOUS:
            return "Consciousness"
        DimensionalInfluence.CONNECTION:
            return "Connection"
        DimensionalInfluence.CREATION:
            return "Creation"
        DimensionalInfluence.NETWORK:
            return "Network"
        DimensionalInfluence.HARMONY:
            return "Harmony"
        DimensionalInfluence.UNITY:
            return "Unity"
        DimensionalInfluence.TRANSCENDENT:
            return "Transcendence"
        DimensionalInfluence.BEYOND:
            return "Beyond"
        _:
            return "Unknown"

func generate_unique_id() -> String:
    var id = str(OS.get_unix_time()) + "-" + str(randi() % 1000000).pad_zeros(6)
    return id

# Example usage:
# var story_gen = StoryGenerationEngine.new()
# add_child(story_gen)
# story_gen.initialize()
# 
# # Import personal data
# story_gen.import_text_data("Some sample text to analyze for themes and word patterns...")
# 
# # Create a story
# var story_id = story_gen.create_story("My Adventure")
# 
# # Get the current event
# var current_event = story_gen.get_current_event(story_id)
# 
# # Make a choice (e.g., choose the first option)
# story_gen.make_choice(story_id, 0)