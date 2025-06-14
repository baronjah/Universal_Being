extends Node
class_name WishingGame

# Wishing Game - Memory-based Wishing System
# Integrates with memory systems to create a wish fulfillment game
# Uses # for memory organization and dimensional mapping

# Game Configuration
const MAX_WISHES = 9
const MAX_WORDS_PER_WISH = 7
const MIN_WORDS_PER_WISH = 3
const MAX_ACTIVE_MEMORIES = 12
const WISH_FULFILLMENT_TIME = 3.0 # seconds
const MEMORY_LIFESPAN = 30.0 # seconds

# Game Dimension Levels
const DIMENSION_NAMES = {
    1: "Reality",
    2: "Linear",
    3: "Spatial", 
    4: "Temporal",
    5: "Consciousness",
    6: "Connection",
    7: "Creation",
    8: "Network",
    9: "Harmony",
    10: "Unity", 
    11: "Transcendent",
    12: "Meta"
}

const DIMENSION_COLORS = {
    1: Color(1.0, 0.1, 0.1),  # Red
    2: Color(1.0, 0.5, 0.1),  # Orange
    3: Color(1.0, 1.0, 0.1),  # Yellow
    4: Color(0.1, 1.0, 0.1),  # Green
    5: Color(0.1, 1.0, 1.0),  # Cyan
    6: Color(0.1, 0.1, 1.0),  # Blue
    7: Color(0.5, 0.1, 1.0),  # Purple
    8: Color(1.0, 0.1, 1.0),  # Magenta
    9: Color(1.0, 0.1, 0.5),  # Pink
    10: Color(0.7, 0.7, 0.7), # Silver
    11: Color(0.9, 0.9, 0.9), # White
    12: Color(0.9, 0.9, 1.0)  # Light Blue
}

# Memory Integration
var memory_rehab_system = null
var memory_ultra_advanced = null
var notepad3d = null
var current_dimension = 1
var current_device = 0
var total_score = 0

# Game State
var wishes = []
var active_memories = []
var fulfilled_wishes = []
var game_active = false
var dimension_unlocked = {
    1: true,   # Reality starts unlocked
    2: false,  # Linear
    3: false,  # Spatial
    4: false,  # Temporal
    5: false,  # Consciousness
    6: false,  # Connection
    7: false,  # Creation
    8: false,  # Network
    9: false,  # Harmony
    10: false, # Unity
    11: false, # Transcendent
    12: false  # Meta
}
var current_level = 1
var wishes_to_advance = 3
var wishes_fulfilled_this_level = 0
var game_timer = 0
var last_wish_time = 0

# UI Elements
var ui_layer = null
var wish_list_panel = null
var memory_panel = null
var score_label = null
var dimension_label = null
var instruction_label = null
var game_timer_label = null

# Audio
var sound_effects = {
    "wish_created": null,
    "wish_fulfilled": null, 
    "level_up": null,
    "memory_created": null,
    "memory_expired": null
}

# Data Classes
class Wish:
    var id: String
    var text: String
    var words = []
    var required_words = []
    var creation_time: float
    var fulfilled: bool = false
    var fulfillment_time: float = 0
    var dimension: int
    var difficulty: int
    var score_value: int
    
    func _init(p_id, p_text, p_dimension, p_difficulty = 1):
        id = p_id
        text = p_text
        dimension = p_dimension
        difficulty = p_difficulty
        creation_time = OS.get_ticks_msec() / 1000.0
        score_value = 10 * difficulty * dimension
        
        # Extract required words
        extract_required_words()
    
    func extract_required_words():
        # Split text into words
        var raw_words = text.split(" ", false)
        
        # Filter and clean words
        for word in raw_words:
            # Clean word
            var clean_word = word.strip_edges().to_lower()
            clean_word = clean_word.replace(".", "").replace(",", "").replace("!", "").replace("?", "")
            
            # Skip small words
            if clean_word.length() < 3:
                continue
                
            # Skip common words
            if clean_word in ["the", "and", "for", "with", "that", "this", "you", "your"]:
                continue
                
            words.append(clean_word)
        
        # Select required words
        var num_required = min(words.size(), MIN_WORDS_PER_WISH + difficulty - 1)
        
        # Randomly select required words
        words.shuffle()
        required_words = words.slice(0, num_required - 1)

class Memory:
    var id: String
    var text: String
    var creation_time: float
    var expiration_time: float
    var dimension: int
    var active: bool = true
    var visualized: bool = false
    var position: Vector3
    var tags = []
    
    func _init(p_id, p_text, p_dimension):
        id = p_id
        text = p_text
        dimension = p_dimension
        creation_time = OS.get_ticks_msec() / 1000.0
        expiration_time = creation_time + MEMORY_LIFESPAN
        
        # Random position within view
        position = Vector3(
            rand_range(-5, 5),
            rand_range(-3, 3),
            rand_range(-2, 2)
        )

# Signals
signal wish_created(wish_data)
signal wish_fulfilled(wish_data, memories_used)
signal memory_created(memory_data)
signal memory_expired(memory_data)
signal dimension_unlocked(dimension)
signal level_advanced(new_level)
signal game_started()
signal game_ended(final_score)

# Initialization
func _ready():
    randomize()
    setup_ui()
    print("# Wishing Game initialized #")

# Core Loop
func _process(delta):
    if not game_active:
        return
        
    # Update game timer
    game_timer += delta
    
    # Update UI
    update_timer_display()
    
    # Check for memory expiration
    check_memory_expiration()
    
    # Check if it's time to create a new wish
    if wishes.size() < MAX_WISHES and game_timer - last_wish_time >= 10.0:
        create_random_wish()
        last_wish_time = game_timer

# Game Setup
func setup_ui():
    # Create UI layer
    ui_layer = CanvasLayer.new()
    ui_layer.name = "WishingGameUI"
    add_child(ui_layer)
    
    # Create panels
    create_wish_panel()
    create_memory_panel()
    create_score_panel()
    
    # Create instruction label
    instruction_label = Label.new()
    instruction_label.name = "InstructionLabel"
    instruction_label.text = "# CREATE MEMORIES TO FULFILL WISHES #"
    instruction_label.align = Label.ALIGN_CENTER
    instruction_label.rect_position = Vector2(0, get_viewport().size.y - 40)
    instruction_label.rect_size = Vector2(get_viewport().size.x, 30)
    instruction_label.add_color_override("font_color", Color(1, 1, 1))
    ui_layer.add_child(instruction_label)
    
    # Hide UI until game starts
    ui_layer.visible = false

func create_wish_panel():
    # Create wish list panel
    wish_list_panel = Panel.new()
    wish_list_panel.name = "WishListPanel"
    wish_list_panel.rect_position = Vector2(20, 20)
    wish_list_panel.rect_size = Vector2(300, 400)
    ui_layer.add_child(wish_list_panel)
    
    # Add title
    var title = Label.new()
    title.name = "Title"
    title.text = "# WISHES #"
    title.align = Label.ALIGN_CENTER
    title.rect_position = Vector2(0, 5)
    title.rect_size = Vector2(300, 30)
    title.add_color_override("font_color", Color(1, 1, 0))
    wish_list_panel.add_child(title)
    
    # Add scroll container for wishes
    var scroll = ScrollContainer.new()
    scroll.name = "WishScroll"
    scroll.rect_position = Vector2(10, 40)
    scroll.rect_size = Vector2(280, 350)
    wish_list_panel.add_child(scroll)
    
    # Add container for wishes
    var container = VBoxContainer.new()
    container.name = "WishContainer"
    container.rect_min_size = Vector2(260, 0)
    container.size_flags_horizontal = Control.SIZE_FILL
    scroll.add_child(container)

func create_memory_panel():
    # Create memory panel
    memory_panel = Panel.new()
    memory_panel.name = "MemoryPanel"
    memory_panel.rect_position = Vector2(get_viewport().size.x - 320, 20)
    memory_panel.rect_size = Vector2(300, 400)
    ui_layer.add_child(memory_panel)
    
    # Add title
    var title = Label.new()
    title.name = "Title"
    title.text = "# ACTIVE MEMORIES #"
    title.align = Label.ALIGN_CENTER
    title.rect_position = Vector2(0, 5)
    title.rect_size = Vector2(300, 30)
    title.add_color_override("font_color", Color(0, 1, 1))
    memory_panel.add_child(title)
    
    # Add scroll container for memories
    var scroll = ScrollContainer.new()
    scroll.name = "MemoryScroll"
    scroll.rect_position = Vector2(10, 40)
    scroll.rect_size = Vector2(280, 350)
    memory_panel.add_child(scroll)
    
    # Add container for memories
    var container = VBoxContainer.new()
    container.name = "MemoryContainer"
    container.rect_min_size = Vector2(260, 0)
    container.size_flags_horizontal = Control.SIZE_FILL
    scroll.add_child(container)

func create_score_panel():
    # Create top score panel
    var score_panel = Panel.new()
    score_panel.name = "ScorePanel"
    score_panel.rect_position = Vector2(330, 20)
    score_panel.rect_size = Vector2(get_viewport().size.x - 660, 50)
    ui_layer.add_child(score_panel)
    
    # Add score label
    score_label = Label.new()
    score_label.name = "ScoreLabel"
    score_label.text = "# SCORE: 0 #"
    score_label.align = Label.ALIGN_CENTER
    score_label.valign = Label.VALIGN_CENTER
    score_label.rect_position = Vector2(10, 0)
    score_label.rect_size = Vector2(score_panel.rect_size.x / 3 - 20, 50)
    score_label.add_color_override("font_color", Color(1, 1, 1))
    score_panel.add_child(score_label)
    
    # Add dimension label
    dimension_label = Label.new()
    dimension_label.name = "DimensionLabel"
    dimension_label.text = "# DIMENSION 1: REALITY #"
    dimension_label.align = Label.ALIGN_CENTER
    dimension_label.valign = Label.VALIGN_CENTER
    dimension_label.rect_position = Vector2(score_panel.rect_size.x / 3, 0)
    dimension_label.rect_size = Vector2(score_panel.rect_size.x / 3, 50)
    dimension_label.add_color_override("font_color", DIMENSION_COLORS[1])
    score_panel.add_child(dimension_label)
    
    # Add timer label
    game_timer_label = Label.new()
    game_timer_label.name = "TimerLabel"
    game_timer_label.text = "# TIME: 0:00 #"
    game_timer_label.align = Label.ALIGN_CENTER
    game_timer_label.valign = Label.VALIGN_CENTER
    game_timer_label.rect_position = Vector2(2 * score_panel.rect_size.x / 3, 0)
    game_timer_label.rect_size = Vector2(score_panel.rect_size.x / 3 - 20, 50)
    game_timer_label.add_color_override("font_color", Color(1, 1, 1))
    score_panel.add_child(game_timer_label)

# Memory System Integration
func connect_memory_rehab_system(system):
    memory_rehab_system = system
    print("# Connected to Memory Rehab System #")
    return true

func connect_memory_ultra_advanced(system):
    memory_ultra_advanced = system
    print("# Connected to Memory Ultra Advanced System #")
    return true

func connect_notepad3d(system):
    notepad3d = system
    print("# Connected to Notepad3D Advanced #")
    return true

# Game Control
func start_game():
    if game_active:
        return
    
    print("# Starting Wishing Game... #")
    
    # Reset game state
    reset_game()
    
    # Show UI
    ui_layer.visible = true
    
    # Create initial wishes
    for i in range(3):
        create_random_wish()
    
    # Set game active
    game_active = true
    
    # Start timer
    game_timer = 0
    last_wish_time = 0
    
    emit_signal("game_started")
    
    return true

func end_game():
    if not game_active:
        return
    
    print("# Ending Wishing Game... #")
    
    # Set game inactive
    game_active = false
    
    # Hide UI
    ui_layer.visible = false
    
    # Clear all active memories
    clear_memories()
    
    emit_signal("game_ended", total_score)
    
    return true

func reset_game():
    # Clear game state
    wishes.clear()
    active_memories.clear()
    fulfilled_wishes.clear()
    
    # Reset progression
    current_dimension = 1
    current_level = 1
    wishes_fulfilled_this_level = 0
    total_score = 0
    
    # Reset dimension unlocks (only dimension 1 is unlocked)
    for dim in dimension_unlocked.keys():
        dimension_unlocked[dim] = (dim == 1)
    
    # Update UI
    update_score_display()
    update_dimension_display()
    update_wish_display()
    update_memory_display()
    
    return true

# Wish Management
func create_random_wish():
    if wishes.size() >= MAX_WISHES:
        return null
    
    # Generate wish ID
    var wish_id = "wish_" + str(wishes.size()) + "_" + str(OS.get_unix_time())
    
    # Determine difficulty (higher dimensions = higher difficulty)
    var difficulty = 1 + int(current_dimension / 3)
    
    # Select a wish template
    var wish_text = generate_wish_text(current_dimension)
    
    # Create the wish
    var wish = Wish.new(wish_id, wish_text, current_dimension, difficulty)
    
    # Add to wish list
    wishes.append(wish)
    
    # Update UI
    update_wish_display()
    
    print("# Created wish: " + wish_text + " #")
    
    # Play sound
    play_sound("wish_created")
    
    emit_signal("wish_created", wish)
    
    return wish

func generate_wish_text(dimension):
    # Templates by dimension
    var templates = {
        1: [  # Reality
            "I wish for a # and # to manifest",
            "Create a # that can transform into a #",
            "Bring forth a # with # properties"
        ],
        2: [  # Linear
            "Connect # with # in a sequential pattern",
            "Create a timeline linking # to #",
            "Establish a path from # to #"
        ],
        3: [  # Spatial
            "Build a # structure with # dimensions",
            "Form a # in the shape of a #",
            "Construct a # with # spatial attributes"
        ],
        4: [  # Temporal
            "Synchronize # with # across time",
            "Create a # that evolves into # over time",
            "Manifest a # that changes # with each moment"
        ],
        5: [  # Consciousness
            "Awaken # within the # of awareness",
            "Bring consciousness to # and #",
            "Make # aware of the # around it"
        ],
        6: [  # Connection
            "Link the essence of # with #",
            "Bridge the gap between # and #",
            "Connect # to # with unbreakable bonds"
        ],
        7: [  # Creation
            "Generate a # that produces #",
            "Create a system where # transforms into #",
            "Manifest a creative force that turns # into #"
        ],
        8: [  # Network
            "Weave # and # into a complex network",
            "Create a system where # influences #",
            "Establish a web connecting # to #"
        ],
        9: [  # Harmony
            "Balance the forces of # and #",
            "Harmonize # with # for perfect balance",
            "Create equilibrium between # and #"
        ],
        10: [  # Unity
            "Unify # and # into a perfect whole",
            "Merge # with # for complete integration",
            "Bring # and # together as one"
        ],
        11: [  # Transcendence
            "Elevate # beyond # into transcendence",
            "Transform # into # beyond limitations",
            "Release # from # for ascension"
        ],
        12: [  # Meta
            "Create a # about #",
            "Form a meta-structure where # reflects on #",
            "Manifest a system that makes # aware of #"
        ]
    }
    
    # Words by dimension category
    var word_categories = {
        1: [  # Reality - physical objects
            "crystal", "stone", "tree", "flower", "mountain", "ocean", "flame", "shadow",
            "wind", "earth", "water", "light", "darkness", "star", "moon", "cloud"
        ],
        2: [  # Linear - sequential concepts
            "path", "journey", "story", "sequence", "progression", "evolution", "cycle",
            "chain", "line", "history", "future", "development", "growth", "timeline"
        ],
        3: [  # Spatial - dimensional concepts
            "cube", "sphere", "pyramid", "labyrinth", "maze", "vortex", "spiral",
            "dimension", "void", "space", "realm", "territory", "domain", "plane"
        ],
        4: [  # Temporal - time concepts
            "moment", "eternity", "epoch", "era", "instant", "duration", "continuum",
            "clock", "calendar", "season", "age", "pulse", "rhythm", "transformation"
        ],
        5: [  # Consciousness - awareness concepts
            "mind", "thought", "dream", "idea", "concept", "perception", "awareness",
            "consciousness", "cognition", "intuition", "insight", "understanding", "wisdom"
        ],
        6: [  # Connection - relational concepts
            "bond", "link", "bridge", "relationship", "connection", "network", "web",
            "synergy", "alliance", "harmony", "resonance", "synchronicity", "unity"
        ],
        7: [  # Creation - generative concepts
            "source", "origin", "creator", "genesis", "imagination", "innovation", "invention",
            "inspiration", "design", "pattern", "blueprint", "vision", "potential"
        ],
        8: [  # Network - systemic concepts
            "system", "framework", "matrix", "grid", "nexus", "node", "hub",
            "ecosystem", "community", "collective", "organization", "structure", "pattern"
        ],
        9: [  # Harmony - balance concepts
            "balance", "harmony", "equilibrium", "symmetry", "proportion", "alignment", "resonance",
            "concord", "peace", "stability", "tranquility", "serenity", "order"
        ],
        10: [  # Unity - wholeness concepts
            "unity", "wholeness", "oneness", "integration", "fusion", "merge", "blend",
            "synthesis", "unification", "convergence", "totality", "completion", "perfection"
        ],
        11: [  # Transcendence - beyond concepts
            "transcendence", "ascension", "liberation", "enlightenment", "awakening", "infinity", "eternity",
            "divinity", "essence", "spirit", "soul", "quintessence", "perfection", "truth"
        ],
        12: [  # Meta - self-referential concepts
            "knowledge", "reflection", "recursion", "meta", "self-reference", "awareness", "observation",
            "introspection", "contemplation", "perception", "conception", "recognition", "understanding"
        ]
    }
    
    # If dimension doesn't have templates, use dimension 1
    if not templates.has(dimension):
        dimension = 1
    
    # Get dimension-specific templates and words
    var dim_templates = templates[dimension]
    var dim_words = word_categories[dimension]
    
    # Choose random template
    var template = dim_templates[randi() % dim_templates.size()]
    
    # Select random words to fill the template
    while template.find("#") >= 0:
        var word = dim_words[randi() % dim_words.size()]
        template = template.replace("#", word, 1)
    
    return template

func check_wish_fulfillment(memory):
    # Skip if no memories or wishes
    if active_memories.size() == 0 or wishes.size() == 0:
        return false
    
    var memory_text = memory.text.to_lower()
    var memories_fulfilled = []
    
    # Check each wish
    for wish in wishes:
        # Skip already fulfilled wishes
        if wish.fulfilled:
            continue
        
        # Count how many required words are found in active memories
        var words_found = 0
        var memories_used = []
        
        # Check if any required words are in this memory
        for req_word in wish.required_words:
            if memory_text.find(req_word) >= 0:
                words_found += 1
                memories_used.append(memory.id)
                break
        
        # Check other active memories
        if words_found < wish.required_words.size():
            for other_memory in active_memories:
                # Skip if already counted
                if other_memory.id == memory.id or memories_used.has(other_memory.id):
                    continue
                
                var other_text = other_memory.text.to_lower()
                
                # Check each remaining required word
                for req_word in wish.required_words:
                    # Skip if word already found
                    var word_already_found = false
                    for mem_id in memories_used:
                        var mem = get_memory_by_id(mem_id)
                        if mem and mem.text.to_lower().find(req_word) >= 0:
                            word_already_found = true
                            break
                    
                    if word_already_found:
                        continue
                    
                    # Check if word is in this memory
                    if other_text.find(req_word) >= 0:
                        words_found += 1
                        memories_used.append(other_memory.id)
                        break
                
                # Stop if we found all required words
                if words_found >= wish.required_words.size():
                    break
        
        # Check if wish is fulfilled
        if words_found >= wish.required_words.size():
            fulfill_wish(wish, memories_used)
            memories_fulfilled.append(wish)
    
    return memories_fulfilled.size() > 0

func fulfill_wish(wish, memories_used):
    # Mark wish as fulfilled
    wish.fulfilled = true
    wish.fulfillment_time = OS.get_ticks_msec() / 1000.0
    
    # Add to fulfilled wishes
    fulfilled_wishes.append(wish)
    
    # Remove from active wishes
    var index = wishes.find(wish)
    if index >= 0:
        wishes.remove(index)
    
    # Update score
    total_score += wish.score_value
    update_score_display()
    
    # Update UI
    update_wish_display()
    
    # Check level progression
    wishes_fulfilled_this_level += 1
    if wishes_fulfilled_this_level >= wishes_to_advance:
        advance_level()
    
    print("# Fulfilled wish: " + wish.text + " #")
    print("# Used memories: " + str(memories_used) + " #")
    
    # Play sound
    play_sound("wish_fulfilled")
    
    emit_signal("wish_fulfilled", wish, memories_used)
    
    return true

func advance_level():
    current_level += 1
    wishes_fulfilled_this_level = 0
    
    # Unlock next dimension if not already unlocked
    var next_dimension = min(current_dimension + 1, 12)
    if not dimension_unlocked[next_dimension]:
        dimension_unlocked[next_dimension] = true
        emit_signal("dimension_unlocked", next_dimension)
    
    # Change to highest unlocked dimension
    var highest_dimension = 1
    for dim in dimension_unlocked.keys():
        if dimension_unlocked[dim] and dim > highest_dimension:
            highest_dimension = dim
    
    change_dimension(highest_dimension)
    
    # Increase wishes needed for next level
    wishes_to_advance = min(wishes_to_advance + 1, 5)
    
    print("# Advanced to level " + str(current_level) + " #")
    print("# Current dimension: " + str(current_dimension) + " #")
    
    # Play sound
    play_sound("level_up")
    
    emit_signal("level_advanced", current_level)
    
    return current_level

func change_dimension(dimension):
    # Validate dimension
    if dimension < 1 or dimension > 12:
        return false
    
    # Check if dimension is unlocked
    if not dimension_unlocked[dimension]:
        print("# Dimension " + str(dimension) + " is not unlocked yet #")
        return false
    
    print("# Changing to dimension " + str(dimension) + " #")
    
    current_dimension = dimension
    
    # Update UI
    update_dimension_display()
    
    # Notify notepad3d if connected
    if notepad3d and notepad3d.has_method("change_dimension"):
        notepad3d.change_dimension(dimension)
    
    return true

# Memory Management
func create_memory(text, tags = []):
    # Limit active memories
    if active_memories.size() >= MAX_ACTIVE_MEMORIES:
        # Remove oldest memory
        var oldest = active_memories[0]
        remove_memory(oldest.id)
    
    # Generate memory ID
    var memory_id = "memory_" + str(active_memories.size()) + "_" + str(OS.get_unix_time())
    
    # Create memory
    var memory = Memory.new(memory_id, text, current_dimension)
    memory.tags = tags
    
    # Add to active memories
    active_memories.append(memory)
    
    # Update UI
    update_memory_display()
    
    print("# Created memory: " + text + " #")
    
    # Play sound
    play_sound("memory_created")
    
    # Check if this memory helps fulfill any wishes
    check_wish_fulfillment(memory)
    
    # Create in connected systems
    if memory_rehab_system and memory_rehab_system.has_method("create_memory"):
        memory_rehab_system.create_memory(text, current_dimension, tags)
    
    if memory_ultra_advanced and memory_ultra_advanced.has_method("add_memory_word"):
        memory_ultra_advanced.add_memory_word(text, current_device, current_dimension)
    
    if notepad3d and notepad3d.has_method("create_memory"):
        notepad3d.create_memory(text, tags)
    
    emit_signal("memory_created", memory)
    
    return memory

func remove_memory(memory_id):
    # Find memory
    for i in range(active_memories.size()):
        if active_memories[i].id == memory_id:
            var memory = active_memories[i]
            active_memories.remove(i)
            
            # Update UI
            update_memory_display()
            
            print("# Removed memory: " + memory.text + " #")
            
            # Play sound
            play_sound("memory_expired")
            
            emit_signal("memory_expired", memory)
            
            return true
    
    return false

func get_memory_by_id(memory_id):
    for memory in active_memories:
        if memory.id == memory_id:
            return memory
    return null

func clear_memories():
    active_memories.clear()
    update_memory_display()
    return true

# Memory Expiration
func check_memory_expiration():
    var current_time = OS.get_ticks_msec() / 1000.0
    var expired_memories = []
    
    for memory in active_memories:
        if current_time > memory.expiration_time:
            expired_memories.append(memory.id)
    
    # Remove expired memories
    for memory_id in expired_memories:
        remove_memory(memory_id)

# UI Updates
func update_wish_display():
    # Get wish container
    var container = wish_list_panel.get_node("WishScroll/WishContainer")
    
    # Clear existing wishes
    for child in container.get_children():
        child.queue_free()
    
    # Add active wishes
    for wish in wishes:
        add_wish_item(container, wish)
    
    # Add separator
    if wishes.size() > 0 and fulfilled_wishes.size() > 0:
        var separator = HSeparator.new()
        separator.name = "Separator"
        container.add_child(separator)
    
    # Add fulfilled wishes (most recent first)
    var recent_fulfilled = fulfilled_wishes.duplicate()
    recent_fulfilled.invert()
    
    for i in range(min(recent_fulfilled.size(), 3)):
        add_fulfilled_wish_item(container, recent_fulfilled[i])

func add_wish_item(container, wish):
    # Create wish item
    var item = Panel.new()
    item.name = "Wish_" + wish.id
    item.rect_min_size = Vector2(260, 80)
    container.add_child(item)
    
    # Add wish text
    var text = Label.new()
    text.name = "WishText"
    text.text = wish.text
    text.align = Label.ALIGN_LEFT
    text.valign = Label.VALIGN_CENTER
    text.autowrap = true
    text.rect_position = Vector2(5, 5)
    text.rect_size = Vector2(250, 50)
    item.add_child(text)
    
    # Add required words
    var words = Label.new()
    words.name = "RequiredWords"
    words.text = "Required: " + PoolStringArray(wish.required_words).join(", ")
    words.align = Label.ALIGN_LEFT
    words.rect_position = Vector2(5, 55)
    words.rect_size = Vector2(250, 20)
    words.add_color_override("font_color", Color(0.7, 0.7, 0.7))
    item.add_child(words)
    
    # Set color based on dimension
    var frame_color = DIMENSION_COLORS[wish.dimension]
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
    style.border_color = frame_color
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    item.add_stylebox_override("panel", style)

func add_fulfilled_wish_item(container, wish):
    # Create wish item (smaller for fulfilled)
    var item = Panel.new()
    item.name = "FulfilledWish_" + wish.id
    item.rect_min_size = Vector2(260, 60)
    container.add_child(item)
    
    # Add wish text
    var text = Label.new()
    text.name = "WishText"
    text.text = "✓ " + wish.text
    text.align = Label.ALIGN_LEFT
    text.valign = Label.VALIGN_CENTER
    text.autowrap = true
    text.rect_position = Vector2(5, 5)
    text.rect_size = Vector2(250, 50)
    text.add_color_override("font_color", Color(0.5, 1.0, 0.5))
    item.add_child(text)
    
    # Set color based on dimension
    var frame_color = DIMENSION_COLORS[wish.dimension].darkened(0.3)
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.1, 0.1, 0.1, 0.5)
    style.border_color = frame_color
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    item.add_stylebox_override("panel", style)

func update_memory_display():
    # Get memory container
    var container = memory_panel.get_node("MemoryScroll/MemoryContainer")
    
    # Clear existing memories
    for child in container.get_children():
        child.queue_free()
    
    # Add active memories (most recent first)
    var recent_memories = active_memories.duplicate()
    recent_memories.invert()
    
    for memory in recent_memories:
        add_memory_item(container, memory)

func add_memory_item(container, memory):
    # Create memory item
    var item = Button.new()
    item.name = "Memory_" + memory.id
    item.rect_min_size = Vector2(260, 60)
    item.connect("pressed", self, "_on_memory_clicked", [memory.id])
    container.add_child(item)
    
    # Add memory text
    var text = Label.new()
    text.name = "MemoryText"
    text.text = memory.text
    text.align = Label.ALIGN_LEFT
    text.valign = Label.VALIGN_CENTER
    text.autowrap = true
    text.rect_position = Vector2(5, 5)
    text.rect_size = Vector2(250, 50)
    item.add_child(text)
    
    # Set color based on dimension
    var memory_color = DIMENSION_COLORS[memory.dimension]
    
    # Add special effects for tags
    if memory.tags.size() > 0:
        var tag = memory.tags[0]
        var tag_label = Label.new()
        tag_label.name = "TagLabel"
        tag_label.text = tag
        tag_label.align = Label.ALIGN_RIGHT
        tag_label.rect_position = Vector2(190, 5)
        tag_label.rect_size = Vector2(60, 20)
        item.add_child(tag_label)
        
        # Modify color based on tag
        match tag:
            "##":  # Core - brighter
                memory_color = memory_color.lightened(0.3)
                tag_label.add_color_override("font_color", Color(1, 1, 1))
            "#-":  # Fragment - darker
                memory_color = memory_color.darkened(0.3)
                tag_label.add_color_override("font_color", Color(0.7, 0.7, 0.7))
            "#>":  # Link - blue tint
                memory_color = memory_color.linear_interpolate(Color(0, 0, 1), 0.3)
                tag_label.add_color_override("font_color", Color(0.5, 0.5, 1))
            _:
                tag_label.add_color_override("font_color", memory_color.lightened(0.3))
    
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.15, 0.15, 0.15, 0.8)
    style.border_color = memory_color
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    item.add_stylebox_override("normal", style)
    
    # Add timer indicator
    var current_time = OS.get_ticks_msec() / 1000.0
    var remaining = memory.expiration_time - current_time
    var progress = remaining / MEMORY_LIFESPAN
    
    var timer = ProgressBar.new()
    timer.name = "ExpiryTimer"
    timer.rect_position = Vector2(5, 50)
    timer.rect_size = Vector2(250, 5)
    timer.value = progress * 100
    timer.percent_visible = false
    item.add_child(timer)

func update_score_display():
    score_label.text = "# SCORE: " + str(total_score) + " #"

func update_dimension_display():
    dimension_label.text = "# DIMENSION " + str(current_dimension) + ": " + DIMENSION_NAMES[current_dimension] + " #"
    dimension_label.add_color_override("font_color", DIMENSION_COLORS[current_dimension])

func update_timer_display():
    var minutes = int(game_timer) / 60
    var seconds = int(game_timer) % 60
    game_timer_label.text = "# TIME: " + str(minutes) + ":" + str(seconds).pad_zeros(2) + " #"

# Input Handling
func _on_memory_clicked(memory_id):
    print("# Memory clicked: " + memory_id + " #")
    
    # Get memory
    var memory = get_memory_by_id(memory_id)
    if not memory:
        return
    
    # Focus memory in 3D view if notepad is connected
    if notepad3d and notepad3d.has_method("select_memory"):
        notepad3d.select_memory(memory_id)

# Sound and Effects
func play_sound(sound_name):
    if sound_effects.has(sound_name) and sound_effects[sound_name] != null:
        var player = AudioStreamPlayer.new()
        player.stream = sound_effects[sound_name]
        player.autoplay = true
        player.connect("finished", player, "queue_free")
        add_child(player)

# Command Processing
func process_command(command):
    # Skip empty commands
    command = command.strip_edges()
    if command.empty():
        return null
    
    print("# Processing command: " + command + " #")
    
    # Parse command and arguments
    var parts = command.split(" ", false)
    var cmd = parts[0].to_lower()
    
    # Get arguments
    var args = []
    if parts.size() > 1:
        args = parts.slice(1, parts.size() - 1)
    
    # Process command
    var result = null
    
    match cmd:
        "start", "/start":
            result = start_game()
        "end", "/end":
            result = end_game()
        "wish", "/wish":
            if args.size() > 0:
                result = create_random_wish()
        "memory", "/memory":
            if args.size() > 0:
                var memory_text = PoolStringArray(args).join(" ")
                result = create_memory(memory_text)
        "dimension", "/dimension":
            if args.size() > 0 and args[0].is_valid_integer():
                var dim = int(args[0])
                result = change_dimension(dim)
        "score", "/score":
            result = {"score": total_score, "level": current_level}
        "clear", "/clear":
            result = clear_memories()
        "help", "/help":
            result = {
                "commands": [
                    "start - Start the game",
                    "end - End the game",
                    "wish - Create a random wish",
                    "memory <text> - Create a memory",
                    "dimension <num> - Change dimension if unlocked",
                    "score - Show current score",
                    "clear - Clear all memories",
                    "help - Show this help"
                ]
            }
        _:
            # Default: create memory with text
            var memory_text = command
            result = create_memory(memory_text)
    
    return result

# Example usage:
# var wishing_game = WishingGame.new()
# add_child(wishing_game)
# 
# // Connect to memory systems if available
# var rehab_system = MemoryRehabSystem.new()
# add_child(rehab_system)
# wishing_game.connect_memory_rehab_system(rehab_system)
# 
# // Start the game
# wishing_game.start_game()
# 
# // Process commands
# wishing_game.process_command("memory This is a new memory")
# wishing_game.process_command("dimension 2")