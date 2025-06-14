extends Node
class_name DualMemoriesCoordinator

"""
DualMemoriesCoordinator
-----------------------
Coordinates between WordMemorySystem and WishKnowledgeSystem to create a dual memory pathway.
This system enables:
1. Cross-memory meaning transformations
2. Parallel processing of language across both systems
3. Dynamic terminal splitting based on memory state
4. Catchphrase-based word transformation

The system is built on the concept of 'hatching data' - where meanings and interpretations
evolve and change across different memory contexts, creating an infinite variety of
possible interpretations and meanings.
"""

# Memory system references
var word_memory_system: WordMemorySystem
var wish_knowledge_system: WishKnowledgeSystem
var memory_channel_system: MemoryChannelSystem
var dual_core_terminal: DualCoreTerminal

# Configuration constants
const MAX_TRANSFORMATION_DEPTH = 5
const MIN_TRANSFORMATION_CONFIDENCE = 0.6
const CATCHPHRASE_PATTERN_MATCH_THRESHOLD = 0.7

# Memory state tracking
var memory_crossover_points = {}
var meaning_transformation_cache = {}
var active_memory_channels = []
var terminal_configurations = {}

# Dynamic system states
var is_hatching_active = false
var current_transformation_mode = "balanced" # "word_dominant", "wish_dominant", "balanced", "random"
var current_terminal_split_mode = "dual" # "single", "dual", "multi"
var meaning_shift_counter = 0
var catchphrase_patterns = []

# Signals
signal meaning_transformed(original_text, transformed_text, source_system)
signal memory_hatched(memory_id, new_meaning)
signal terminal_split_changed(old_config, new_config)
signal catchphrase_detected(pattern, text, strength)

# Initialize the coordinator with required systems
func initialize(word_system: WordMemorySystem, wish_system: WishKnowledgeSystem, 
               channel_system: MemoryChannelSystem = null, terminal_system: DualCoreTerminal = null):
    word_memory_system = word_system
    wish_knowledge_system = wish_system
    memory_channel_system = channel_system
    dual_core_terminal = terminal_system
    
    # Connect signals from memory systems
    if word_memory_system:
        word_memory_system.connect("memory_updated", self, "_on_word_memory_updated")
        word_memory_system.connect("word_remembered", self, "_on_word_remembered")
    
    if wish_knowledge_system:
        wish_knowledge_system.connect("wish_processed", self, "_on_wish_processed")
        wish_knowledge_system.connect("element_created", self, "_on_element_created")
    
    if dual_core_terminal:
        dual_core_terminal.connect("core_switched", self, "_on_terminal_core_switched")
        dual_core_terminal.connect("input_processed", self, "_on_terminal_input_processed")
    
    # Initialize catchphrase patterns
    _initialize_catchphrase_patterns()
    
    # Initialize terminal configurations
    _initialize_terminal_configurations()
    
    print("Dual Memories Coordinator initialized")

# Process text through both memory systems and transform meaning
func process_text(text: String, source: String = "user") -> Dictionary:
    var result = {
        "original_text": text,
        "word_memory_result": null,
        "wish_knowledge_result": null,
        "transformed_meaning": null,
        "confidence": 0.0,
        "terminal_split_required": false,
        "catchphrases_detected": []
    }
    
    # Check for catchphrases first
    var catchphrase_matches = detect_catchphrases(text)
    result.catchphrases_detected = catchphrase_matches
    
    # Process through word memory system
    var word_memory_result = null
    if word_memory_system:
        # Create a simulated message to record in memory
        var message = {
            "type": "text_input",
            "payload": {
                "text": text,
                "source": source
            },
            "timestamp": OS.get_unix_time()
        }
        word_memory_system.record_word_message(message)
        
        # Try to remember any related words
        word_memory_result = word_memory_system.remember_word(text)
    
    # Process through wish knowledge system
    var wish_result = null
    var element_id = null
    if wish_knowledge_system:
        element_id = wish_knowledge_system.process_wish(text)
        if element_id:
            wish_result = wish_knowledge_system.get_element(element_id)
    
    # Store individual system results
    result.word_memory_result = word_memory_result
    result.wish_knowledge_result = wish_result
    
    # Create transformed meaning by combining both memory pathways
    var transformation = transform_meaning(text, word_memory_result, wish_result)
    result.transformed_meaning = transformation.transformed_text
    result.confidence = transformation.confidence
    
    # Cache this transformation
    meaning_transformation_cache[text] = transformation
    
    # Check if this should trigger a terminal split
    result.terminal_split_required = should_split_terminal(text, transformation)
    
    # Emit signal for meaning transformation
    emit_signal("meaning_transformed", text, transformation.transformed_text, source)
    
    # Check if any catchphrases were detected and emit signals
    for catchphrase in catchphrase_matches:
        emit_signal("catchphrase_detected", 
                   catchphrase.pattern, 
                   catchphrase.matched_text, 
                   catchphrase.strength)
    
    return result

# Transform meaning by combining word and wish memory systems
func transform_meaning(text: String, word_memory = null, wish_memory = null) -> Dictionary:
    var transformation = {
        "original_text": text,
        "transformed_text": text,
        "confidence": 0.0,
        "source_system": "none",
        "dimensional_influences": [],
        "word_associations": [],
        "contextual_shifts": []
    }
    
    # If no memory results, return original with low confidence
    if not word_memory and not wish_memory:
        transformation.confidence = 0.1
        return transformation
    
    # Initialize variables for transformation
    var transformed_text = text
    var confidence = 0.0
    var dimensional_influences = []
    var word_associations = []
    var contextual_shifts = []
    
    # Get transformation mode
    var mode = current_transformation_mode
    
    # Apply transformation based on mode
    match mode:
        "word_dominant":
            # Prioritize word memory for transformation
            if word_memory:
                transformed_text = _transform_via_word_memory(text, word_memory)
                confidence = 0.7
                transformation.source_system = "word_memory"
                
                # Add minimal wish system influence if available
                if wish_memory:
                    var element_type = wish_memory.type
                    var element_dimension = wish_memory.dimensional_plane
                    dimensional_influences.append({
                        "dimension": element_dimension,
                        "influence_strength": 0.3
                    })
                    
                    # Apply subtle modifications based on wish system
                    transformed_text = _apply_dimensional_influence(transformed_text, element_dimension, 0.3)
            elif wish_memory:
                # Fallback to wish system if word memory has nothing
                transformed_text = _transform_via_wish_knowledge(text, wish_memory)
                confidence = 0.5
                transformation.source_system = "wish_knowledge"
        
        "wish_dominant":
            # Prioritize wish knowledge for transformation
            if wish_memory:
                transformed_text = _transform_via_wish_knowledge(text, wish_memory)
                confidence = 0.7
                transformation.source_system = "wish_knowledge"
                
                # Add minimal word memory influence if available
                if word_memory:
                    for connection in word_memory.connections.slice(0, min(3, word_memory.connections.size() - 1)):
                        word_associations.append({
                            "word_id": connection.target_id,
                            "strength": connection.strength * 0.3
                        })
                    
                    # Apply subtle modifications based on word memory
                    transformed_text = _apply_word_associations(transformed_text, word_associations)
            elif word_memory:
                # Fallback to word memory if wish system has nothing
                transformed_text = _transform_via_word_memory(text, word_memory)
                confidence = 0.5
                transformation.source_system = "word_memory"
        
        "balanced":
            # Equal influence from both systems
            var word_contribution = ""
            var wish_contribution = ""
            
            if word_memory:
                word_contribution = _transform_via_word_memory(text, word_memory)
                
                # Extract word associations
                for connection in word_memory.connections.slice(0, min(5, word_memory.connections.size() - 1)):
                    word_associations.append({
                        "word_id": connection.target_id,
                        "strength": connection.strength * 0.5
                    })
            
            if wish_memory:
                wish_contribution = _transform_via_wish_knowledge(text, wish_memory)
                
                # Extract dimensional influences
                var element_dimension = wish_memory.dimensional_plane
                dimensional_influences.append({
                    "dimension": element_dimension,
                    "influence_strength": 0.5
                })
            
            # Merge the contributions
            if word_contribution and wish_contribution:
                # For interesting combination, alternate words or phrases
                transformed_text = _merge_transformations(word_contribution, wish_contribution)
                confidence = 0.8
                transformation.source_system = "dual"
            elif word_contribution:
                transformed_text = word_contribution
                confidence = 0.6
                transformation.source_system = "word_memory"
            elif wish_contribution:
                transformed_text = wish_contribution
                confidence = 0.6
                transformation.source_system = "wish_knowledge"
        
        "random":
            # Random mixture and unexpected combinations
            var rand_factor = randf()
            
            if rand_factor < 0.4 and word_memory:
                # Word memory dominant with random elements
                transformed_text = _transform_via_word_memory(text, word_memory)
                
                # Add random noise
                transformed_text = _add_random_transformation(transformed_text, 0.3)
                
                confidence = 0.5
                transformation.source_system = "word_memory_random"
                
            elif rand_factor < 0.8 and wish_memory:
                # Wish knowledge dominant with random elements
                transformed_text = _transform_via_wish_knowledge(text, wish_memory)
                
                # Add random noise
                transformed_text = _add_random_transformation(transformed_text, 0.3)
                
                confidence = 0.5
                transformation.source_system = "wish_knowledge_random"
                
            else:
                # Pure random transformation
                transformed_text = _add_random_transformation(text, 0.7)
                confidence = 0.3
                transformation.source_system = "pure_random"
            
            # Add contextual shifts that represent random influences
            contextual_shifts.append({
                "type": "random_influence",
                "strength": rand_factor
            })
    
    # Detect if there was a meaning shift
    if transformed_text != text:
        meaning_shift_counter += 1
    
    # Store the transformation details
    transformation.transformed_text = transformed_text
    transformation.confidence = confidence
    transformation.dimensional_influences = dimensional_influences
    transformation.word_associations = word_associations
    transformation.contextual_shifts = contextual_shifts
    
    return transformation

# Detect catchphrases in text
func detect_catchphrases(text: String) -> Array:
    var matches = []
    
    for pattern in catchphrase_patterns:
        var pattern_text = pattern.text
        var pattern_type = pattern.type
        var pattern_effect = pattern.effect
        
        # Different matching strategies based on pattern type
        var strength = 0.0
        var matched_text = ""
        
        match pattern_type:
            "exact":
                # Exact catchphrase match
                if text.find(pattern_text) >= 0:
                    strength = 1.0
                    matched_text = pattern_text
            
            "fuzzy":
                # Fuzzy matching using Levenshtein distance or similar
                var similarity = _calculate_text_similarity(text, pattern_text)
                if similarity >= CATCHPHRASE_PATTERN_MATCH_THRESHOLD:
                    strength = similarity
                    matched_text = pattern_text
            
            "semantic":
                # Semantic matching based on meaning rather than exact text
                # This would typically use more advanced NLP, but we'll simulate
                var words = text.to_lower().split(" ")
                var pattern_words = pattern_text.to_lower().split(" ")
                
                var matching_words = 0
                for word in pattern_words:
                    if words.has(word):
                        matching_words += 1
                
                if pattern_words.size() > 0:
                    strength = float(matching_words) / pattern_words.size()
                    
                    if strength >= CATCHPHRASE_PATTERN_MATCH_THRESHOLD:
                        matched_text = pattern_text
        
        # If match found, add to results
        if strength >= CATCHPHRASE_PATTERN_MATCH_THRESHOLD:
            matches.append({
                "pattern": pattern_text,
                "pattern_type": pattern_type,
                "effect": pattern_effect,
                "strength": strength,
                "matched_text": matched_text
            })
    
    return matches

# Add a new catchphrase pattern for detection
func add_catchphrase_pattern(text: String, type: String = "exact", effect: Dictionary = {}) -> bool:
    # Validate inputs
    if text.empty():
        return false
    
    if not type in ["exact", "fuzzy", "semantic"]:
        type = "exact"
    
    # Create pattern
    var pattern = {
        "text": text,
        "type": type,
        "effect": effect,
        "created_at": OS.get_unix_time()
    }
    
    # Add to collection
    catchphrase_patterns.append(pattern)
    return true

# Check if terminal should be split based on text and transformation
func should_split_terminal(text: String, transformation: Dictionary) -> bool:
    # Simple logic: if confidence is high and there's a significant transformation,
    # we might want to split the terminal to show both perspectives
    
    # Don't split if we already have multiple terminals active in dual mode
    if current_terminal_split_mode != "single" and dual_core_terminal and dual_core_terminal.cores.size() > 1:
        return false
    
    var original = text
    var transformed = transformation.transformed_text
    
    # If transformation significantly changed the text and has decent confidence
    if original != transformed and transformation.confidence >= 0.6:
        # Text length difference check
        var length_diff = abs(original.length() - transformed.length())
        var avg_length = (original.length() + transformed.length()) / 2.0
        
        if length_diff / avg_length > 0.3:  # More than 30% different in length
            return true
        
        # Word count change check
        var original_words = original.split(" ").size()
        var transformed_words = transformed.split(" ").size()
        
        if abs(original_words - transformed_words) >= 2:
            return true
    
    return false

# Split terminal to display dual memory perspectives
func split_terminal(config: String = "dual") -> bool:
    if not dual_core_terminal:
        return false
    
    var old_config = current_terminal_split_mode
    
    # Apply the requested configuration
    match config:
        "single":
            # Revert to single terminal if not already
            if dual_core_terminal.cores.size() > 1:
                # Focus on core 0
                dual_core_terminal.switch_core(0)
                current_terminal_split_mode = "single"
            
        "dual":
            # Create/ensure we have two terminals
            if not dual_core_terminal.cores.has(1):
                dual_core_terminal.create_core(1, "Memory Core")
            
            # Set different bracket styles for the two cores
            if dual_core_terminal.cores.has(0):
                dual_core_terminal.cores[0].bracket_style = "blue"
            
            if dual_core_terminal.cores.has(1):
                dual_core_terminal.cores[1].bracket_style = "green"
            
            # Activate core 0
            dual_core_terminal.switch_core(0)
            current_terminal_split_mode = "dual"
        
        "multi":
            # Create four terminals for different perspectives
            for i in range(4):
                if not dual_core_terminal.cores.has(i):
                    var name = "Core " + str(i)
                    match i:
                        0: name = "Word Core"
                        1: name = "Wish Core"
                        2: name = "Hybrid Core"
                        3: name = "Random Core"
                    
                    dual_core_terminal.create_core(i, name)
            
            # Set different styles for each core
            var styles = ["blue", "green", "purple", "gold"]
            for i in range(4):
                if dual_core_terminal.cores.has(i):
                    dual_core_terminal.cores[i].bracket_style = styles[i]
            
            # Activate core 0
            dual_core_terminal.switch_core(0)
            current_terminal_split_mode = "multi"
    
    # Emit signal about configuration change
    if old_config != current_terminal_split_mode:
        emit_signal("terminal_split_changed", old_config, current_terminal_split_mode)
    
    return true

# Set the transformation mode
func set_transformation_mode(mode: String) -> bool:
    if mode in ["word_dominant", "wish_dominant", "balanced", "random"]:
        current_transformation_mode = mode
        return true
    return false

# Trigger data hatching process
func hatch_data(text: String, force_mode: String = "") -> Dictionary:
    is_hatching_active = true
    
    # Save original mode and set temporary mode for hatching
    var original_mode = current_transformation_mode
    if force_mode:
        current_transformation_mode = force_mode
    
    # Process with increased randomness and depth
    var result = process_text(text, "hatching")
    
    # Apply memory cross-pollination
    var crossover_data = _create_memory_crossover(result.word_memory_result, result.wish_knowledge_result)
    
    # Store crossover point for future reference
    if crossover_data:
        memory_crossover_points[OS.get_unix_time()] = crossover_data
    
    # Restore original mode
    current_transformation_mode = original_mode
    is_hatching_active = false
    
    # Add hatching results to result
    result["hatching_data"] = {
        "crossover_created": crossover_data != null,
        "crossover_id": crossover_data.id if crossover_data else "",
        "hatching_strength": randf() * 0.5 + 0.5  # Random value between 0.5 and 1.0
    }
    
    # Emit signal for successful hatching
    if crossover_data:
        emit_signal("memory_hatched", crossover_data.id, result.transformed_meaning)
    
    return result

# Helper method to transform text using word memory system
func _transform_via_word_memory(text: String, word_memory) -> String:
    if not word_memory:
        return text
    
    var transformed = text
    
    # Use connections to influence the text
    if word_memory.connections and word_memory.connections.size() > 0:
        # Get relevant connections
        var connections = []
        for i in range(min(3, word_memory.connections.size())):
            connections.append(word_memory.connections[i])
        
        # Simple transformation: insert connected words
        for connection in connections:
            var target_id = connection.target_id
            var target_memory = word_memory_system.get_word_memory(target_id)
            
            if target_memory and target_memory.text:
                # Simple contextual insertion
                transformed = transformed + " " + target_memory.text
    
    # Consider dimensional history
    if word_memory.dimension_history and word_memory.dimension_history.size() > 0:
        var current_dimension = word_memory.dimension_history[word_memory.dimension_history.size() - 1].dimension
        
        # Simple dimension-based formatting
        match current_dimension:
            "3D": 
                transformed = transformed.to_upper()
            "4D": 
                transformed = transformed + " (across time)"
            "5D": 
                transformed = transformed + " (in consciousness)"
            "12D": 
                transformed = "DIVINE: " + transformed
    
    return transformed

# Helper method to transform text using wish knowledge system
func _transform_via_wish_knowledge(text: String, wish_element) -> String:
    if not wish_element:
        return text
    
    var transformed = text
    
    # Include element type influence
    if wish_element.type != null:
        var type_prefix = ""
        match wish_element.type:
            WishKnowledgeSystem.ElementType.CHARACTER:
                type_prefix = "Character: "
            WishKnowledgeSystem.ElementType.LOCATION:
                type_prefix = "Place: "
            WishKnowledgeSystem.ElementType.ITEM:
                type_prefix = "Item: "
            WishKnowledgeSystem.ElementType.ABILITY:
                type_prefix = "Power: "
            WishKnowledgeSystem.ElementType.MECHANIC:
                type_prefix = "System: "
        
        if type_prefix:
            transformed = type_prefix + transformed
    
    # Include dimensional influence
    if wish_element.dimensional_plane != null:
        transformed = _apply_dimensional_influence(transformed, wish_element.dimensional_plane, 0.7)
    
    # Include properties influence
    if wish_element.properties:
        # Add some property-based modifications
        for property_name in wish_element.properties:
            var property_value = wish_element.properties[property_name]
            
            if property_name == "complexity" and typeof(property_value) == TYPE_INT:
                # Add complexity indicator
                match property_value:
                    WishKnowledgeSystem.WishComplexity.SIMPLE:
                        # No change for simple
                        pass
                    WishKnowledgeSystem.WishComplexity.MODERATE:
                        transformed = transformed + " (moderately complex)"
                    WishKnowledgeSystem.WishComplexity.COMPLEX:
                        transformed = transformed + " (complex)"
                    WishKnowledgeSystem.WishComplexity.VERY_COMPLEX:
                        transformed = transformed + " (very complex)"
                    WishKnowledgeSystem.WishComplexity.REVOLUTIONARY:
                        transformed = "REVOLUTIONARY: " + transformed
    
    return transformed

# Merge two different transformations with interesting patterns
func _merge_transformations(word_contrib: String, wish_contrib: String) -> String:
    # If either contribution is empty, return the other
    if word_contrib.empty():
        return wish_contrib
    elif wish_contrib.empty():
        return word_contrib
    
    # Split into words
    var word_parts = word_contrib.split(" ")
    var wish_parts = wish_contrib.split(" ")
    
    # Simple strategy: alternate words
    var result = ""
    var max_parts = max(word_parts.size(), wish_parts.size())
    
    for i in range(max_parts):
        if i < word_parts.size():
            result += word_parts[i] + " "
        
        if i < wish_parts.size():
            result += wish_parts[i] + " "
    
    return result.strip_edges()

# Apply dimensional influence to text
func _apply_dimensional_influence(text: String, dimension: int, strength: float) -> String:
    var transformed = text
    
    # Early return if strength is too low
    if strength < 0.1:
        return transformed
    
    # Apply dimension-specific transformations
    match dimension:
        WishKnowledgeSystem.DimensionalPlane.REALITY:
            # Concrete, specific
            transformed = transformed + " (concrete)"
        
        WishKnowledgeSystem.DimensionalPlane.LINEAR:
            # Sequential, ordered
            transformed = transformed + " → next step"
        
        WishKnowledgeSystem.DimensionalPlane.SPATIAL:
            # Space, environment
            transformed = transformed + " [in space]"
        
        WishKnowledgeSystem.DimensionalPlane.TEMPORAL:
            # Time-related
            transformed = transformed + " (across time)"
        
        WishKnowledgeSystem.DimensionalPlane.CONSCIOUS:
            # Awareness, mind
            transformed = transformed + " (in consciousness)"
        
        WishKnowledgeSystem.DimensionalPlane.CONNECTION:
            # Relationships, connections
            transformed = transformed + " <connected>"
        
        WishKnowledgeSystem.DimensionalPlane.CREATION:
            # Creation, generation
            transformed = "CREATE: " + transformed
        
        WishKnowledgeSystem.DimensionalPlane.NETWORK:
            # Systems, networks
            transformed = transformed + " {in the network}"
        
        WishKnowledgeSystem.DimensionalPlane.HARMONY:
            # Balance, harmony
            transformed = "Balanced: " + transformed
        
        WishKnowledgeSystem.DimensionalPlane.UNITY:
            # Wholeness, integration
            transformed = "UNIFIED: " + transformed
        
        WishKnowledgeSystem.DimensionalPlane.TRANSCENDENT:
            # Beyond, transcend
            transformed = "TRANSCENDENT: " + transformed
        
        WishKnowledgeSystem.DimensionalPlane.BEYOND:
            # Mysterious, ineffable
            transformed = "∞ " + transformed + " ∞"
    
    return transformed

# Apply word associations to text
func _apply_word_associations(text: String, associations: Array) -> String:
    var transformed = text
    
    # Don't modify if no associations
    if associations.size() == 0:
        return transformed
    
    # Add associated words
    var addition = " ["
    for i in range(associations.size()):
        var assoc = associations[i]
        var word_id = assoc.word_id
        var word_memory = word_memory_system.get_word_memory(word_id)
        
        if word_memory and word_memory.text:
            addition += word_memory.text
            
            if i < associations.size() - 1:
                addition += ", "
    
    addition += "]"
    transformed += addition
    
    return transformed

# Add random transformation elements
func _add_random_transformation(text: String, intensity: float) -> String:
    var transformed = text
    
    # Intensity controls how much randomness to apply
    if intensity <= 0:
        return transformed
    
    # Random prefix
    var prefixes = ["ECHO: ", "VISION: ", "DREAM: ", "PULSE: ", "WAVE: "]
    if randf() < intensity * 0.5:
        transformed = prefixes[randi() % prefixes.size()] + transformed
    
    # Random suffix
    var suffixes = [" (echoing)", " [shifting]", " {resonating}", " <transforming>", " /oscillating/"]
    if randf() < intensity * 0.5:
        transformed = transformed + suffixes[randi() % suffixes.size()]
    
    # Word substitution (more extreme)
    if randf() < intensity * 0.3:
        var words = transformed.split(" ")
        if words.size() > 2:
            var random_index = randi() % words.size()
            var random_words = ["infinity", "cosmos", "dream", "reality", "void", "light", "shadow", "essence"]
            words[random_index] = random_words[randi() % random_words.size()]
            
            transformed = ""
            for word in words:
                transformed += word + " "
            transformed = transformed.strip_edges()
    
    return transformed

# Create a memory crossover point between two memory systems
func _create_memory_crossover(word_memory, wish_element) -> Dictionary:
    if not word_memory or not wish_element:
        return null
    
    # Generate a unique crossover ID
    var crossover_id = "crossover_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Create the crossover data structure
    var crossover = {
        "id": crossover_id,
        "word_memory_id": word_memory.id,
        "wish_element_id": wish_element.id,
        "creation_time": OS.get_unix_time(),
        "dimensional_plane": wish_element.dimensional_plane,
        "word_dimension": word_memory.dimension_history[word_memory.dimension_history.size() - 1].dimension if word_memory.dimension_history.size() > 0 else "3D",
        "properties": {}
    }
    
    return crossover

# Calculate text similarity (simplified)
func _calculate_text_similarity(text1: String, text2: String) -> float:
    var t1 = text1.to_lower()
    var t2 = text2.to_lower()
    
    # Exact match
    if t1 == t2:
        return 1.0
    
    # Contains check
    if t1.find(t2) >= 0:
        return 0.9
    elif t2.find(t1) >= 0:
        return 0.9
    
    # Word-based similarity
    var words1 = t1.split(" ")
    var words2 = t2.split(" ")
    
    var common_count = 0
    for word in words1:
        if words2.has(word):
            common_count += 1
    
    var max_words = max(words1.size(), words2.size())
    if max_words == 0:
        return 0.0
    
    return float(common_count) / max_words

# Initialize catchphrase patterns
func _initialize_catchphrase_patterns():
    # Core catchphrases from initial request
    add_catchphrase_pattern("hatching of data", "exact", {"effect": "trigger_hatching", "strength": 1.0})
    add_catchphrase_pattern("catchphrase system", "exact", {"effect": "add_new_pattern", "strength": 0.8})
    add_catchphrase_pattern("changing meanings", "fuzzy", {"effect": "meaning_shift", "strength": 0.7})
    add_catchphrase_pattern("infinite way", "exact", {"effect": "dimensional_shift", "strength": 0.9})
    add_catchphrase_pattern("dual memories", "exact", {"effect": "terminal_split", "strength": 0.9})
    add_catchphrase_pattern("shape inte", "fuzzy", {"effect": "reshape_memory", "strength": 0.6})
    
    # Hidden catchphrases based on the user memory input
    add_catchphrase_pattern("0000000000000000000000000000000000000000000000000000000000000", "exact", {"effect": "reveal_zero_memory", "strength": 1.0})
    add_catchphrase_pattern("11111111111111111111111111111111111111111111111@", "exact", {"effect": "reveal_one_memory", "strength": 1.0})
    add_catchphrase_pattern("22222222222222222222222222222222222222####", "exact", {"effect": "reveal_two_memory", "strength": 1.0})
    add_catchphrase_pattern("#", "semantic", {"effect": "hash_trigger", "strength": 0.5})
    add_catchphrase_pattern("@", "semantic", {"effect": "entity_trigger", "strength": 0.5})

# Initialize terminal configurations
func _initialize_terminal_configurations():
    # Single terminal configuration
    terminal_configurations["single"] = {
        "cores": 1,
        "active_core": 0,
        "styles": ["default"],
        "states": [DualCoreTerminal.WindowState.ACTIVE]
    }
    
    # Dual terminal configuration
    terminal_configurations["dual"] = {
        "cores": 2,
        "active_core": 0,
        "styles": ["blue", "green"],
        "states": [DualCoreTerminal.WindowState.ACTIVE, DualCoreTerminal.WindowState.BACKGROUND]
    }
    
    # Multi terminal configuration
    terminal_configurations["multi"] = {
        "cores": 4,
        "active_core": 0,
        "styles": ["blue", "green", "purple", "gold"],
        "states": [
            DualCoreTerminal.WindowState.ACTIVE,
            DualCoreTerminal.WindowState.BACKGROUND,
            DualCoreTerminal.WindowState.WAITING,
            DualCoreTerminal.WindowState.BACKGROUND
        ]
    }

# Event handlers
func _on_word_memory_updated(word_id, memory_data):
    # When word memory is updated, we can potentially trigger meaning transformations
    if is_hatching_active:
        # During hatching, memory updates can have special handling
        print("Word memory updated during hatching: ", word_id)
    
func _on_word_remembered(word_id, memory_quality):
    # When a word is remembered, we can use this to adjust transformations
    print("Word remembered: ", word_id, " (quality: ", memory_quality, ")")

func _on_wish_processed(wish_id, intent):
    # When a wish is processed, we can potentially use this for integration
    print("Wish processed: ", wish_id)

func _on_element_created(element_id, element_type):
    # When a game element is created from a wish, we can track it
    print("Element created: ", element_id, " (type: ", element_type, ")")

func _on_terminal_core_switched(from_core, to_core):
    # When terminal cores are switched, we can update our state
    print("Terminal core switched from ", from_core, " to ", to_core)

func _on_terminal_input_processed(core_id, text, result):
    # When terminal input is processed, potentially process through dual memories
    process_text(text, "terminal_" + str(core_id))