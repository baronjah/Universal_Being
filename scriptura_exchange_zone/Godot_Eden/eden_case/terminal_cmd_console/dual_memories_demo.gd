extends Node
class_name DualMemoriesDemo

"""
DualMemoriesDemo
---------------
A demonstration scene showcasing the dual memories system with all components:
- DualMemoriesCoordinator for managing memory interactions
- MeaningTransformationPipeline for processing and transforming meanings
- TerminalSplitController for handling multiple terminal displays
- CatchphraseSystem for detecting and transforming special patterns

This demo integrates all systems into a cohesive experience that demonstrates
the capabilities of the dual memories architecture, allowing users to:
1. Enter text through multiple terminals
2. See transformations across different memory systems
3. Trigger special memory sequences through catchphrases
4. Visualize parallel data processing

The scene automatically configures and connects all required components.
"""

# System component references
var dual_memories_coordinator: DualMemoriesCoordinator
var meaning_transformation_pipeline: MeaningTransformationPipeline
var terminal_split_controller: TerminalSplitController
var catchphrase_system: CatchphraseSystem
var word_memory_system: WordMemorySystem
var wish_knowledge_system: WishKnowledgeSystem
var dual_core_terminal: DualCoreTerminal
var memory_channel_system: MemoryChannelSystem

# UI references (would be set in editor)
export(NodePath) var terminal_display_container_path
export(NodePath) var memory_visualization_container_path
export(NodePath) var control_panel_container_path
export(NodePath) var debug_output_label_path

# Configuration
export var auto_initialize = true
export var default_split_mode = "dual"
export var enable_debug_output = true
export var memory_storage_path = "user://dual_memories_demo/"

# Demo state
var demo_initialized = false
var stored_memory_samples = []
var console_history = []
var active_memory_sequences = []
var demo_scenario_index = 0

# Debug output settings
var debug_terminal_output = true
var debug_memory_events = true
var debug_transformation_events = true
var debug_catchphrase_events = true

# Signals
signal demo_initialized()
signal memory_activated(memory_id, content)
signal terminal_updated(core_id, content)
signal demo_scenario_started(scenario_name)
signal demo_scenario_completed(scenario_name)

func _ready():
    if auto_initialize:
        initialize()

# Initialize the entire demo system
func initialize() -> bool:
    print("Initializing Dual Memories Demo...")
    
    # Create directory if it doesn't exist
    var dir = Directory.new()
    if not dir.dir_exists(memory_storage_path):
        dir.make_dir_recursive(memory_storage_path)
    
    # Step 1: Initialize core systems
    _init_core_systems()
    
    # Step 2: Initialize memory systems
    _init_memory_systems()
    
    # Step 3: Initialize terminals
    _init_terminal_systems()
    
    # Step 4: Initialize UI components
    _init_ui_components()
    
    # Step 5: Connect signals
    _connect_signals()
    
    # Step 6: Load demo data
    _load_demo_data()
    
    demo_initialized = true
    emit_signal("demo_initialized")
    
    debug_log("Dual Memories Demo initialized successfully")
    
    # Configure initial terminal split
    if terminal_split_controller:
        terminal_split_controller.set_split_mode(default_split_mode)
    
    return true

# Process input from any source
func process_input(text: String, source: String = "user") -> Dictionary:
    if not demo_initialized:
        debug_log("Demo not initialized! Cannot process input.")
        return {"error": "Demo not initialized"}
    
    var result = {
        "original_text": text,
        "transformed_text": text,
        "systems_processed": [],
        "patterns_detected": [],
        "memory_sequences": [],
        "terminal_updates": []
    }
    
    debug_log("Processing input: " + text)
    
    # Step 1: Process through catchphrase system
    if catchphrase_system:
        var catchphrase_results = catchphrase_system.process_text(text, {"source": source})
        
        if catchphrase_results.size() > 0:
            result.patterns_detected = catchphrase_results
            result.systems_processed.append("catchphrase_system")
            
            # Check for memory sequences
            for pattern in catchphrase_results:
                if pattern.has("effect") and pattern.effect.has("type") and pattern.effect.type == "reveal_memory":
                    result.memory_sequences.append({
                        "pattern": pattern.pattern,
                        "memory_content": pattern.effect.memory_content
                    })
                    
                    # Add to active memory sequences
                    _activate_memory_sequence(pattern.pattern, pattern.effect.memory_content)
    
    # Step 2: Process through meaning transformation pipeline
    if meaning_transformation_pipeline:
        var pipeline_result = meaning_transformation_pipeline.process_text(text, {"source": source})
        
        result.transformed_text = pipeline_result.transformed_text
        result.systems_processed.append("meaning_transformation_pipeline")
        
        # Merge patterns detected
        if pipeline_result.has("patterns_detected"):
            for pattern in pipeline_result.patterns_detected:
                if not result.patterns_detected.has(pattern):
                    result.patterns_detected.append(pattern)
    
    # Step 3: If pipeline not available, use dual memories coordinator directly
    elif dual_memories_coordinator:
        var dual_result = dual_memories_coordinator.process_text(text, source)
        
        result.transformed_text = dual_result.transformed_meaning
        result.systems_processed.append("dual_memories_coordinator")
        
        # Check for terminal split
        if dual_result.terminal_split_required and terminal_split_controller:
            terminal_split_controller.set_split_mode("dual")
    
    # Step 4: Update terminals if available
    if terminal_split_controller:
        var terminal_result = terminal_split_controller.process_input(text, 0)
        result.terminal_updates = terminal_result.terminals_updated
        result.systems_processed.append("terminal_split_controller")
    
    # Add to console history
    console_history.append({
        "input": text,
        "output": result.transformed_text,
        "timestamp": OS.get_unix_time()
    })
    
    return result

# Run the next demo scenario
func run_demo_scenario(index: int = -1) -> void:
    # Use provided index or next in sequence
    if index >= 0:
        demo_scenario_index = index
    else:
        demo_scenario_index += 1
    
    var scenario_name = ""
    
    match demo_scenario_index:
        0: # Basic transformation
            scenario_name = "Basic Transformation"
            _run_basic_transformation_scenario()
            
        1: # Catchphrase detection
            scenario_name = "Catchphrase Detection"
            _run_catchphrase_detection_scenario()
            
        2: # Memory sequence reveal
            scenario_name = "Memory Sequence Reveal"
            _run_memory_sequence_scenario()
            
        3: # Terminal split demo
            scenario_name = "Terminal Split"
            _run_terminal_split_scenario()
            
        4: # Full multi-system demo
            scenario_name = "Full System Integration"
            _run_full_system_demo()
            
        _: # Reset to first scenario
            demo_scenario_index = 0
            scenario_name = "Basic Transformation"
            _run_basic_transformation_scenario()
    
    emit_signal("demo_scenario_started", scenario_name)
    debug_log("Started demo scenario: " + scenario_name)

# Clear all demo data and reset
func reset_demo() -> void:
    debug_log("Resetting demo...")
    
    # Clear console history
    console_history.clear()
    
    # Clear active memory sequences
    active_memory_sequences.clear()
    
    # Reset scenario index
    demo_scenario_index = 0
    
    # Reset memory systems
    if word_memory_system:
        word_memory_system.clear_memory()
    
    # Reset terminal display
    if terminal_split_controller:
        terminal_split_controller.set_split_mode("single")
    
    # Reset catchphrase system activation history
    if catchphrase_system:
        catchphrase_system.clear_activation_history()
    
    debug_log("Demo reset complete")

# Set debug output mode
func set_debug_output(enabled: bool) -> void:
    enable_debug_output = enabled

# Demo scenario implementations
func _run_basic_transformation_scenario() -> void:
    # Process a simple input to demonstrate basic transformation
    process_input("Hello, this is a basic transformation test")
    
    # Process with a specific transformation need
    process_input("I wish for a magical sword that freezes enemies")
    
    # Allow time for processing
    yield(get_tree().create_timer(2.0), "timeout")
    
    # Process with dimensional content
    process_input("This text spans across multiple dimensions")
    
    emit_signal("demo_scenario_completed", "Basic Transformation")

func _run_catchphrase_detection_scenario() -> void:
    # Process text with catchphrases
    process_input("The hatching of data begins now")
    
    # Allow time for processing
    yield(get_tree().create_timer(2.0), "timeout")
    
    # Another catchphrase
    process_input("We need the catchphrase system to identify special patterns")
    
    # Allow time for processing
    yield(get_tree().create_timer(2.0), "timeout")
    
    # Special character patterns
    process_input("This is a zone boundary: ####")
    
    emit_signal("demo_scenario_completed", "Catchphrase Detection")

func _run_memory_sequence_scenario() -> void:
    # Process text with memory sequences
    process_input("0000000000000000000000000000000000000000000000000000000000000")
    
    # Allow time for processing
    yield(get_tree().create_timer(3.0), "timeout")
    
    # Another memory sequence
    process_input("11111111111111111111111111111111111111111111111@")
    
    # Allow time for processing
    yield(get_tree().create_timer(3.0), "timeout")
    
    # Final memory sequence
    process_input("22222222222222222222222222222222222222####")
    
    emit_signal("demo_scenario_completed", "Memory Sequence Reveal")

func _run_terminal_split_scenario() -> void:
    # First set to single mode
    if terminal_split_controller:
        terminal_split_controller.set_split_mode("single")
    
    # Process text that should trigger split
    process_input("The dual memories system requires terminal splitting")
    
    # Allow time for processing
    yield(get_tree().create_timer(2.0), "timeout")
    
    # Switch to quad mode
    if terminal_split_controller:
        terminal_split_controller.set_split_mode("quad")
    
    # Process text for all terminals
    process_input("This text should display differently in each terminal")
    
    emit_signal("demo_scenario_completed", "Terminal Split")

func _run_full_system_demo() -> void:
    # First set to quad mode
    if terminal_split_controller:
        terminal_split_controller.set_split_mode("quad")
    
    # Process complex input with multiple triggers
    process_input("The hatching of data creates infinite ways to shape integration across dimensions")
    
    # Allow time for processing
    yield(get_tree().create_timer(3.0), "timeout")
    
    # Include a memory sequence
    process_input("The threefold memory system: 0000000000000000000000000000000000000000000000000000000000000#111111111111111111111111111111111111111111111@#222222222222222222222222222222222222####")
    
    # Allow time for processing
    yield(get_tree().create_timer(3.0), "timeout")
    
    # Final complex input
    process_input("connect Claude, claude code, desktop app, the console and editor projects, for desktop split for data seeing and buttons reasons, the whim and greed")
    
    emit_signal("demo_scenario_completed", "Full System Integration")

# Initialize core coordination systems
func _init_core_systems() -> void:
    # Initialize DualMemoriesCoordinator
    dual_memories_coordinator = DualMemoriesCoordinator.new()
    add_child(dual_memories_coordinator)
    
    # Initialize MeaningTransformationPipeline
    meaning_transformation_pipeline = MeaningTransformationPipeline.new()
    add_child(meaning_transformation_pipeline)
    
    # Initialize MemoryChannelSystem for communication
    memory_channel_system = MemoryChannelSystem.new()
    add_child(memory_channel_system)
    memory_channel_system.initialize()

# Initialize memory systems
func _init_memory_systems() -> void:
    # Initialize WordMemorySystem
    word_memory_system = WordMemorySystem.new()
    add_child(word_memory_system)
    
    # Initialize WishKnowledgeSystem
    wish_knowledge_system = WishKnowledgeSystem.new()
    add_child(wish_knowledge_system)
    
    # Connect memory systems
    if dual_memories_coordinator:
        dual_memories_coordinator.initialize(word_memory_system, wish_knowledge_system, memory_channel_system)
    
    if meaning_transformation_pipeline:
        meaning_transformation_pipeline.initialize(dual_memories_coordinator, word_memory_system, wish_knowledge_system)

# Initialize terminal systems
func _init_terminal_systems() -> void:
    # Initialize DualCoreTerminal
    dual_core_terminal = DualCoreTerminal.new()
    add_child(dual_core_terminal)
    
    # Initialize TerminalSplitController
    terminal_split_controller = TerminalSplitController.new()
    add_child(terminal_split_controller)
    
    # Initialize CatchphraseSystem
    catchphrase_system = CatchphraseSystem.new()
    add_child(catchphrase_system)
    
    # Connect terminal systems
    if terminal_split_controller:
        terminal_split_controller.initialize(
            dual_core_terminal,
            dual_memories_coordinator,
            meaning_transformation_pipeline,
            word_memory_system,
            wish_knowledge_system
        )
    
    if catchphrase_system:
        catchphrase_system.initialize(
            dual_memories_coordinator,
            meaning_transformation_pipeline,
            terminal_split_controller
        )

# Initialize UI components
func _init_ui_components() -> void:
    # This would configure UI nodes in the scene tree
    # Based on the exported NodePaths
    pass

# Connect all system signals
func _connect_signals() -> void:
    # Connect DualMemoriesCoordinator signals
    if dual_memories_coordinator:
        dual_memories_coordinator.connect("meaning_transformed", self, "_on_meaning_transformed")
        dual_memories_coordinator.connect("memory_hatched", self, "_on_memory_hatched")
        dual_memories_coordinator.connect("catchphrase_detected", self, "_on_catchphrase_detected")
    
    # Connect MeaningTransformationPipeline signals
    if meaning_transformation_pipeline:
        meaning_transformation_pipeline.connect("pipeline_completed", self, "_on_pipeline_completed")
        meaning_transformation_pipeline.connect("pattern_detected", self, "_on_pattern_detected")
    
    # Connect TerminalSplitController signals
    if terminal_split_controller:
        terminal_split_controller.connect("terminal_data_updated", self, "_on_terminal_data_updated")
        terminal_split_controller.connect("split_mode_changed", self, "_on_split_mode_changed")
    
    # Connect CatchphraseSystem signals
    if catchphrase_system:
        catchphrase_system.connect("memory_sequence_revealed", self, "_on_memory_sequence_revealed")
        catchphrase_system.connect("catchphrase_activated", self, "_on_catchphrase_activated")

# Load demo data
func _load_demo_data() -> void:
    # Add sample memory entries
    stored_memory_samples = [
        {
            "id": "memory_sample_1",
            "text": "The first memory sample demonstrates basic word storage",
            "dimension": "3D",
            "connections": ["memory_sample_2", "memory_sample_3"]
        },
        {
            "id": "memory_sample_2",
            "text": "The second memory explores temporal aspects across time",
            "dimension": "4D",
            "connections": ["memory_sample_1"]
        },
        {
            "id": "memory_sample_3",
            "text": "The third memory demonstrates multidimensional awareness",
            "dimension": "5D",
            "connections": ["memory_sample_1", "memory_sample_2"]
        }
    ]
    
    # Add sample memories to word memory system
    if word_memory_system:
        for sample in stored_memory_samples:
            var message = {
                "type": "word_create",
                "payload": {
                    "id": sample.id,
                    "text": sample.text,
                    "dimension": sample.dimension
                },
                "timestamp": OS.get_unix_time()
            }
            word_memory_system.record_word_message(message)
            
            # Create connections
            for connection in sample.connections:
                var conn_message = {
                    "type": "connection_create",
                    "payload": {
                        "from_id": sample.id,
                        "to_id": connection,
                        "strength": 0.8
                    },
                    "timestamp": OS.get_unix_time()
                }
                word_memory_system.record_word_message(conn_message)

# Activate a memory sequence
func _activate_memory_sequence(pattern: String, content: String) -> void:
    # Check if already active
    for seq in active_memory_sequences:
        if seq.pattern == pattern:
            return
    
    # Add to active sequences
    active_memory_sequences.append({
        "pattern": pattern,
        "content": content,
        "activation_time": OS.get_unix_time()
    })
    
    # Emit signal
    emit_signal("memory_activated", pattern, content)
    
    debug_log("Memory sequence activated: " + pattern)

# Debug output
func debug_log(message: String) -> void:
    if not enable_debug_output:
        return
    
    print("DualMemoriesDemo: " + message)
    
    # Update debug label if available
    var debug_label = get_node_or_null(debug_output_label_path)
    if debug_label:
        debug_label.text = message

# Signal handlers
func _on_meaning_transformed(original_text, transformed_text, source_system):
    if debug_transformation_events:
        debug_log("Meaning transformed: " + original_text + " -> " + transformed_text)

func _on_memory_hatched(memory_id, new_meaning):
    if debug_memory_events:
        debug_log("Memory hatched: " + memory_id)

func _on_catchphrase_detected(pattern, text, strength):
    if debug_catchphrase_events:
        debug_log("Catchphrase detected: " + pattern + " (strength: " + str(strength) + ")")

func _on_pipeline_completed(input_text, final_output, confidence):
    if debug_transformation_events:
        debug_log("Pipeline completed: " + input_text + " -> " + final_output)

func _on_pattern_detected(pattern, confidence, context):
    if debug_catchphrase_events:
        debug_log("Pattern detected: " + pattern + " (confidence: " + str(confidence) + ")")

func _on_terminal_data_updated(core_id, content):
    if debug_terminal_output:
        debug_log("Terminal " + str(core_id) + " updated")
    
    emit_signal("terminal_updated", core_id, content)

func _on_split_mode_changed(old_mode, new_mode):
    debug_log("Terminal split mode changed: " + str(old_mode) + " -> " + str(new_mode))

func _on_memory_sequence_revealed(sequence_id, memory_content):
    if debug_memory_events:
        debug_log("Memory sequence revealed: " + sequence_id)
    
    _activate_memory_sequence(sequence_id, memory_content)

func _on_catchphrase_activated(pattern, effect_data):
    if debug_catchphrase_events:
        debug_log("Catchphrase activated: " + pattern)