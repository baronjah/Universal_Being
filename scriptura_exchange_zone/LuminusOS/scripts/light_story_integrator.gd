extends Node

class_name LightStoryIntegrator

# Light Story Integrator - Connects the Light Data Transformer with storytelling systems
# Creates narrative structures around light transformations

signal story_created(story_id, title, light_source)
signal story_segment_added(story_id, segment_index, light_related)
signal story_completed(story_id, word_count, light_percentage)

# Story structure constants
const MIN_STORY_SEGMENTS = 3
const MAX_STORY_SEGMENTS = 7
const LIGHT_WORDS = [
    "light", "bright", "glow", "shine", "illuminate", "radiant", "beam", "ray", 
    "luminous", "gleam", "brilliance", "aura", "glitter", "spark", "illumination",
    "shimmer", "glimmer", "flash", "dazzle", "radiance", "clarity", "crystal",
    "transparent", "reflect", "refract", "prism", "spectrum", "rainbow", "dawn"
]

# Story pattern templates
var story_patterns = {
    "12_to_22": {
        "title_template": "The %s Expansion",
        "intro_template": "From twelve lines of %s, the transformation begins.",
        "middle_templates": [
            "The %s expands, revealing deeper truths.",
            "Through illumination, %s becomes clearer.",
            "Lines multiply as %s flows through the structure.",
            "Between the twelfth and twenty-second, %s reveals itself."
        ],
        "conclusion_template": "Twenty-two lines now stand where twelve began, transformed by %s."
    },
    "22_to_12": {
        "title_template": "The %s Condensation",
        "intro_template": "Twenty-two lines of %s await distillation.",
        "middle_templates": [
            "The %s condenses into its essential form.",
            "Through refinement, %s becomes concentrated.",
            "Lines merge as %s flows through the structure.",
            "Between the twenty-second and twelfth, %s refines itself."
        ],
        "conclusion_template": "Twelve lines now stand where twenty-two began, purified by %s."
    },
    "illumination": {
        "title_template": "The %s Illumination",
        "intro_template": "In darkness, %s awaits the light.",
        "middle_templates": [
            "The %s begins to glow with inner knowledge.",
            "Illumination reveals the true nature of %s.",
            "Light flows through %s, transforming meaning.",
            "The hidden aspects of %s emerge in the radiance."
        ],
        "conclusion_template": "Fully illuminated, %s now radiates with newfound clarity."
    }
}

# References to other systems
var transformer
var story_weaver
var data_sea
var memory_system

# Active integration sessions
var active_integrations = {}

# Initialize connections
func _ready():
    # Connect to other systems
    transformer = get_node_or_null("/root/LightDataTransformer")
    story_weaver = get_node_or_null("/root/StoryWeaver")
    data_sea = get_node_or_null("/root/DataSeaController")
    memory_system = get_node_or_null("/root/TerminalMemorySystem")
    
    # Connect signals if available
    if transformer:
        transformer.connect("transformation_complete", Callable(self, "_on_transformation_complete"))
    
    print("Light Story Integrator initialized")

# Create a story from a light transformation
func create_light_story(transformation_id, story_type="auto"):
    if not transformer or not story_weaver:
        print("ERROR: Required systems not available")
        return null
    
    # Get transformation data
    var transformations = transformer.light_data_store.transformations
    if not transformations.has(transformation_id):
        print("ERROR: Transformation not found: " + transformation_id)
        return null
    
    var transformation = transformations[transformation_id]
    
    # Determine story type if auto
    if story_type == "auto":
        if transformation.original_lines < transformation.target_lines:
            story_type = "12_to_22"
        elif transformation.original_lines > transformation.target_lines:
            story_type = "22_to_12"
        else:
            story_type = "illumination"
    
    # Ensure we have the story pattern
    if not story_patterns.has(story_type):
        story_type = "illumination"  # Default to illumination
    
    # Extract key concepts from transformation
    var key_concepts = _extract_key_concepts(transformation)
    
    # Generate light-themed seed words
    var seed_words = _generate_seed_words(key_concepts)
    
    # Create story title
    var title_word = seed_words[0]
    var title = story_patterns[story_type].title_template % title_word
    
    # Begin the story
    var story_id = "none"
    var story_result = null
    
    if story_weaver.has_method("beginStory"):
        story_result = story_weaver.beginStory(title, seed_words)
        story_id = story_result.storyId
    else:
        print("WARNING: Story Weaver missing beginStory method")
        return null
    
    # Store integration info
    active_integrations[story_id] = {
        "id": story_id,
        "title": title,
        "transformation_id": transformation_id,
        "story_type": story_type,
        "seed_words": seed_words,
        "key_concepts": key_concepts,
        "segments_added": 0,
        "light_words_count": 0,
        "total_words_count": 0,
        "status": "in_progress"
    }
    
    # Create and add introduction
    var intro = story_patterns[story_type].intro_template % key_concepts[0]
    if story_weaver.has_method("addMessageToStory"):
        story_weaver.addMessageToStory(intro)
        active_integrations[story_id].segments_added += 1
        
        # Track light words
        _count_light_words(intro, story_id)
    
    # Emit signal
    emit_signal("story_created", story_id, title, transformation_id)
    
    return {
        "story_id": story_id,
        "title": title,
        "seed_words": seed_words,
        "transformation_id": transformation_id
    }

# Add segments to an existing light story
func add_story_segments(story_id, count=1):
    if not story_weaver or not active_integrations.has(story_id):
        return false
    
    var integration = active_integrations[story_id]
    var story_type = integration.story_type
    var pattern = story_patterns[story_type]
    var key_concepts = integration.key_concepts
    
    # Determine how many segments to add
    var segments_remaining = MAX_STORY_SEGMENTS - integration.segments_added
    count = min(count, segments_remaining)
    
    # If no segments left to add, complete the story instead
    if count <= 0:
        return complete_light_story(story_id)
    
    # Add middle segments
    for i in range(count):
        # Determine if this is the last segment
        var is_last = (integration.segments_added + i + 1) >= MAX_STORY_SEGMENTS - 1
        
        if is_last:
            # Add conclusion
            var concept_idx = randi() % key_concepts.size()
            var conclusion = pattern.conclusion_template % key_concepts[concept_idx]
            
            if story_weaver.has_method("addMessageToStory"):
                story_weaver.addMessageToStory(conclusion)
                integration.segments_added += 1
                
                # Track light words
                _count_light_words(conclusion, story_id)
                
                # Emit signal
                emit_signal("story_segment_added", story_id, integration.segments_added, true)
                
                # Complete the story
                return complete_light_story(story_id)
        else:
            # Add middle segment
            var template_idx = randi() % pattern.middle_templates.size()
            var concept_idx = randi() % key_concepts.size()
            var segment = pattern.middle_templates[template_idx] % key_concepts[concept_idx]
            
            if story_weaver.has_method("addMessageToStory"):
                story_weaver.addMessageToStory(segment)
                integration.segments_added += 1
                
                # Track light words
                _count_light_words(segment, story_id)
                
                # Emit signal
                emit_signal("story_segment_added", story_id, integration.segments_added, true)
    
    return true

# Complete a light story
func complete_light_story(story_id):
    if not story_weaver or not active_integrations.has(story_id):
        return false
    
    var integration = active_integrations[story_id]
    
    # Add conclusion if not enough segments yet
    if integration.segments_added < MIN_STORY_SEGMENTS:
        var count = MIN_STORY_SEGMENTS - integration.segments_added
        add_story_segments(story_id, count)
    
    # Complete the story
    if story_weaver.has_method("completeStory"):
        var completion = story_weaver.completeStory()
        integration.status = "completed"
        
        # Calculate light percentage
        var light_percentage = 0.0
        if integration.total_words_count > 0:
            light_percentage = float(integration.light_words_count) / integration.total_words_count
        
        # Emit signal
        emit_signal("story_completed", story_id, integration.total_words_count, light_percentage)
        
        return {
            "story_id": story_id,
            "title": integration.title,
            "segments": integration.segments_added,
            "words": integration.total_words_count,
            "light_percentage": light_percentage
        }
    
    return false

# Fully integrate a transformation with a story (all in one step)
func integrate_transformation(transformation_id):
    # Create story
    var story_info = create_light_story(transformation_id)
    if not story_info:
        return null
    
    # Add middle segments
    add_story_segments(story_info.story_id, MAX_STORY_SEGMENTS - 2)
    
    # Complete the story
    return complete_light_story(story_info.story_id)

# Internal methods
# ---------------

# Extract key concepts from transformation data
func _extract_key_concepts(transformation):
    var concepts = []
    
    # Extract words from transformed data
    var lines = transformation.result.split("\n")
    var all_words = []
    
    for line in lines:
        var words = line.split(" ")
        for word in words:
            # Clean up word
            word = word.strip_edges().to_lower()
            word = word.replace(".", "").replace(",", "").replace("!", "").replace("?", "")
            
            # Only keep words with 4+ characters
            if word.length() >= 4:
                all_words.append(word)
    
    # Find most frequent words
    var word_count = {}
    for word in all_words:
        if not word_count.has(word):
            word_count[word] = 0
        word_count[word] += 1
    
    # Sort by frequency
    var words_sorted = word_count.keys()
    words_sorted.sort_custom(func(a, b): return word_count[a] > word_count[b])
    
    # Take top concepts, excluding very common words
    var common_words = ["this", "that", "with", "from", "what", "when", "where", "they", "their", "there", "these", "have"]
    var concept_count = 0
    
    for word in words_sorted:
        if common_words.has(word):
            continue
        
        concepts.append(word)
        concept_count += 1
        
        if concept_count >= 5:
            break
    
    # Ensure we have at least one concept
    if concepts.size() == 0:
        concepts.append("data")
    
    return concepts

# Generate seed words for the story
func _generate_seed_words(key_concepts):
    var seed_words = []
    
    # Add some key concepts
    var concept_count = min(2, key_concepts.size())
    for i in range(concept_count):
        seed_words.append(key_concepts[i])
    
    # Add some light-related words
    var light_count = 3
    var selected_light_words = []
    
    for i in range(light_count):
        var light_word = LIGHT_WORDS[randi() % LIGHT_WORDS.size()]
        
        # Avoid duplicates
        while selected_light_words.has(light_word):
            light_word = LIGHT_WORDS[randi() % LIGHT_WORDS.size()]
        
        selected_light_words.append(light_word)
        seed_words.append(light_word)
    
    return seed_words

# Count light-related words in text
func _count_light_words(text, story_id):
    if not active_integrations.has(story_id):
        return
    
    var words = text.split(" ")
    var light_count = 0
    
    for word in words:
        # Clean up word
        word = word.strip_edges().to_lower()
        word = word.replace(".", "").replace(",", "").replace("!", "").replace("?", "")
        
        # Check if it's a light-related word
        if LIGHT_WORDS.has(word):
            light_count += 1
    
    # Update counts
    active_integrations[story_id].light_words_count += light_count
    active_integrations[story_id].total_words_count += words.size()

# Signal handlers
# ---------------

# Handle transformation completion
func _on_transformation_complete(transformation_id, original_lines, transformed_lines):
    print("Transformation complete: " + transformation_id)
    # You could automatically integrate with story here if desired

# Public API methods
# ---------------

# Get active integrations
func get_active_integrations():
    return active_integrations

# Get story integration status
func get_integration_status(story_id):
    if not active_integrations.has(story_id):
        return null
    
    return active_integrations[story_id]

# Get light word list
func get_light_words():
    return LIGHT_WORDS

# Process a command for story integration
func process_command(command):
    var parts = command.split(" ")
    
    if parts.size() < 1:
        return "Available commands: create, add, complete, integrate, status, words"
    
    match parts[0]:
        "create":
            if parts.size() < 2:
                return "Usage: create <transformation_id> [story_type]"
            
            var transformation_id = parts[1]
            var story_type = "auto"
            if parts.size() >= 3:
                story_type = parts[2]
            
            var result = create_light_story(transformation_id, story_type)
            if result:
                return "Created story: " + result.title + " (ID: " + result.story_id + ")"
            else:
                return "Failed to create story from transformation: " + transformation_id
            
        "add":
            if parts.size() < 2:
                return "Usage: add <story_id> [count]"
            
            var story_id = parts[1]
            var count = 1
            if parts.size() >= 3:
                count = int(parts[2])
            
            var success = add_story_segments(story_id, count)
            if success:
                return "Added " + str(count) + " segments to story: " + story_id
            else:
                return "Failed to add segments to story: " + story_id
            
        "complete":
            if parts.size() < 2:
                return "Usage: complete <story_id>"
            
            var story_id = parts[1]
            var result = complete_light_story(story_id)
            
            if result:
                return "Completed story: " + result.title + " (" + str(result.words) + " words, " + str(int(result.light_percentage * 100)) + "% light)"
            else:
                return "Failed to complete story: " + story_id
            
        "integrate":
            if parts.size() < 2:
                return "Usage: integrate <transformation_id>"
            
            var transformation_id = parts[1]
            var result = integrate_transformation(transformation_id)
            
            if result:
                return "Integrated transformation with story: " + result.title
            else:
                return "Failed to integrate transformation: " + transformation_id
            
        "status":
            if parts.size() < 2:
                var active_count = active_integrations.size()
                return "Active integrations: " + str(active_count)
            
            var story_id = parts[1]
            var status = get_integration_status(story_id)
            
            if status:
                return "Story: " + status.title + "\nStatus: " + status.status + "\nSegments: " + str(status.segments_added) + "\nWords: " + str(status.total_words_count) + " (" + str(int(float(status.light_words_count) / max(1, status.total_words_count) * 100)) + "% light)"
            else:
                return "No integration found for story: " + story_id
            
        "words":
            var count = 10
            if parts.size() >= 2:
                count = int(parts[1])
            
            count = min(count, LIGHT_WORDS.size())
            var sample = []
            
            for i in range(count):
                sample.append(LIGHT_WORDS[i])
            
            return "Light-related words (" + str(count) + "/" + str(LIGHT_WORDS.size()) + "): " + ", ".join(sample)
            
        _:
            return "Unknown command: " + parts[0]