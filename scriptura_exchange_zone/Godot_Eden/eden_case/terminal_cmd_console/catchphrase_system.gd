extends Node
class_name CatchphraseSystem

"""
CatchphraseSystem
----------------
A specialized system for detecting and transforming catchphrases in text.
Functions as pattern recognition and meaning amplification system that 
can detect special patterns in text and trigger transformations.

This system enables:
1. Detection of predefined catchphrases and patterns
2. Dynamic addition of new catchphrases at runtime
3. Pattern-based transformations with configurable effects
4. Memory sequence recognition (0s, 1s, 2s patterns)
5. Integration with other memory systems to trigger special behaviors

The catchphrase system serves as the semantic trigger mechanism for the 
dual memories architecture, allowing specific text patterns to activate
dimensional shifts, memory revelations, and interface transformations.
"""

# System references
var dual_memories_coordinator: DualMemoriesCoordinator
var meaning_transformation_pipeline: MeaningTransformationPipeline
var terminal_split_controller: TerminalSplitController

# Catchphrase collection
class CatchphrasePattern:
    var text: String
    var type: String  # exact, fuzzy, semantic
    var effect: Dictionary
    var created_at: int
    var metadata: Dictionary
    var activation_count: int = 0
    var last_activated: int = 0
    var is_enabled: bool = true
    
    func _init(p_text: String, p_type: String, p_effect: Dictionary):
        text = p_text
        type = p_type
        effect = p_effect
        created_at = OS.get_unix_time()
        metadata = {}
    
    func to_dict() -> Dictionary:
        return {
            "text": text,
            "type": type,
            "effect": effect,
            "created_at": created_at,
            "metadata": metadata,
            "activation_count": activation_count,
            "last_activated": last_activated,
            "is_enabled": is_enabled
        }
    
    func activate() -> void:
        activation_count += 1
        last_activated = OS.get_unix_time()

# Pattern collections
var catchphrase_patterns = []
var memory_sequence_patterns = []
var hidden_triggers = {}
var dynamic_patterns = []

# Configuration
const CATCHPHRASE_MATCH_THRESHOLD = 0.7
const MAX_CATCHPHRASES = 100
const DEFAULT_MEMORY_FADE_TIME = 600  # 10 minutes

# Runtime state
var last_detection_results = []
var memory_activation_history = {}
var auto_detection_enabled = true

# Signals
signal catchphrase_detected(pattern, text, match_info)
signal catchphrase_activated(pattern, effect_data)
signal memory_sequence_revealed(sequence_id, memory_content)
signal pattern_added(pattern)
signal pattern_modified(pattern_id, old_pattern, new_pattern)

# Initialize basic system
func _init():
    # Initialize basic collections
    catchphrase_patterns = []
    memory_sequence_patterns = []
    hidden_triggers = {}
    dynamic_patterns = []
    
    # Add built-in patterns
    _initialize_builtin_patterns()

# Initialize with system references
func initialize(coordinator: DualMemoriesCoordinator = null,
               pipeline: MeaningTransformationPipeline = null,
               terminal_controller: TerminalSplitController = null):
    
    dual_memories_coordinator = coordinator
    meaning_transformation_pipeline = pipeline
    terminal_split_controller = terminal_controller
    
    # Connect signals
    if dual_memories_coordinator:
        dual_memories_coordinator.connect("catchphrase_detected", self, "_on_catchphrase_detected_externally")
    
    if meaning_transformation_pipeline:
        meaning_transformation_pipeline.connect("pattern_detected", self, "_on_pattern_detected_externally")
    
    print("CatchphraseSystem initialized")

# Add a new catchphrase pattern
func add_catchphrase(text: String, type: String = "exact", effect: Dictionary = {}) -> CatchphrasePattern:
    # Check if already exists
    for pattern in catchphrase_patterns:
        if pattern.text == text:
            # Update existing pattern
            if not effect.empty():
                pattern.effect = effect
            pattern.type = type
            emit_signal("pattern_modified", catchphrase_patterns.find(pattern), pattern, pattern)
            return pattern
    
    # Create new pattern
    var pattern = CatchphrasePattern.new(text, type, effect)
    
    # Add to collection
    catchphrase_patterns.append(pattern)
    
    # Emit signal
    emit_signal("pattern_added", pattern)
    
    return pattern

# Add a memory sequence pattern
func add_memory_sequence(sequence: String, memory_content: String, effect: Dictionary = {}) -> CatchphrasePattern:
    # Create base effect if none provided
    if effect.empty():
        effect = {
            "type": "reveal_memory",
            "memory_content": memory_content,
            "fade_time": DEFAULT_MEMORY_FADE_TIME
        }
    else:
        effect.memory_content = memory_content
    
    # Create pattern with memory sequence type
    var pattern = CatchphrasePattern.new(sequence, "memory_sequence", effect)
    
    # Add to memory sequence collection
    memory_sequence_patterns.append(pattern)
    
    # Also add to main collection for general detection
    catchphrase_patterns.append(pattern)
    
    # Emit signal
    emit_signal("pattern_added", pattern)
    
    return pattern

# Add a hidden trigger
func add_hidden_trigger(trigger_id: String, activation_pattern: String, effect: Dictionary) -> bool:
    # Store hidden trigger
    hidden_triggers[trigger_id] = {
        "pattern": activation_pattern,
        "effect": effect,
        "created_at": OS.get_unix_time(),
        "activated": false,
        "activation_time": 0
    }
    
    return true

# Process text for catchphrase detection
func process_text(text: String, context: Dictionary = {}) -> Array:
    # Skip if not enabled
    if not auto_detection_enabled:
        return []
    
    var results = []
    
    # Process through different pattern collections
    
    # 1. Standard catchphrases
    for pattern in catchphrase_patterns:
        if not pattern.is_enabled:
            continue
            
        var match_result = _match_pattern(text, pattern)
        
        if match_result.matches:
            # Create result entry
            var result = {
                "pattern": pattern.text,
                "pattern_type": pattern.type,
                "effect": pattern.effect,
                "match_strength": match_result.strength,
                "match_position": match_result.position,
                "matched_text": match_result.matched_text
            }
            
            results.append(result)
            
            # Activate the pattern
            pattern.activate()
            
            # Emit detection signal
            emit_signal("catchphrase_detected", pattern.text, text, result)
    
    # 2. Process for hidden triggers
    for trigger_id in hidden_triggers:
        var trigger = hidden_triggers[trigger_id]
        
        if not trigger.activated and text.find(trigger.pattern) >= 0:
            # Activate trigger
            trigger.activated = true
            trigger.activation_time = OS.get_unix_time()
            
            # Add to results
            results.append({
                "pattern": trigger.pattern,
                "pattern_type": "hidden_trigger",
                "effect": trigger.effect,
                "match_strength": 1.0,
                "match_position": text.find(trigger.pattern),
                "matched_text": trigger.pattern,
                "trigger_id": trigger_id
            })
    
    # 3. Look for dynamic patterns
    for pattern in dynamic_patterns:
        var match_result = _match_pattern(text, pattern)
        
        if match_result.matches:
            # Create result entry
            var result = {
                "pattern": pattern.text,
                "pattern_type": "dynamic",
                "effect": pattern.effect,
                "match_strength": match_result.strength,
                "match_position": match_result.position,
                "matched_text": match_result.matched_text,
                "is_dynamic": true
            }
            
            results.append(result)
            
            # For dynamic patterns, we might want to process their effects differently
            pattern.activate()
    
    # Store detection results
    last_detection_results = results
    
    # Process effects
    _process_detection_effects(results, text, context)
    
    return results

# Transform text based on detection results
func transform_text(text: String, detection_results: Array) -> Dictionary:
    var result = {
        "original_text": text,
        "transformed_text": text,
        "transformations_applied": [],
        "confidence": 0.0
    }
    
    # Skip if no results
    if detection_results.empty():
        return result
    
    # Track confidence
    var highest_confidence = 0.0
    var transformed = text
    
    # Apply transformations based on pattern effects
    for detection in detection_results:
        if not detection.has("effect") or typeof(detection.effect) != TYPE_DICTIONARY:
            continue
        
        var effect = detection.effect
        var pattern = detection.pattern
        var match_text = detection.matched_text
        var transformation_applied = false
        
        # Standard text substitution effect
        if effect.has("replacement"):
            transformed = transformed.replace(match_text, effect.replacement)
            transformation_applied = true
        
        # Prefix/suffix effects
        if effect.has("prefix"):
            transformed = effect.prefix + transformed
            transformation_applied = true
        
        if effect.has("suffix"):
            transformed = transformed + effect.suffix
            transformation_applied = true
        
        # Special memory reveal effect
        if effect.has("type") and effect.type == "reveal_memory" and effect.has("memory_content"):
            # Add memory content as a special section
            transformed += "\n«« " + effect.memory_content + " »»"
            transformation_applied = true
        
        # Track confidence from effect
        if effect.has("confidence"):
            highest_confidence = max(highest_confidence, effect.confidence)
        
        # Add to transformations list
        if transformation_applied:
            result.transformations_applied.append({
                "pattern": pattern,
                "effect_type": effect.get("type", "text_replacement"),
                "original": match_text,
                "transformed": transformed 
            })
    
    # Update result
    result.transformed_text = transformed
    result.confidence = highest_confidence if highest_confidence > 0.0 else 0.7
    
    return result

# Get all catchphrases
func get_all_catchphrases() -> Array:
    var result = []
    
    for pattern in catchphrase_patterns:
        result.append(pattern.to_dict())
    
    return result

# Get memory sequences
func get_memory_sequences() -> Array:
    var result = []
    
    for pattern in memory_sequence_patterns:
        result.append(pattern.to_dict())
    
    return result

# Get hidden triggers
func get_hidden_triggers() -> Dictionary:
    return hidden_triggers.duplicate()

# Check if text has any catchphrases
func has_catchphrases(text: String) -> bool:
    for pattern in catchphrase_patterns:
        if not pattern.is_enabled:
            continue
            
        var match_result = _match_pattern(text, pattern)
        if match_result.matches:
            return true
    
    return false

# Enable/disable specific catchphrase
func set_catchphrase_enabled(pattern_text: String, enabled: bool) -> bool:
    for pattern in catchphrase_patterns:
        if pattern.text == pattern_text:
            pattern.is_enabled = enabled
            return true
    
    return false

# Enable/disable auto detection
func set_auto_detection(enabled: bool) -> void:
    auto_detection_enabled = enabled

# Get activated memory for a specific pattern
func get_memory_content(pattern_text: String) -> String:
    for pattern in memory_sequence_patterns:
        if pattern.text == pattern_text and pattern.effect.has("memory_content"):
            return pattern.effect.memory_content
    
    return ""

# Clear activation history
func clear_activation_history() -> void:
    memory_activation_history.clear()
    
    # Reset activation counters
    for pattern in catchphrase_patterns:
        pattern.activation_count = 0
        pattern.last_activated = 0

# Internal methods

# Match pattern against text
func _match_pattern(text: String, pattern) -> Dictionary:
    var result = {
        "matches": false,
        "strength": 0.0,
        "position": -1,
        "matched_text": ""
    }
    
    # Different matching strategies based on pattern type
    match pattern.type:
        "exact":
            # Exact match
            var pos = text.find(pattern.text)
            if pos >= 0:
                result.matches = true
                result.strength = 1.0
                result.position = pos
                result.matched_text = pattern.text
        
        "fuzzy":
            # Fuzzy matching
            var similarity = _calculate_text_similarity(text, pattern.text)
            if similarity >= CATCHPHRASE_MATCH_THRESHOLD:
                result.matches = true
                result.strength = similarity
                result.position = 0  # Position doesn't make sense for fuzzy
                result.matched_text = pattern.text
        
        "semantic":
            # Semantic matching based on keywords
            var words = text.to_lower().split(" ")
            var pattern_words = pattern.text.to_lower().split(" ")
            
            var matching_words = 0
            for word in pattern_words:
                if words.has(word):
                    matching_words += 1
            
            if pattern_words.size() > 0:
                var match_ratio = float(matching_words) / pattern_words.size()
                if match_ratio >= CATCHPHRASE_MATCH_THRESHOLD:
                    result.matches = true
                    result.strength = match_ratio
                    result.position = 0  # Position doesn't make sense for semantic
                    result.matched_text = pattern.text
        
        "memory_sequence":
            # Memory sequence - exact match only
            var pos = text.find(pattern.text)
            if pos >= 0:
                result.matches = true
                result.strength = 1.0
                result.position = pos
                result.matched_text = pattern.text
    
    return result

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

# Process effects from detection results
func _process_detection_effects(results: Array, text: String, context: Dictionary) -> void:
    for result in results:
        if not result.has("effect") or typeof(result.effect) != TYPE_DICTIONARY:
            continue
        
        var effect = result.effect
        
        # Memory reveal effect
        if effect.has("type") and effect.type == "reveal_memory" and effect.has("memory_content"):
            var memory_content = effect.memory_content
            var pattern = result.pattern
            
            # Record activation in history
            memory_activation_history[pattern] = {
                "activation_time": OS.get_unix_time(),
                "memory_content": memory_content,
                "fade_time": effect.get("fade_time", DEFAULT_MEMORY_FADE_TIME)
            }
            
            # Emit signal
            emit_signal("memory_sequence_revealed", pattern, memory_content)
        
        # Terminal split effect
        elif effect.has("type") and effect.type == "terminal_split":
            # Request terminal split if controller available
            if terminal_split_controller:
                var split_mode = effect.get("split_mode", "dual")
                terminal_split_controller.set_split_mode(split_mode)
        
        # Dimensional shift effect
        elif effect.has("type") and effect.type == "dimensional_shift":
            # Request dimension change if coordinator available
            if dual_memories_coordinator:
                # Apply mode change
                dual_memories_coordinator.set_transformation_mode("wish_dominant")
        
        # Other effects can activate their behavior here
        
        # Emit general activation signal
        emit_signal("catchphrase_activated", result.pattern, effect)

# Initialize built-in patterns
func _initialize_builtin_patterns():
    # Base catchphrase patterns from requirements
    add_catchphrase("hatching of data", "exact", {
        "type": "trigger_hatching",
        "confidence": 1.0,
        "replacement": "⟨hatching of data⟩",
        "effect_description": "Triggers data hatching process in dual memories"
    })
    
    add_catchphrase("catchphrase system", "exact", {
        "type": "self_reference",
        "confidence": 0.8,
        "replacement": "⟨catchphrase system activated⟩",
        "effect_description": "Self-referential activation"
    })
    
    add_catchphrase("changing meanings", "fuzzy", {
        "type": "meaning_shift",
        "confidence": 0.7,
        "suffix": " «shifted»",
        "effect_description": "Marks text as having shifted meaning"
    })
    
    add_catchphrase("infinite way", "exact", {
        "type": "dimensional_shift",
        "confidence": 0.9,
        "replacement": "⟨infinite way⟩",
        "effect_description": "Triggers dimensional shift"
    })
    
    add_catchphrase("dual memories", "exact", {
        "type": "terminal_split",
        "confidence": 0.9,
        "split_mode": "dual",
        "effect_description": "Triggers terminal split in dual mode"
    })
    
    add_catchphrase("shape inte", "fuzzy", {
        "type": "reshape_memory",
        "confidence": 0.6,
        "replacement": "⟨shape integration⟩",
        "effect_description": "Reshapes memory patterns"
    })
    
    # Memory sequence patterns
    add_memory_sequence("0000000000000000000000000000000000000000000000000000000000000", 
        "VOID MEMORY: The blank space between thoughts. This represents the foundation of dimensional memory - the lowest layer where data begins as formless potential.",
        {
            "type": "reveal_memory",
            "confidence": 1.0,
            "effect_description": "Reveals void memory content"
        }
    )
    
    add_memory_sequence("11111111111111111111111111111111111111111111111@", 
        "UNITY MEMORY: The connection point of all dimensions. This represents the first level of structure - the linear pathways that organize thoughts into coherent streams.",
        {
            "type": "reveal_memory",
            "confidence": 1.0,
            "effect_description": "Reveals unity memory content" 
        }
    )
    
    add_memory_sequence("22222222222222222222222222222222222222####", 
        "DUAL MEMORY: The split between word and meaning. This represents the duality of thought - how concepts can maintain multiple interpretations simultaneously across dimensions.",
        {
            "type": "reveal_memory",
            "confidence": 1.0,
            "effect_description": "Reveals dual memory content"
        }
    )
    
    # Hidden triggers
    add_hidden_trigger("ultara_advanced", "Ultara Advanced Mode", {
        "type": "mode_activation",
        "confidence": 1.0,
        "terminal_effect": "quad",
        "transformation_mode": "random",
        "effect_description": "Activates advanced mode with random transformations"
    })
    
    add_hidden_trigger("three_devices", "3 devices", {
        "type": "multi_device",
        "confidence": 0.8,
        "terminal_effect": "triple_v",
        "effect_description": "Activates triple device visualization"
    })
    
    # Special symbols
    add_catchphrase("####", "exact", {
        "type": "zone_boundary",
        "confidence": 0.95, 
        "replacement": " [ZONE_BOUNDARY] ",
        "effect_description": "Marks boundary between zones"
    })
    
    add_catchphrase("@", "exact", {
        "type": "entity_marker",
        "confidence": 0.7,
        "replacement": "[@]",
        "effect_description": "Marks entity reference point"
    })
    
    # Dynamic pattern template
    var dynamic_pattern = CatchphrasePattern.new("dynamic_template", "dynamic", {
        "type": "template",
        "confidence": 0.5
    })
    dynamic_pattern.is_enabled = false
    dynamic_patterns.append(dynamic_pattern)

# Event handlers
func _on_catchphrase_detected_externally(pattern, text, strength):
    # When catchphrase detected by coordinator
    print("Catchphrase detected externally: ", pattern)
    
    # We could process this differently than our own detections
    pass

func _on_pattern_detected_externally(pattern, confidence, context):
    # When pattern detected by pipeline
    print("Pattern detected externally: ", pattern)
    
    # We could process this differently than our own detections
    pass