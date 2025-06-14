extends Node
class_name NumericStageSystem

# The yoyo effect of creation, from 0 to 9 cycle
const NUMERIC_STAGES = 10
const GREEK_SYMBOLS = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "μ"]
const STAGE_NAMES = [
    "Genesis",        # 0
    "Foundation",     # 1
    "Duality",        # 2
    "Expression",     # 3
    "Manifestation",  # 4
    "Harmony",        # 5
    "Perfection",     # 6
    "Mystery",        # 7
    "Mastery",        # 8
    "Completion"      # 9
]

# Stage properties
var current_stage = 0
var current_cycle = 0
var evolution_progress = 0.0
var stage_properties = {}
var word_resonances = {}

# Connections to other systems
var limb_system = null
var memory_system = null
var firewall_system = null

# Signals
signal stage_changed(from_stage, to_stage, symbol)
signal cycle_completed(cycle_number)
signal evolution_progressed(stage, progress)
signal word_resonated(word, stage, strength)
signal numeric_yoyo(direction, from_value, to_value)

func _ready():
    initialize_stage_system()
    connect_to_subsystems()

func initialize_stage_system():
    # Initialize properties for each stage
    for i in range(NUMERIC_STAGES):
        stage_properties[i] = {
            "symbol": GREEK_SYMBOLS[i],
            "name": STAGE_NAMES[i],
            "unlocked": i == 0,  # Only first stage is unlocked initially
            "evolution_threshold": 100.0 * (i + 1),
            "word_affinities": get_stage_word_affinities(i),
            "element_boost": get_stage_element_boost(i),
            "special_abilities": get_stage_abilities(i)
        }
    
    print("Numeric Stage System initialized")
    print("Current stage: " + str(current_stage) + " - " + STAGE_NAMES[current_stage] + " (" + GREEK_SYMBOLS[current_stage] + ")")

func connect_to_subsystems():
    # Connect to limb evolution system if available
    limb_system = get_node_or_null("/root/WordLimbEvolution")
    if limb_system:
        limb_system.limb_evolved.connect(_on_limb_evolved)
        limb_system.stage_unlocked.connect(_on_limb_stage_unlocked)
        print("Connected to Word Limb Evolution system")
    
    # Connect to memory system if available
    memory_system = get_node_or_null("/root/MemoryEvolutionManager")
    if memory_system:
        memory_system.word_caught.connect(_on_word_caught)
        print("Connected to Memory Evolution Manager")
    
    # Connect to firewall system if available
    firewall_system = get_node_or_null("/root/DataPathProtector")
    if firewall_system:
        firewall_system.security_level_changed.connect(_on_security_level_changed)
        print("Connected to Data Path Protector")

func get_stage_word_affinities(stage):
    # Define which types of words resonate with each stage
    var affinities = []
    
    match stage:
        0:  # Genesis
            affinities = ["create", "begin", "start", "init", "var"]
        1:  # Foundation
            affinities = ["build", "base", "struct", "class", "extends"]
        2:  # Duality
            affinities = ["pair", "dual", "toggle", "binary", "bool"]
        3:  # Expression
            affinities = ["print", "display", "show", "emit", "signal"]
        4:  # Manifestation
            affinities = ["form", "instance", "spawn", "new", "construct"]
        5:  # Harmony
            affinities = ["balance", "align", "sync", "match", "pattern"]
        6:  # Perfection
            affinities = ["optimize", "enhance", "perfect", "refine", "clean"]
        7:  # Mystery
            affinities = ["hidden", "secret", "encrypt", "protect", "private"]
        8:  # Mastery
            affinities = ["control", "master", "expert", "command", "virtuoso"]
        9:  # Completion
            affinities = ["finish", "complete", "end", "final", "return"]
    
    return affinities

func get_stage_element_boost(stage):
    # Each stage has an affinity with certain elements
    var element_boost = {}
    
    match stage:
        0: element_boost = {"void": 2.0, "light": 1.5}
        1: element_boost = {"earth": 2.0, "crystal": 1.5}
        2: element_boost = {"water": 1.5, "air": 1.5}
        3: element_boost = {"fire": 2.0, "light": 1.5}
        4: element_boost = {"earth": 1.5, "fire": 1.5}
        5: element_boost = {"water": 2.0, "air": 1.5}
        6: element_boost = {"crystal": 2.0, "light": 1.5}
        7: element_boost = {"void": 2.0, "crystal": 1.5}
        8: element_boost = {"air": 2.0, "fire": 1.5}
        9: element_boost = {"void": 1.5, "light": 2.0}
    
    return element_boost

func get_stage_abilities(stage):
    # Special abilities unlocked at each stage
    var abilities = []
    
    match stage:
        0: abilities = ["creation", "genesis"]
        1: abilities = ["structure", "foundation"]
        2: abilities = ["reflection", "mirroring"]
        3: abilities = ["communication", "expression"]
        4: abilities = ["materialization", "formation"]
        5: abilities = ["balance", "alignment"]
        6: abilities = ["optimization", "perfection"]
        7: abilities = ["concealment", "protection"]
        8: abilities = ["mastery", "control"]
        9: abilities = ["transcendence", "completion"]
    
    return abilities

func advance_stage():
    if current_stage >= NUMERIC_STAGES - 1:
        # Complete a cycle and return to stage 0
        complete_cycle()
        return
    
    var previous_stage = current_stage
    current_stage += 1
    
    # Ensure stage is unlocked
    stage_properties[current_stage].unlocked = true
    evolution_progress = 0.0
    
    print("Advanced from stage " + str(previous_stage) + " to stage " + str(current_stage))
    print("New stage: " + STAGE_NAMES[current_stage] + " (" + GREEK_SYMBOLS[current_stage] + ")")
    
    # Emit signal
    emit_signal("stage_changed", previous_stage, current_stage, GREEK_SYMBOLS[current_stage])
    
    return current_stage

func complete_cycle():
    var previous_stage = current_stage
    current_stage = 0  # Back to beginning
    current_cycle += 1
    evolution_progress = 0.0
    
    print("Cycle " + str(current_cycle) + " completed!")
    print("Returning to stage 0: " + STAGE_NAMES[0] + " (" + GREEK_SYMBOLS[0] + ")")
    
    emit_signal("cycle_completed", current_cycle)
    emit_signal("stage_changed", previous_stage, 0, GREEK_SYMBOLS[0])
    
    # Apply cycle completion bonuses
    _apply_cycle_completion_bonuses()
    
    return current_cycle

func _apply_cycle_completion_bonuses():
    # Apply bonuses based on completed cycles
    print("Applying cycle " + str(current_cycle) + " completion bonuses")
    
    # Enhance limb evolution if available
    if limb_system:
        # This would call methods on the limb system to enhance its capabilities
        print("Enhancing limb evolution system")
    
    # Upgrade firewall if available
    if firewall_system:
        if firewall_system.has_method("upgrade_security_level"):
            firewall_system.upgrade_security_level()
    
    # Expand memory if available
    if memory_system:
        print("Expanding memory system capacity")
        # This would call methods on the memory system to increase capacity

func yoyo_effect(start_value = 0, end_value = 9, iterations = 1):
    # Implement the yoyo numeric effect (cycling from start to end and back)
    print("Starting yoyo effect from " + str(start_value) + " to " + str(end_value))
    
    var sequence = []
    
    for iter in range(iterations):
        # Forward sequence
        for i in range(start_value, end_value + 1):
            sequence.append(i)
            emit_signal("numeric_yoyo", "forward", i > start_value ? i-1 : start_value, i)
            print(str(i))
            # In actual implementation, you might want to add a delay here
        
        # Backward sequence
        for i in range(end_value - 1, start_value - 1, -1):
            sequence.append(i)
            emit_signal("numeric_yoyo", "backward", i < end_value - 1 ? i+1 : end_value, i)
            print(str(i))
            # In actual implementation, you might want to add a delay here
    
    return sequence

func add_evolution_progress(amount):
    var previous_progress = evolution_progress
    evolution_progress += amount
    
    print("Evolution progress: " + str(evolution_progress) + " / " + 
          str(stage_properties[current_stage].evolution_threshold))
    
    emit_signal("evolution_progressed", current_stage, evolution_progress)
    
    # Check if we should advance to next stage
    if evolution_progress >= stage_properties[current_stage].evolution_threshold:
        advance_stage()
    
    return evolution_progress

func process_word(word, element_type = null):
    # Process a word through the numeric stage system
    
    # Check if word resonates with current stage
    var resonance = calculate_word_resonance(word, current_stage)
    var progress_boost = resonance * 10.0  # Base progress boost
    
    # Apply element type boost if applicable
    if element_type != null and stage_properties[current_stage].element_boost.has(element_type):
        var boost_factor = stage_properties[current_stage].element_boost[element_type]
        progress_boost *= boost_factor
        print("Element boost: " + element_type + " (x" + str(boost_factor) + ")")
    
    # Add to tracked words
    if not word in word_resonances:
        word_resonances[word] = {}
    word_resonances[word][current_stage] = resonance
    
    print("Word processed: '" + word + "'")
    print("  Resonance with stage " + str(current_stage) + ": " + str(resonance))
    print("  Progress boost: " + str(progress_boost))
    
    # Add to evolution progress
    add_evolution_progress(progress_boost)
    
    emit_signal("word_resonated", word, current_stage, resonance)
    
    return resonance

func calculate_word_resonance(word, stage):
    # Calculate how much a word resonates with a specific stage
    var base_resonance = 0.1  # Minimum resonance
    var affinities = stage_properties[stage].word_affinities
    
    # Check if word contains any affinity words for this stage
    for affinity in affinities:
        if word.to_lower().contains(affinity.to_lower()):
            base_resonance += 0.3
            print("Word '" + word + "' contains affinity '" + affinity + "' for stage " + str(stage))
    
    # Check if word starts with any affinity word
    for affinity in affinities:
        if word.to_lower().begins_with(affinity.to_lower()):
            base_resonance += 0.2
    
    # Check word length factor (longer words have more potential)
    var length_factor = min(1.0, word.length() / 10.0)
    base_resonance += length_factor * 0.1
    
    # Check for special programming words
    if is_programming_keyword(word):
        base_resonance += 0.2
        print("Programming keyword detected: " + word)
    
    # Limit maximum resonance
    return min(1.0, base_resonance)

func is_programming_keyword(word):
    # Check if word is a common programming keyword
    var keywords = [
        "var", "if", "else", "for", "while", "func", "return", "class",
        "extends", "signal", "emit", "export", "static", "const",
        "match", "break", "continue", "pass", "null", "true", "false"
    ]
    
    return keywords.has(word.to_lower())

func _on_limb_evolved(limb_id, stage, type):
    # When a limb evolves, add progress to the numeric system
    var bonus_progress = 20.0 * (stage + 1)
    print("Limb evolved to stage " + str(stage) + ", adding " + str(bonus_progress) + " to numeric evolution")
    add_evolution_progress(bonus_progress)

func _on_limb_stage_unlocked(stage_number):
    # When limb system unlocks a stage, consider unlocking the same stage here
    if stage_number < NUMERIC_STAGES and not stage_properties[stage_number].unlocked:
        print("Numeric stage " + str(stage_number) + " unlocked due to limb evolution")
        stage_properties[stage_number].unlocked = true

func _on_word_caught(source, word):
    # When memory system catches a word, process it
    if source == "openai" or source == "claude" or source == "gemini":
        # Words from AI APIs get a boost
        process_word(word, "crystal")
    else:
        process_word(word)

func _on_security_level_changed(old_level, new_level):
    # When firewall upgrades, add evolution progress
    var bonus_progress = 15.0 * (new_level + 1)
    print("Security upgraded to level " + str(new_level) + ", adding " + str(bonus_progress) + " to numeric evolution")
    add_evolution_progress(bonus_progress)

func get_current_stage_info():
    # Return information about the current stage
    var info = {
        "number": current_stage,
        "symbol": GREEK_SYMBOLS[current_stage],
        "name": STAGE_NAMES[current_stage],
        "progress": evolution_progress,
        "threshold": stage_properties[current_stage].evolution_threshold,
        "progress_percentage": evolution_progress / stage_properties[current_stage].evolution_threshold * 100.0,
        "affinities": stage_properties[current_stage].word_affinities,
        "element_boosts": stage_properties[current_stage].element_boost,
        "abilities": stage_properties[current_stage].special_abilities
    }
    
    return info