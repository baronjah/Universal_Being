extends Node
class_name MeaningTransformationPipeline

"""
MeaningTransformationPipeline
-----------------------------
A specialized pipeline that transforms meanings across different memory dimensions,
connecting Claude, Claude Code, desktop applications, consoles, and editors.

This system enables:
1. Cross-system meaning transformations via a multi-stage pipeline
2. Desktop split visualization for parallel data streams
3. Special catchphrase detection and pattern mapping 
4. Integration between different tools and systems

Functions as the data bridge between memory systems, visual interfaces, and interactive controls.
"""

# System references
var dual_memories_coordinator: DualMemoriesCoordinator
var word_memory_system: WordMemorySystem
var wish_knowledge_system: WishKnowledgeSystem
var dual_core_terminal: DualCoreTerminal

# Pipeline configuration
const MAX_PIPELINE_STAGES = 5
const DEFAULT_CONFIDENCE_THRESHOLD = 0.65
const PIPELINE_DEPTH_DEFAULT = 3
const MAX_TRANSFORMATION_ITERATIONS = 3

# Transformation stages
var pipeline_stages = []
var active_transformers = {}
var stage_processors = {}

# Connection state
var connected_systems = {
    "claude": false,
    "claude_code": false,
    "desktop_app": false,
    "console": false,
    "editor": false,
    "whim_processor": false
}

# Visualization configuration
var desktop_split_config = {
    "enabled": false,
    "split_mode": "vertical", # vertical, horizontal, quad
    "panels": [],
    "data_bindings": {}
}

# Runtime state
var is_pipeline_active = false
var current_pipeline_depth = PIPELINE_DEPTH_DEFAULT
var current_iteration = 0
var confidence_threshold = DEFAULT_CONFIDENCE_THRESHOLD
var transformation_cache = {}
var pattern_mapping_table = []

# Signals
signal pipeline_stage_completed(stage_index, input_data, output_data)
signal pipeline_completed(input_data, final_output, confidence)
signal pattern_detected(pattern, confidence, context)
signal system_connected(system_name, connection_state)
signal desktop_split_changed(old_config, new_config)

# Initialize the pipeline
func _init():
    # Create default pipeline stages
    _setup_default_pipeline()
    
# Initialize with external systems
func initialize(dual_mem_coordinator: DualMemoriesCoordinator,
                word_mem: WordMemorySystem = null,
                wish_knowledge: WishKnowledgeSystem = null,
                terminal: DualCoreTerminal = null):
    
    # Store system references
    dual_memories_coordinator = dual_mem_coordinator
    word_memory_system = word_mem
    wish_knowledge_system = wish_knowledge
    dual_core_terminal = terminal
    
    # Connect signals
    if dual_memories_coordinator:
        dual_memories_coordinator.connect("meaning_transformed", self, "_on_meaning_transformed")
        dual_memories_coordinator.connect("catchphrase_detected", self, "_on_catchphrase_detected")
    
    if terminal:
        terminal.connect("input_processed", self, "_on_terminal_input")
        
    # Initialize pattern mapping table    
    _initialize_pattern_mapping()
    
    print("Meaning Transformation Pipeline initialized")

# Process text through the entire transformation pipeline
func process_text(text: String, source: String = "user") -> Dictionary:
    if not is_pipeline_active:
        is_pipeline_active = true
    
    # Reset iteration counter
    current_iteration = 0
    
    # Prepare input data packet
    var data_packet = {
        "original_text": text,
        "current_text": text,
        "source": source,
        "timestamp": OS.get_unix_time(),
        "confidence": 1.0,
        "transformations": [],
        "patterns_detected": [],
        "systems_involved": [source],
        "stage_outputs": {},
        "metadata": {}
    }
    
    # Process through pipeline stages
    for stage_index in range(min(current_pipeline_depth, pipeline_stages.size())):
        var stage_name = pipeline_stages[stage_index]
        var processor = stage_processors[stage_name]
        
        # Process the current stage
        var stage_result = _process_pipeline_stage(stage_name, processor, data_packet)
        
        # Store stage output
        data_packet.stage_outputs[stage_name] = stage_result
        
        # Update current text for next stage
        if stage_result and stage_result.has("transformed_text") and stage_result.confidence >= confidence_threshold:
            data_packet.current_text = stage_result.transformed_text
            data_packet.transformations.append({
                "stage": stage_name,
                "input": data_packet.current_text,
                "output": stage_result.transformed_text,
                "confidence": stage_result.confidence
            })
        
        # Emit signal for stage completion
        emit_signal("pipeline_stage_completed", stage_index, text, data_packet.current_text)
        
        # Check if we should perform iterative transformation
        if stage_result and stage_result.iterate and current_iteration < MAX_TRANSFORMATION_ITERATIONS:
            # Apply additional iterations for deeper transformation
            data_packet = _apply_iterative_transformation(data_packet, stage_name)
    
    # Final result preparation
    var result = {
        "original_text": text,
        "transformed_text": data_packet.current_text,
        "confidence": _calculate_final_confidence(data_packet),
        "transformations": data_packet.transformations,
        "patterns_detected": data_packet.patterns_detected,
        "systems_involved": data_packet.systems_involved,
        "metadata": data_packet.metadata
    }
    
    # Cache this transformation
    transformation_cache[text] = result
    
    # Apply desktop split if needed
    if desktop_split_config.enabled:
        _update_desktop_split_visualization(result)
    
    # Emit completion signal
    emit_signal("pipeline_completed", text, result.transformed_text, result.confidence)
    
    # Reset pipeline state
    is_pipeline_active = false
    
    return result

# Connect to an external system
func connect_system(system_name: String, system_reference = null) -> bool:
    if not connected_systems.has(system_name):
        return false
    
    # Store current state
    var was_connected = connected_systems[system_name]
    
    # Update connection state
    connected_systems[system_name] = system_reference != null
    
    # Emit signal if state changed
    if was_connected != connected_systems[system_name]:
        emit_signal("system_connected", system_name, connected_systems[system_name])
    
    # Configure specialized handlers for this system
    match system_name:
        "claude":
            # Claude API integration
            pass
            
        "claude_code":
            # Claude Code terminal integration
            pass
            
        "desktop_app":
            # Desktop application integration
            if connected_systems[system_name]:
                _setup_desktop_app_integration()
            
        "console":
            # Console integration
            if connected_systems[system_name]:
                _setup_console_integration()
            
        "editor":
            # Editor integration
            if connected_systems[system_name]:
                _setup_editor_integration()
            
        "whim_processor":
            # Whim processing system
            if connected_systems[system_name]:
                _setup_whim_processor()
    
    return true

# Configure desktop split visualization
func configure_desktop_split(enabled: bool, split_mode: String = "vertical") -> bool:
    # Store old config for signal
    var old_config = desktop_split_config.duplicate()
    
    # Update configuration
    desktop_split_config.enabled = enabled
    
    if split_mode in ["vertical", "horizontal", "quad"]:
        desktop_split_config.split_mode = split_mode
    
    # Create panels based on split mode
    _setup_desktop_panels()
    
    # Emit signal
    emit_signal("desktop_split_changed", old_config, desktop_split_config)
    
    return true

# Add a custom transformation stage to the pipeline
func add_transformation_stage(stage_name: String, processor_func: FuncRef, position: int = -1) -> bool:
    if stage_processors.has(stage_name):
        # Stage already exists
        return false
    
    # Register the processor
    stage_processors[stage_name] = processor_func
    
    # Add to pipeline at specified position
    if position >= 0 and position < pipeline_stages.size():
        pipeline_stages.insert(position, stage_name)
    else:
        pipeline_stages.append(stage_name)
    
    return true

# Add a pattern mapping rule
func add_pattern_mapping(pattern: String, mapping_rule: Dictionary) -> bool:
    # Check if pattern already exists
    for existing in pattern_mapping_table:
        if existing.pattern == pattern:
            # Update existing pattern
            existing.mapping_rule = mapping_rule
            return true
    
    # Add new pattern mapping
    pattern_mapping_table.append({
        "pattern": pattern,
        "mapping_rule": mapping_rule,
        "created_at": OS.get_unix_time()
    })
    
    return true

# Set the active pipeline depth
func set_pipeline_depth(depth: int) -> void:
    current_pipeline_depth = clamp(depth, 1, MAX_PIPELINE_STAGES)

# Decode a special pattern based on mapping rules
func decode_pattern(text: String) -> Dictionary:
    var result = {
        "original": text,
        "decoded": text,
        "pattern_matches": [],
        "confidence": 0.0
    }
    
    # Look for pattern matches
    for pattern_map in pattern_mapping_table:
        var pattern = pattern_map.pattern
        var mapping_rule = pattern_map.mapping_rule
        
        # Check for pattern match
        if text.find(pattern) >= 0:
            # Pattern found
            result.pattern_matches.append({
                "pattern": pattern,
                "rule": mapping_rule
            })
            
            # Apply mapping rule
            if mapping_rule.has("replacement"):
                result.decoded = result.decoded.replace(pattern, mapping_rule.replacement)
            
            # Adjust confidence
            if mapping_rule.has("confidence"):
                result.confidence = max(result.confidence, mapping_rule.confidence)
    
    # If no specific confidence set but patterns matched, set a default
    if result.pattern_matches.size() > 0 and result.confidence == 0.0:
        result.confidence = 0.7
    
    return result

# Process pipeline stage
func _process_pipeline_stage(stage_name: String, processor, data_packet: Dictionary) -> Dictionary:
    var result = {
        "transformed_text": data_packet.current_text,
        "confidence": 0.0,
        "iterate": false,
        "metadata": {}
    }
    
    match stage_name:
        "word_memory_transform":
            result = _word_memory_transform_stage(data_packet)
            
        "wish_knowledge_transform":
            result = _wish_knowledge_transform_stage(data_packet)
            
        "catchphrase_processing":
            result = _catchphrase_processing_stage(data_packet)
            
        "pattern_mapping":
            result = _pattern_mapping_stage(data_packet)
            
        "whim_processing":
            result = _whim_processing_stage(data_packet)
            
        "dual_memories_transform":
            result = _dual_memories_transform_stage(data_packet)
            
        "claude_integration":
            result = _claude_integration_stage(data_packet)
            
        _:
            # Custom processor function
            if processor is FuncRef and processor.is_valid():
                var custom_result = processor.call_func(data_packet.current_text, data_packet)
                
                # Handle different return types
                if typeof(custom_result) == TYPE_STRING:
                    result.transformed_text = custom_result
                    result.confidence = 0.7
                elif typeof(custom_result) == TYPE_DICTIONARY:
                    # Assume properly formatted result
                    result = custom_result
    
    return result

# Word memory transform stage
func _word_memory_transform_stage(data_packet: Dictionary) -> Dictionary:
    var result = {
        "transformed_text": data_packet.current_text,
        "confidence": 0.0,
        "iterate": false,
        "metadata": {
            "memories_accessed": 0,
            "connections_followed": 0
        }
    }
    
    # Check if word memory system is available
    if not word_memory_system:
        return result
    
    # Attempt to remember the word
    var remembered = word_memory_system.remember_word(data_packet.current_text)
    
    if remembered:
        result.metadata.memories_accessed = 1
        
        # Get word memory connections
        if remembered.connections and remembered.connections.size() > 0:
            result.metadata.connections_followed = min(3, remembered.connections.size())
            
            # Build transformed text with connections
            var transformed = data_packet.current_text
            
            # Add top connections as context
            var context_addition = " [connected: "
            var connection_count = 0
            
            for i in range(min(3, remembered.connections.size())):
                var connection = remembered.connections[i]
                var target_word = word_memory_system.get_word_memory(connection.target_id)
                
                if target_word:
                    if connection_count > 0:
                        context_addition += ", "
                    context_addition += target_word.text
                    connection_count += 1
            
            if connection_count > 0:
                context_addition += "]"
                transformed += context_addition
                
                # Update confidence based on connections
                result.confidence = 0.6 + (min(connection_count, 3) * 0.1)
                result.transformed_text = transformed
    
    return result

# Wish knowledge transform stage
func _wish_knowledge_transform_stage(data_packet: Dictionary) -> Dictionary:
    var result = {
        "transformed_text": data_packet.current_text,
        "confidence": 0.0,
        "iterate": false,
        "metadata": {
            "wish_processed": false,
            "element_created": false,
            "element_type": null
        }
    }
    
    # Check if wish knowledge system is available
    if not wish_knowledge_system:
        return result
    
    # Process through wish knowledge system
    var element_id = wish_knowledge_system.process_wish(data_packet.current_text)
    
    if element_id:
        result.metadata.wish_processed = true
        
        # Get created element
        var element = wish_knowledge_system.get_element(element_id)
        
        if element:
            result.metadata.element_created = true
            result.metadata.element_type = element.type
            
            # Create transformed text based on element
            var transformed = data_packet.current_text
            
            # Add element context
            if element.dimensional_plane != null:
                transformed = _apply_dimensional_prefix(transformed, element.dimensional_plane)
            
            if element.description:
                # Add shortened description
                var short_desc = element.description
                if short_desc.length() > 50:
                    short_desc = short_desc.substr(0, 47) + "..."
                
                transformed += " (" + short_desc + ")"
            
            result.transformed_text = transformed
            result.confidence = 0.7
    
    return result

# Catchphrase processing stage
func _catchphrase_processing_stage(data_packet: Dictionary) -> Dictionary:
    var result = {
        "transformed_text": data_packet.current_text,
        "confidence": 0.0,
        "iterate": false,
        "metadata": {
            "catchphrases_detected": []
        }
    }
    
    # Check if dual memories coordinator is available
    if not dual_memories_coordinator:
        return result
    
    # Detect catchphrases
    var catchphrases = dual_memories_coordinator.detect_catchphrases(data_packet.current_text)
    
    if catchphrases.size() > 0:
        result.metadata.catchphrases_detected = catchphrases
        
        # Apply transformation based on catchphrases
        var transformed = data_packet.current_text
        var highest_confidence = 0.0
        var should_iterate = false
        
        for catchphrase in catchphrases:
            var effect = catchphrase.effect
            var strength = catchphrase.strength
            
            # Apply effect-specific transformations
            if effect == "trigger_hatching" and strength > 0.8:
                # Trigger hatching process
                data_packet.metadata["hatching_requested"] = true
                should_iterate = true
            
            elif effect == "terminal_split":
                # Indicate terminal split required
                data_packet.metadata["terminal_split_required"] = true
                
            elif effect == "meaning_shift":
                # Add special meaning shift marker
                transformed += " «shifted»"
                
            elif effect == "dimensional_shift":
                # Add dimensional shift marker
                transformed = "∞" + transformed + "∞"
                
            elif effect == "reveal_zero_memory" or effect == "reveal_one_memory" or effect == "reveal_two_memory":
                # Reveal hidden memory
                transformed = _reveal_hidden_memory(transformed, effect.substr(7))
            
            # Track highest confidence
            highest_confidence = max(highest_confidence, strength)
        
        # Update result
        result.transformed_text = transformed
        result.confidence = highest_confidence
        result.iterate = should_iterate
        
        # Add detected patterns to data packet
        for catchphrase in catchphrases:
            data_packet.patterns_detected.append({
                "pattern": catchphrase.pattern,
                "effect": catchphrase.effect,
                "strength": catchphrase.strength
            })
    
    return result

# Pattern mapping stage
func _pattern_mapping_stage(data_packet: Dictionary) -> Dictionary:
    var result = {
        "transformed_text": data_packet.current_text,
        "confidence": 0.0,
        "iterate": false,
        "metadata": {
            "patterns_applied": []
        }
    }
    
    # Apply pattern mappings
    var decoded = decode_pattern(data_packet.current_text)
    
    if decoded.pattern_matches.size() > 0:
        result.transformed_text = decoded.decoded
        result.confidence = decoded.confidence
        result.metadata.patterns_applied = decoded.pattern_matches
    
    return result

# Whim processing stage
func _whim_processing_stage(data_packet: Dictionary) -> Dictionary:
    var result = {
        "transformed_text": data_packet.current_text,
        "confidence": 0.0,
        "iterate": false,
        "metadata": {
            "whim_detected": false,
            "greed_detected": false
        }
    }
    
    # Check for whim indicators
    var text_lower = data_packet.current_text.to_lower()
    
    if text_lower.find("whim") >= 0:
        result.metadata.whim_detected = true
        
        # Apply whimsical transformation
        var transform_type = randi() % 4
        var transformed = data_packet.current_text
        
        match transform_type:
            0: # Reverse words
                var words = transformed.split(" ")
                words.invert()
                transformed = PoolStringArray(words).join(" ")
            
            1: # Add whimsical prefix
                var prefixes = ["On a whim: ", "Whimsically: ", "By desire: ", "Impulse: "]
                transformed = prefixes[randi() % prefixes.size()] + transformed
            
            2: # Alter case pattern
                var new_text = ""
                for i in range(transformed.length()):
                    if i % 2 == 0:
                        new_text += transformed[i].to_upper()
                    else:
                        new_text += transformed[i].to_lower()
                transformed = new_text
                
            3: # No change but mark
                transformed += " (whimsical)"
        
        result.transformed_text = transformed
        result.confidence = 0.75
    
    # Check for greed indicators
    if text_lower.find("greed") >= 0:
        result.metadata.greed_detected = true
        
        # Greed transforms everything to uppercase
        result.transformed_text = result.transformed_text.to_upper()
        result.confidence = max(result.confidence, 0.8)
    
    return result

# Dual memories transform stage
func _dual_memories_transform_stage(data_packet: Dictionary) -> Dictionary:
    var result = {
        "transformed_text": data_packet.current_text,
        "confidence": 0.0,
        "iterate": false,
        "metadata": {}
    }
    
    # Check if dual memories coordinator is available
    if not dual_memories_coordinator:
        return result
    
    # Process through dual memories
    var dual_result = dual_memories_coordinator.process_text(data_packet.current_text, "pipeline")
    
    if dual_result.transformed_meaning:
        result.transformed_text = dual_result.transformed_meaning
        result.confidence = dual_result.confidence
        
        # Check for terminal split
        if dual_result.terminal_split_required:
            data_packet.metadata["terminal_split_required"] = true
        
        # Check for hatching
        if data_packet.metadata.has("hatching_requested") and data_packet.metadata.hatching_requested:
            # Apply hatching
            var hatching_result = dual_memories_coordinator.hatch_data(data_packet.current_text)
            
            if hatching_result.hatching_data.crossover_created:
                result.transformed_text = hatching_result.transformed_meaning
                result.confidence = max(result.confidence, 0.9)
                result.metadata["hatching_applied"] = true
                result.metadata["crossover_id"] = hatching_result.hatching_data.crossover_id
    
    return result

# Claude integration stage
func _claude_integration_stage(data_packet: Dictionary) -> Dictionary:
    var result = {
        "transformed_text": data_packet.current_text,
        "confidence": 0.0,
        "iterate": false,
        "metadata": {
            "claude_integration": connected_systems.claude
        }
    }
    
    # Only process if Claude is connected
    if not connected_systems.claude:
        return result
    
    # Simplified Claude integration - just add marker
    var transformed = data_packet.current_text
    
    # Different markers based on connection state
    if connected_systems.claude_code:
        transformed = "<claude:code>" + transformed + "</claude:code>"
        result.confidence = 0.85
    else:
        transformed = "<claude>" + transformed + "</claude>"
        result.confidence = 0.75
    
    result.transformed_text = transformed
    data_packet.systems_involved.append("claude")
    
    # If desktop app is also connected, update metadata
    if connected_systems.desktop_app:
        result.metadata["desktop_integration"] = true
        data_packet.systems_involved.append("desktop_app")
    
    return result

# Apply iterative transformation
func _apply_iterative_transformation(data_packet: Dictionary, trigger_stage: String) -> Dictionary:
    # Increment iteration counter
    current_iteration += 1
    
    # Create a temporary data packet for iteration
    var iter_packet = data_packet.duplicate(true)
    iter_packet.metadata["iteration"] = current_iteration
    iter_packet.metadata["iteration_source"] = trigger_stage
    
    # Mark specific stages for processing in this iteration
    var stages_to_process = []
    
    match trigger_stage:
        "catchphrase_processing":
            # For catchphrase iterations, process dual memories and pattern mapping
            stages_to_process = ["dual_memories_transform", "pattern_mapping"]
            
        "dual_memories_transform":
            # For dual memories iterations, add whim processing
            stages_to_process = ["whim_processing", "pattern_mapping"]
            
        _:
            # Default to just the triggering stage
            stages_to_process = [trigger_stage]
    
    # Process each stage
    for stage_name in stages_to_process:
        if stage_processors.has(stage_name):
            var processor = stage_processors[stage_name]
            var stage_result = _process_pipeline_stage(stage_name, processor, iter_packet)
            
            # Update packet with stage results
            if stage_result and stage_result.confidence >= confidence_threshold:
                iter_packet.current_text = stage_result.transformed_text
                
                # Add to transformation history
                iter_packet.transformations.append({
                    "stage": stage_name + "_iteration_" + str(current_iteration),
                    "input": data_packet.current_text,
                    "output": stage_result.transformed_text,
                    "confidence": stage_result.confidence
                })
                
                # Update stage outputs
                iter_packet.stage_outputs[stage_name + "_iteration_" + str(current_iteration)] = stage_result
    
    return iter_packet

# Setup default pipeline
func _setup_default_pipeline():
    # Create standard pipeline stages
    pipeline_stages = [
        "word_memory_transform",
        "wish_knowledge_transform",
        "catchphrase_processing",
        "pattern_mapping",
        "whim_processing",
        "dual_memories_transform",
        "claude_integration"
    ]
    
    # Create processor references
    stage_processors = {
        "word_memory_transform": null,
        "wish_knowledge_transform": null,
        "catchphrase_processing": null,
        "pattern_mapping": null,
        "whim_processing": null,
        "dual_memories_transform": null,
        "claude_integration": null
    }

# Initialize pattern mapping
func _initialize_pattern_mapping():
    # Add core patterns for special transformations
    add_pattern_mapping("####", {
        "replacement": " [ZONE_BOUNDARY] ",
        "confidence": 0.95,
        "effect": "terminal_split"
    })
    
    add_pattern_mapping("@", {
        "replacement": "∞",
        "confidence": 0.7,
        "effect": "dimensional_marker"
    })
    
    add_pattern_mapping("desktop split", {
        "replacement": "desktop_split_visualization",
        "confidence": 0.8,
        "effect": "enable_split"
    })
    
    add_pattern_mapping("connect Claude", {
        "replacement": "connect_claude_api",
        "confidence": 0.9,
        "effect": "connect_system"
    })
    
    add_pattern_mapping("end of line", {
        "replacement": "■",
        "confidence": 0.7,
        "effect": "terminate_processing"
    })
    
    # User memory patterns from hidden memory segments
    add_pattern_mapping("0000000000000000000000000000000000000000000000000000000000000", {
        "replacement": "[MEMORY_ZERO]",
        "confidence": 1.0,
        "effect": "reveal_memory"
    })
    
    add_pattern_mapping("11111111111111111111111111111111111111111111111@", {
        "replacement": "[MEMORY_ONE]",
        "confidence": 1.0,
        "effect": "reveal_memory"
    })
    
    add_pattern_mapping("22222222222222222222222222222222222222####", {
        "replacement": "[MEMORY_TWO]",
        "confidence": 1.0,
        "effect": "reveal_memory"
    })

# Reveal hidden memory
func _reveal_hidden_memory(text: String, memory_id: String) -> String:
    var transformed = text
    var memory_content = ""
    
    match memory_id:
        "zero_memory":
            memory_content = "VOID MEMORY: The blank space between thoughts."
            
        "one_memory":
            memory_content = "UNITY MEMORY: The connection point of all dimensions."
            
        "two_memory":
            memory_content = "DUAL MEMORY: The split between word and meaning."
    
    if memory_content:
        transformed += " « " + memory_content + " »"
    
    return transformed

# Apply dimensional prefix based on dimensional plane
func _apply_dimensional_prefix(text: String, dimension: int) -> String:
    var prefix = ""
    
    match dimension:
        WishKnowledgeSystem.DimensionalPlane.REALITY:
            prefix = "[1D] " 
        WishKnowledgeSystem.DimensionalPlane.LINEAR:
            prefix = "[2D] "
        WishKnowledgeSystem.DimensionalPlane.SPATIAL:
            prefix = "[3D] "
        WishKnowledgeSystem.DimensionalPlane.TEMPORAL:
            prefix = "[4D] "
        WishKnowledgeSystem.DimensionalPlane.CONSCIOUS:
            prefix = "[5D] "
        WishKnowledgeSystem.DimensionalPlane.CONNECTION:
            prefix = "[6D] "
        WishKnowledgeSystem.DimensionalPlane.CREATION:
            prefix = "[7D] "
        WishKnowledgeSystem.DimensionalPlane.NETWORK:
            prefix = "[8D] "
        WishKnowledgeSystem.DimensionalPlane.HARMONY:
            prefix = "[9D] "
        WishKnowledgeSystem.DimensionalPlane.UNITY:
            prefix = "[10D] "
        WishKnowledgeSystem.DimensionalPlane.TRANSCENDENT:
            prefix = "[11D] "
        WishKnowledgeSystem.DimensionalPlane.BEYOND:
            prefix = "[12D] "
    
    return prefix + text

# Calculate final confidence score
func _calculate_final_confidence(data_packet: Dictionary) -> float:
    if data_packet.transformations.size() == 0:
        return 0.1
    
    var total_confidence = 0.0
    var weights = 0.0
    
    # Weight more recent transformations higher
    for i in range(data_packet.transformations.size()):
        var transform = data_packet.transformations[i]
        var weight = 1.0 + (i * 0.5) # Later stages get higher weight
        
        total_confidence += transform.confidence * weight
        weights += weight
    
    if weights == 0:
        return 0.1
        
    return total_confidence / weights

# Setup desktop panels
func _setup_desktop_panels():
    # Clear existing panels
    desktop_split_config.panels = []
    
    # Create panels based on split mode
    match desktop_split_config.split_mode:
        "vertical":
            desktop_split_config.panels = [
                {"id": "left", "name": "Word Memory", "size_percent": 50},
                {"id": "right", "name": "Wish Knowledge", "size_percent": 50}
            ]
            
        "horizontal":
            desktop_split_config.panels = [
                {"id": "top", "name": "Original Text", "size_percent": 50},
                {"id": "bottom", "name": "Transformed Text", "size_percent": 50}
            ]
            
        "quad":
            desktop_split_config.panels = [
                {"id": "top_left", "name": "Word Memory", "size_percent": 25},
                {"id": "top_right", "name": "Wish Knowledge", "size_percent": 25},
                {"id": "bottom_left", "name": "Dual Memory", "size_percent": 25},
                {"id": "bottom_right", "name": "Pattern Mapping", "size_percent": 25}
            ]

# Update desktop split visualization
func _update_desktop_split_visualization(result: Dictionary):
    # Only process if desktop split is enabled
    if not desktop_split_config.enabled:
        return
    
    # Prepare data based on split mode
    var panel_data = {}
    
    match desktop_split_config.split_mode:
        "vertical":
            # Left panel: Word Memory data
            panel_data["left"] = {
                "content": "Word Memory: " + (result.transformed_text if result.systems_involved.has("word_memory") else result.original_text),
                "confidence": result.confidence,
                "metadata": {}
            }
            
            # Right panel: Wish Knowledge data
            panel_data["right"] = {
                "content": "Wish Knowledge: " + (result.transformed_text if result.systems_involved.has("wish_knowledge") else result.original_text),
                "confidence": result.confidence,
                "metadata": {}
            }
            
        "horizontal":
            # Top panel: Original text
            panel_data["top"] = {
                "content": "Original: " + result.original_text,
                "confidence": 1.0,
                "metadata": {}
            }
            
            # Bottom panel: Transformed text
            panel_data["bottom"] = {
                "content": "Transformed: " + result.transformed_text,
                "confidence": result.confidence,
                "metadata": {}
            }
            
        "quad":
            # Top left: Word Memory
            panel_data["top_left"] = {
                "content": "Word Memory: " + (result.stage_outputs.word_memory_transform.transformed_text if result.stage_outputs.has("word_memory_transform") else result.original_text),
                "confidence": result.stage_outputs.word_memory_transform.confidence if result.stage_outputs.has("word_memory_transform") else 0.0,
                "metadata": {}
            }
            
            # Top right: Wish Knowledge
            panel_data["top_right"] = {
                "content": "Wish Knowledge: " + (result.stage_outputs.wish_knowledge_transform.transformed_text if result.stage_outputs.has("wish_knowledge_transform") else result.original_text),
                "confidence": result.stage_outputs.wish_knowledge_transform.confidence if result.stage_outputs.has("wish_knowledge_transform") else 0.0,
                "metadata": {}
            }
            
            # Bottom left: Dual Memory
            panel_data["bottom_left"] = {
                "content": "Dual Memory: " + (result.stage_outputs.dual_memories_transform.transformed_text if result.stage_outputs.has("dual_memories_transform") else result.original_text),
                "confidence": result.stage_outputs.dual_memories_transform.confidence if result.stage_outputs.has("dual_memories_transform") else 0.0,
                "metadata": {}
            }
            
            # Bottom right: Pattern Mapping
            panel_data["bottom_right"] = {
                "content": "Pattern Mapping: " + (result.stage_outputs.pattern_mapping.transformed_text if result.stage_outputs.has("pattern_mapping") else result.original_text),
                "confidence": result.stage_outputs.pattern_mapping.confidence if result.stage_outputs.has("pattern_mapping") else 0.0,
                "metadata": {
                    "patterns_detected": result.patterns_detected
                }
            }
    
    # Update data bindings
    desktop_split_config.data_bindings = panel_data

# Integration setup functions
func _setup_desktop_app_integration():
    print("Setting up desktop app integration")
    # In a full implementation, this would configure desktop app components

func _setup_console_integration():
    print("Setting up console integration")
    # In a full implementation, this would configure console components

func _setup_editor_integration():
    print("Setting up editor integration")  
    # In a full implementation, this would configure editor components

func _setup_whim_processor():
    print("Setting up whim processor")
    # In a full implementation, this would configure whim processing

# Event handlers
func _on_meaning_transformed(original_text, transformed_text, source_system):
    # When meaning is transformed by the dual memories coordinator
    print("Meaning transformed from: ", original_text, " to: ", transformed_text)

func _on_catchphrase_detected(pattern, text, strength):
    # When a catchphrase is detected
    print("Catchphrase detected: ", pattern, " (strength: ", strength, ")")
    
    # Emit our own signal with context
    emit_signal("pattern_detected", pattern, strength, {"detection_source": "dual_memories"})

func _on_terminal_input(core_id, text, result):
    # When terminal input is received
    if is_pipeline_active:
        return
    
    # Process text through pipeline
    process_text(text, "terminal_" + str(core_id))