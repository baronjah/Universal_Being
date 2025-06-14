extends Node
class_name TerminalSplitController

"""
TerminalSplitController
-----------------------
Extends DualCoreTerminal functionality to support dynamic splitting of terminals
for parallel data visualization and processing. Integrates with the dual memories system
to create a unified interface for memory visualization across different perspectives.

This controller enables:
1. Dynamic creation and management of terminal cores
2. Synchronized data visualization across multiple terminals
3. Memory-specific terminal customization
4. Split-mode switching (vertical, horizontal, quad, etc.)
5. Integration with memory systems for real-time updates

Works with the existing DualCoreTerminal, but adds advanced splitting capabilities.
"""

# System references
var dual_core_terminal: DualCoreTerminal
var dual_memories_coordinator: DualMemoriesCoordinator
var meaning_transformation_pipeline: MeaningTransformationPipeline
var word_memory_system: WordMemorySystem
var wish_knowledge_system: WishKnowledgeSystem

# Split configurations
enum SplitMode {
    SINGLE,    # Only one terminal visible
    DUAL,      # Two terminals side by side
    QUAD,      # Four terminals in grid layout
    TRIPLE_V,  # Three terminals in vertical layout
    TRIPLE_H,  # Three terminals in horizontal layout
    CASCADE,   # Terminals in cascading windows
    CUSTOM     # Custom arrangement
}

# Core assignment types
enum CoreAssignment {
    WORD_MEMORY,
    WISH_KNOWLEDGE,
    DUAL_MEMORY,
    PATTERN_MAPPING,
    RAW_INPUT,
    TRANSFORMED_OUTPUT,
    CUSTOM
}

# Terminal state
var current_split_mode = SplitMode.SINGLE
var active_terminal_cores = []
var core_assignments = {}
var core_data_bindings = {}
var custom_layout_data = {}
var split_ratio = 0.5  # For simple split modes
var is_auto_update_enabled = true
var last_input_text = ""
var last_transformation_result = null

# Configuration
const MAX_TERMINALS = 9  # Match DualCoreTerminal.MAX_CORES
const DEFAULT_BRACKET_STYLES = {
    CoreAssignment.WORD_MEMORY: "blue",
    CoreAssignment.WISH_KNOWLEDGE: "green",
    CoreAssignment.DUAL_MEMORY: "purple",
    CoreAssignment.PATTERN_MAPPING: "gold",
    CoreAssignment.RAW_INPUT: "default",
    CoreAssignment.TRANSFORMED_OUTPUT: "rainbow"
}

# Memory display formats
var display_formats = {
    "word_memory": {
        "prefix": "WORD: ",
        "suffix": "",
        "highlight_patterns": ["#", "@"]
    },
    "wish_knowledge": {
        "prefix": "WISH: ",
        "suffix": "",
        "highlight_patterns": ["create", "transform", "connect"]
    },
    "dual_memory": {
        "prefix": "DUAL: ",
        "suffix": "",
        "highlight_patterns": ["0", "1", "2", "memory", "hatching"]
    },
    "pattern_mapping": {
        "prefix": "PATTERN: ",
        "suffix": "",
        "highlight_patterns": ["####", "@", "catchphrase", "whim"]
    }
}

# Signals
signal split_mode_changed(old_mode, new_mode)
signal terminal_core_created(core_id, assignment)
signal terminal_data_updated(core_id, new_data)
signal terminal_focus_changed(old_core_id, new_core_id)
signal terminal_synchronized(sync_data)

# Initialize the controller
func _init():
    pass

# Initialize with system references
func initialize(terminal: DualCoreTerminal, 
               coordinator: DualMemoriesCoordinator = null,
               pipeline: MeaningTransformationPipeline = null,
               word_system: WordMemorySystem = null,
               wish_system: WishKnowledgeSystem = null):
    
    # Store references
    dual_core_terminal = terminal
    dual_memories_coordinator = coordinator
    meaning_transformation_pipeline = pipeline
    word_memory_system = word_system
    wish_knowledge_system = wish_system
    
    # Connect signals
    if dual_core_terminal:
        dual_core_terminal.connect("core_switched", self, "_on_core_switched")
        dual_core_terminal.connect("input_processed", self, "_on_terminal_input_processed")
    
    if dual_memories_coordinator:
        dual_memories_coordinator.connect("meaning_transformed", self, "_on_meaning_transformed")
        dual_memories_coordinator.connect("terminal_split_changed", self, "_on_terminal_split_changed")
    
    if meaning_transformation_pipeline:
        meaning_transformation_pipeline.connect("pipeline_completed", self, "_on_pipeline_completed")
    
    # Initialize with single mode
    _initialize_single_mode()
    
    print("TerminalSplitController initialized")

# Set the split mode
func set_split_mode(mode) -> bool:
    # Validate mode
    if typeof(mode) == TYPE_STRING:
        # Convert string to enum
        match mode.to_lower():
            "single": mode = SplitMode.SINGLE
            "dual": mode = SplitMode.DUAL
            "quad": mode = SplitMode.QUAD
            "triple_v", "triple_vertical": mode = SplitMode.TRIPLE_V
            "triple_h", "triple_horizontal": mode = SplitMode.TRIPLE_H
            "cascade": mode = SplitMode.CASCADE
            "custom": mode = SplitMode.CUSTOM
            _: return false
    
    # Only process valid enum values
    if typeof(mode) != TYPE_INT or mode < 0 or mode > SplitMode.CUSTOM:
        return false
    
    # Store old mode for signal
    var old_mode = current_split_mode
    
    # Skip if no change
    if old_mode == mode:
        return true
    
    # Apply new split mode
    current_split_mode = mode
    
    # Configure terminals for new mode
    match mode:
        SplitMode.SINGLE:
            _configure_single_mode()
        SplitMode.DUAL:
            _configure_dual_mode()
        SplitMode.QUAD:
            _configure_quad_mode()
        SplitMode.TRIPLE_V:
            _configure_triple_vertical_mode()
        SplitMode.TRIPLE_H:
            _configure_triple_horizontal_mode()
        SplitMode.CASCADE:
            _configure_cascade_mode()
        SplitMode.CUSTOM:
            _configure_custom_mode()
    
    # Emit signal
    emit_signal("split_mode_changed", old_mode, current_split_mode)
    
    return true

# Set the split ratio
func set_split_ratio(ratio: float) -> bool:
    # Validate ratio
    if ratio <= 0.0 or ratio >= 1.0:
        return false
    
    # Update ratio
    split_ratio = ratio
    
    # Reconfigure current mode with new ratio
    match current_split_mode:
        SplitMode.DUAL:
            _configure_dual_mode()
        SplitMode.TRIPLE_H:
            _configure_triple_horizontal_mode()
        SplitMode.TRIPLE_V:
            _configure_triple_vertical_mode()
    
    return true

# Process input through all memory systems and update terminal displays
func process_input(text: String, source_core_id: int = 0) -> Dictionary:
    # Store input for reference
    last_input_text = text
    
    var result = {
        "original_text": text,
        "transformed_text": text,
        "word_memory_result": null,
        "wish_knowledge_result": null,
        "dual_memory_result": null,
        "pipeline_result": null,
        "terminals_updated": []
    }
    
    # Process through meaning transformation pipeline if available
    if meaning_transformation_pipeline:
        var pipeline_result = meaning_transformation_pipeline.process_text(text, "terminal_" + str(source_core_id))
        result.pipeline_result = pipeline_result
        result.transformed_text = pipeline_result.transformed_text
    
    # Otherwise, process through dual memories coordinator
    elif dual_memories_coordinator:
        var dual_result = dual_memories_coordinator.process_text(text, "terminal_" + str(source_core_id))
        result.dual_memory_result = dual_result
        result.transformed_text = dual_result.transformed_meaning
        
        # Check for wish and word memory results
        result.word_memory_result = dual_result.word_memory_result
        result.wish_knowledge_result = dual_result.wish_knowledge_result
    
    # Store last transformation result
    last_transformation_result = result
    
    # Update terminal displays
    if is_auto_update_enabled:
        update_terminal_displays(result)
    
    return result

# Update all terminal displays with new data
func update_terminal_displays(result: Dictionary) -> void:
    # Skip if no terminal
    if not dual_core_terminal:
        return
    
    # Update each core based on its assignment
    for core_id in active_terminal_cores:
        if not core_assignments.has(core_id):
            continue
        
        var assignment = core_assignments[core_id]
        var display_text = ""
        var display_format = null
        
        match assignment:
            CoreAssignment.WORD_MEMORY:
                display_text = _format_word_memory_display(result)
                display_format = display_formats.word_memory
                
            CoreAssignment.WISH_KNOWLEDGE:
                display_text = _format_wish_knowledge_display(result)
                display_format = display_formats.wish_knowledge
                
            CoreAssignment.DUAL_MEMORY:
                display_text = _format_dual_memory_display(result)
                display_format = display_formats.dual_memory
                
            CoreAssignment.PATTERN_MAPPING:
                display_text = _format_pattern_mapping_display(result)
                display_format = display_formats.pattern_mapping
                
            CoreAssignment.RAW_INPUT:
                display_text = "INPUT: " + result.original_text
                
            CoreAssignment.TRANSFORMED_OUTPUT:
                display_text = "OUTPUT: " + result.transformed_text
        
        # Apply display formatting
        if display_format:
            display_text = display_format.prefix + display_text + display_format.suffix
            
            # Apply highlighting
            for pattern in display_format.highlight_patterns:
                # Simple highlighting for pattern matches
                if display_text.find(pattern) >= 0:
                    display_text = display_text.replace(pattern, "[b]" + pattern + "[/b]")
        
        # Store in data bindings
        core_data_bindings[core_id] = {
            "text": display_text,
            "timestamp": OS.get_unix_time(),
            "raw_data": result
        }
        
        # Send to terminal core as simulated input
        # In real implementation, would update terminal UI instead
        if dual_core_terminal.cores.has(core_id):
            # Add to terminal history
            dual_core_terminal.cores[core_id].history.append({
                "type": "system",
                "text": display_text,
                "timestamp": OS.get_unix_time()
            })
            
            # Emit signal
            emit_signal("terminal_data_updated", core_id, display_text)

# Assign a specific core to a display type
func assign_core(core_id: int, assignment) -> bool:
    # Validate core existence
    if not dual_core_terminal or not dual_core_terminal.cores.has(core_id):
        return false
    
    # Validate assignment type
    if typeof(assignment) == TYPE_STRING:
        # Convert string to enum
        match assignment.to_lower():
            "word_memory": assignment = CoreAssignment.WORD_MEMORY
            "wish_knowledge": assignment = CoreAssignment.WISH_KNOWLEDGE
            "dual_memory": assignment = CoreAssignment.DUAL_MEMORY
            "pattern_mapping": assignment = CoreAssignment.PATTERN_MAPPING
            "raw_input": assignment = CoreAssignment.RAW_INPUT
            "transformed_output": assignment = CoreAssignment.TRANSFORMED_OUTPUT
            "custom": assignment = CoreAssignment.CUSTOM
            _: return false
    
    # Store assignment
    core_assignments[core_id] = assignment
    
    # Configure core appearance based on assignment
    if DEFAULT_BRACKET_STYLES.has(assignment):
        dual_core_terminal.cores[core_id].bracket_style = DEFAULT_BRACKET_STYLES[assignment]
    
    # Add to active cores if not already there
    if not active_terminal_cores.has(core_id):
        active_terminal_cores.append(core_id)
    
    # Emit signal
    emit_signal("terminal_core_created", core_id, assignment)
    
    # Update display if we have last results
    if last_transformation_result:
        update_terminal_displays(last_transformation_result)
    
    return true

# Create a terminal with specified assignment
func create_assigned_terminal(assignment, core_id: int = -1) -> int:
    # Find available core ID if not specified
    if core_id < 0:
        for i in range(MAX_TERMINALS):
            if not dual_core_terminal.cores.has(i):
                core_id = i
                break
    
    # Bail if all cores used or invalid core_id
    if core_id < 0 or core_id >= MAX_TERMINALS:
        return -1
    
    # Create core if doesn't exist
    if not dual_core_terminal.cores.has(core_id):
        var name = ""
        
        # Generate name based on assignment
        if typeof(assignment) == TYPE_INT:
            match assignment:
                CoreAssignment.WORD_MEMORY: name = "Word Memory"
                CoreAssignment.WISH_KNOWLEDGE: name = "Wish Knowledge"
                CoreAssignment.DUAL_MEMORY: name = "Dual Memory" 
                CoreAssignment.PATTERN_MAPPING: name = "Pattern Mapping"
                CoreAssignment.RAW_INPUT: name = "Input Core"
                CoreAssignment.TRANSFORMED_OUTPUT: name = "Output Core"
                CoreAssignment.CUSTOM: name = "Custom Core"
        elif typeof(assignment) == TYPE_STRING:
            name = assignment
        
        if name.empty():
            name = "Core " + str(core_id)
        
        # Create the core
        dual_core_terminal.create_core(core_id, name)
    
    # Assign the core
    assign_core(core_id, assignment)
    
    return core_id

# Synchronize all terminals to same display
func synchronize_terminals() -> void:
    # No need to sync if only one terminal
    if active_terminal_cores.size() <= 1:
        return
    
    # Create sync data
    var sync_data = {
        "sync_time": OS.get_unix_time(),
        "original_text": last_input_text,
        "transformed_text": last_transformation_result.transformed_text if last_transformation_result else last_input_text,
        "cores_synced": active_terminal_cores
    }
    
    # Add synchronization message to all active cores
    for core_id in active_terminal_cores:
        if dual_core_terminal.cores.has(core_id):
            dual_core_terminal.cores[core_id].history.append({
                "type": "sync",
                "text": "SYNC: All terminals synchronized at " + str(OS.get_datetime()),
                "timestamp": OS.get_unix_time()
            })
    
    # Update displays
    if last_transformation_result:
        update_terminal_displays(last_transformation_result)
    
    # Emit signal
    emit_signal("terminal_synchronized", sync_data)

# Toggle auto-update of terminal displays
func set_auto_update(enabled: bool) -> void:
    is_auto_update_enabled = enabled

# Create a custom terminal layout
func create_custom_layout(layout_data: Dictionary) -> bool:
    # Validate layout data
    if not layout_data.has("cores") or typeof(layout_data.cores) != TYPE_ARRAY:
        return false
    
    # Store custom layout
    custom_layout_data = layout_data
    
    # Apply custom layout
    if current_split_mode == SplitMode.CUSTOM:
        _configure_custom_mode()
    
    return true

# Configuration functions for different modes
func _configure_single_mode() -> void:
    # Ensure core 0 exists
    if not dual_core_terminal.cores.has(0):
        dual_core_terminal.create_core(0, "Main Terminal")
    
    # Set as active core
    dual_core_terminal.switch_core(0)
    
    # Set to active cores list
    active_terminal_cores = [0]
    
    # Assign as transformed output
    assign_core(0, CoreAssignment.TRANSFORMED_OUTPUT)

func _configure_dual_mode() -> void:
    # Ensure both cores exist
    for i in range(2):
        if not dual_core_terminal.cores.has(i):
            var name = "Core " + str(i)
            if i == 0:
                name = "Word Memory"
            elif i == 1:
                name = "Wish Knowledge"
            
            dual_core_terminal.create_core(i, name)
    
    # Set to active cores list
    active_terminal_cores = [0, 1]
    
    # Assign core roles
    assign_core(0, CoreAssignment.WORD_MEMORY)
    assign_core(1, CoreAssignment.WISH_KNOWLEDGE)
    
    # Set core 0 as active
    dual_core_terminal.switch_core(0)

func _configure_quad_mode() -> void:
    # Ensure all four cores exist
    for i in range(4):
        if not dual_core_terminal.cores.has(i):
            var name = "Core " + str(i)
            match i:
                0: name = "Word Memory"
                1: name = "Wish Knowledge"
                2: name = "Dual Memory"
                3: name = "Pattern Mapping"
            
            dual_core_terminal.create_core(i, name)
    
    # Set to active cores list
    active_terminal_cores = [0, 1, 2, 3]
    
    # Assign core roles
    assign_core(0, CoreAssignment.WORD_MEMORY)
    assign_core(1, CoreAssignment.WISH_KNOWLEDGE)
    assign_core(2, CoreAssignment.DUAL_MEMORY)
    assign_core(3, CoreAssignment.PATTERN_MAPPING)
    
    # Set core 0 as active
    dual_core_terminal.switch_core(0)

func _configure_triple_vertical_mode() -> void:
    # Ensure all three cores exist
    for i in range(3):
        if not dual_core_terminal.cores.has(i):
            var name = "Core " + str(i)
            match i:
                0: name = "Input"
                1: name = "Processing"
                2: name = "Output"
            
            dual_core_terminal.create_core(i, name)
    
    # Set to active cores list
    active_terminal_cores = [0, 1, 2]
    
    # Assign core roles
    assign_core(0, CoreAssignment.RAW_INPUT)
    assign_core(1, CoreAssignment.DUAL_MEMORY)
    assign_core(2, CoreAssignment.TRANSFORMED_OUTPUT)
    
    # Set core 0 as active
    dual_core_terminal.switch_core(0)

func _configure_triple_horizontal_mode() -> void:
    # Same core setup as vertical, just different layout in UI
    _configure_triple_vertical_mode()

func _configure_cascade_mode() -> void:
    # Use all available cores in cascade
    active_terminal_cores = []
    
    # Create/configure cores
    var assignments = [
        CoreAssignment.RAW_INPUT,
        CoreAssignment.WORD_MEMORY,
        CoreAssignment.WISH_KNOWLEDGE,
        CoreAssignment.DUAL_MEMORY,
        CoreAssignment.PATTERN_MAPPING,
        CoreAssignment.TRANSFORMED_OUTPUT
    ]
    
    for i in range(min(MAX_TERMINALS, assignments.size())):
        if not dual_core_terminal.cores.has(i):
            var name = "Core " + str(i)
            dual_core_terminal.create_core(i, name)
        
        # Assign role
        assign_core(i, assignments[i])
        active_terminal_cores.append(i)
    
    # Set core 0 as active
    dual_core_terminal.switch_core(0)

func _configure_custom_mode() -> void:
    # Apply custom layout if available
    if custom_layout_data.empty():
        # Fallback to dual mode
        _configure_dual_mode()
        return
    
    # Clear active cores
    active_terminal_cores = []
    
    # Configure each core from custom layout
    for core_config in custom_layout_data.cores:
        if not core_config.has("id") or not core_config.has("assignment"):
            continue
        
        var core_id = core_config.id
        var assignment = core_config.assignment
        var name = core_config.get("name", "Core " + str(core_id))
        
        # Create core if needed
        if not dual_core_terminal.cores.has(core_id):
            dual_core_terminal.create_core(core_id, name)
        
        # Assign role
        assign_core(core_id, assignment)
        active_terminal_cores.append(core_id)
    
    # Set first core as active if available
    if active_terminal_cores.size() > 0:
        dual_core_terminal.switch_core(active_terminal_cores[0])

# Initialize single mode
func _initialize_single_mode() -> void:
    # Start with single mode configuration
    current_split_mode = SplitMode.SINGLE
    _configure_single_mode()

# Format display functions
func _format_word_memory_display(result: Dictionary) -> String:
    var display = result.original_text
    
    # Include word memory data if available
    if result.word_memory_result:
        display += "\n\n--- Word Memory ---"
        
        # Add dimension history
        if result.word_memory_result.dimension_history and result.word_memory_result.dimension_history.size() > 0:
            var dim = result.word_memory_result.dimension_history[result.word_memory_result.dimension_history.size() - 1].dimension
            display += "\nDimension: " + dim
        
        # Add connections
        if result.word_memory_result.connections and result.word_memory_result.connections.size() > 0:
            display += "\nConnections: "
            for i in range(min(3, result.word_memory_result.connections.size())):
                var conn = result.word_memory_result.connections[i]
                display += conn.target_id + " "
    
    return display

func _format_wish_knowledge_display(result: Dictionary) -> String:
    var display = result.original_text
    
    # Include wish knowledge data if available
    if result.wish_knowledge_result:
        display += "\n\n--- Wish Knowledge ---"
        
        # Add dimensional plane
        if result.wish_knowledge_result.dimensional_plane != null:
            display += "\nDimension: " + str(result.wish_knowledge_result.dimensional_plane)
        
        # Add element type
        if result.wish_knowledge_result.type != null:
            display += "\nType: " + str(result.wish_knowledge_result.type)
        
        # Add description
        if result.wish_knowledge_result.description:
            display += "\nDescription: " + result.wish_knowledge_result.description
    
    return display

func _format_dual_memory_display(result: Dictionary) -> String:
    var display = result.transformed_text
    
    # Include dual memory specific data
    if result.dual_memory_result:
        display += "\n\n--- Dual Memory ---"
        
        # Add confidence
        display += "\nConfidence: " + str(result.dual_memory_result.confidence)
        
        # Add terminal split info
        if result.dual_memory_result.terminal_split_required:
            display += "\nTerminal Split Recommended"
        
        # Add catchphrases
        if result.dual_memory_result.catchphrases_detected and result.dual_memory_result.catchphrases_detected.size() > 0:
            display += "\nCatchphrases: "
            for cp in result.dual_memory_result.catchphrases_detected:
                display += cp.pattern + " "
    
    return display

func _format_pattern_mapping_display(result: Dictionary) -> String:
    var display = result.transformed_text
    
    # Include pattern mapping data
    if result.pipeline_result and result.pipeline_result.patterns_detected:
        display += "\n\n--- Pattern Mapping ---"
        
        for pattern in result.pipeline_result.patterns_detected:
            display += "\nPattern: " + pattern.pattern + " (" + str(pattern.strength) + ")"
    
    # Include special pattern formats for the number sequences
    display = display.replace("0000000000000000000000000000000000000000000000000000000000000", "[ZERO MEMORY]")
    display = display.replace("11111111111111111111111111111111111111111111111@", "[ONE MEMORY]")
    display = display.replace("22222222222222222222222222222222222222####", "[TWO MEMORY]")
    display = display.replace("####", "[ZONE BOUNDARY]")
    display = display.replace("@", "[@]")
    
    return display

# Event handlers
func _on_core_switched(from_core, to_core):
    # When terminal cores are switched
    emit_signal("terminal_focus_changed", from_core, to_core)

func _on_terminal_input_processed(core_id, text, result):
    # When terminal input is processed, handle through pipeline
    process_input(text, core_id)

func _on_meaning_transformed(original_text, transformed_text, source_system):
    # When meaning is transformed
    if last_input_text == original_text and is_auto_update_enabled:
        # Create simplified result for update
        var update_result = {
            "original_text": original_text,
            "transformed_text": transformed_text,
            "source_system": source_system
        }
        
        update_terminal_displays(update_result)

func _on_terminal_split_changed(old_config, new_config):
    # When split config changes in dual memories coordinator
    if new_config == "single":
        set_split_mode(SplitMode.SINGLE)
    elif new_config == "dual":
        set_split_mode(SplitMode.DUAL)
    elif new_config == "multi":
        set_split_mode(SplitMode.QUAD)

func _on_pipeline_completed(input_text, final_output, confidence):
    # When transformation pipeline completes processing
    if last_input_text == input_text and is_auto_update_enabled:
        # Create simplified result for update
        var update_result = {
            "original_text": input_text,
            "transformed_text": final_output,
            "confidence": confidence
        }
        
        update_terminal_displays(update_result)