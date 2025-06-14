extends Node
class_name InitializeDualMemories

"""
InitializeDualMemories
---------------------
Central initialization script that ties all dual memory system components together.
This script handles:
1. Setup of the complete memory architecture
2. Connection to multiple storage systems (3 out of 9 pools)
3. Terminal splitting and visualization
4. Loading and saving memory sequences
5. Advanced integration with device memories

The system supports multi-device, multi-terminal configurations with special
handling for memory fragments and dimensional processing. This is the main
entry point for the entire dual memories system.
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
var dual_memories_demo: DualMemoriesDemo
var dynamic_color_system: DynamicColorSystem  # Added dynamic color system
var animation_system: AnimationSystem  # Added animation system

# Memory storage configuration
const MEMORY_STORAGE_PATHS = [
    "user://memory_storage_primary/",
    "user://memory_storage_secondary/",
    "user://memory_storage_tertiary/"
]
const TOTAL_STORAGE_POOLS = 9  # Total available pools
const ACTIVE_STORAGE_POOLS = 3  # Currently used pools

# Terminal configuration
const MAX_TERMINALS = 9
const DEFAULT_TERMINAL_COUNT = 3
const DEFAULT_TERMINAL_SPLIT_MODE = "triple_v"  # vertical split for 3 terminals
const DEFAULT_COLOR_PALETTE = "cosmic"  # Default color palette

# Memory sequence patterns
var memory_fragment_patterns = {
    "blank": "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
    "unity": "11111111111111111111111111111111111111111111111@",
    "dual": "22222222222222222222222222222222222222####",
    "hash_sequence": "##############################",
    "split_marker": "# ## ### # #"
}

# Device memory integration
var connected_devices = []
var device_memory_pools = {}

# System state
var system_initialized = false

# Signals
signal system_initialized(success, details)
signal memory_storage_connected(storage_id, status)
signal terminal_configuration_ready(terminal_count, split_mode)
signal memory_fragments_loaded(count)
signal hash_marker_processed(marker, action)
signal word_restart_detected(reason, rule)
signal message_weight_processed(text, weight)

# Initialize the entire system
func initialize() -> bool:
    print("Initializing Dual Memories System...")
    
    # Step 1: Create core systems
    _create_core_systems()
    
    # Step 2: Setup memory storage
    _setup_memory_storage()
    
    # Step 3: Configure terminals
    _configure_terminals()
    
    # Step 4: Connect memory systems
    _connect_memory_systems()
    
    # Step 5: Initialize visual systems
    _initialize_visual_systems()
    
    # Step 6: Load memory fragments
    _load_memory_fragments()
    
    # Step 7: Initialize demo
    _initialize_demo()
    
    # Mark as initialized
    system_initialized = true
    
    # Signal successful initialization
    emit_signal("system_initialized", true, {
        "active_storage_pools": ACTIVE_STORAGE_POOLS,
        "terminal_count": DEFAULT_TERMINAL_COUNT,
        "color_palette": DEFAULT_COLOR_PALETTE
    })
    
    print("Dual Memories System initialized successfully")
    return true

# Create core system components
func _create_core_systems() -> void:
    # Initialize all core components
    memory_channel_system = MemoryChannelSystem.new()
    add_child(memory_channel_system)
    memory_channel_system.initialize()
    
    word_memory_system = WordMemorySystem.new()
    add_child(word_memory_system)
    
    wish_knowledge_system = WishKnowledgeSystem.new()
    add_child(wish_knowledge_system)
    
    dual_memories_coordinator = DualMemoriesCoordinator.new()
    add_child(dual_memories_coordinator)
    
    meaning_transformation_pipeline = MeaningTransformationPipeline.new()
    add_child(meaning_transformation_pipeline)
    
    dual_core_terminal = DualCoreTerminal.new()
    add_child(dual_core_terminal)
    
    terminal_split_controller = TerminalSplitController.new()
    add_child(terminal_split_controller)
    
    catchphrase_system = CatchphraseSystem.new()
    add_child(catchphrase_system)
    
    # Add new visual systems
    animation_system = AnimationSystem.new()
    add_child(animation_system)
    
    dynamic_color_system = DynamicColorSystem.new()
    add_child(dynamic_color_system)

# Setup memory storage systems
func _setup_memory_storage() -> void:
    # Create memory storage directories
    var dir = Directory.new()
    
    for path in MEMORY_STORAGE_PATHS:
        if not dir.dir_exists(path):
            dir.make_dir_recursive(path)
        
        # Configure memory channel for this storage
        var storage_id = path.split("/")[1]
        
        if memory_channel_system:
            memory_channel_system.create_channel(
                "storage_" + storage_id,
                MemoryChannelSystem.ChannelType.SECONDARY,
                MemoryChannelSystem.StorageType.LOCAL,
                200,
                "Memory storage channel for " + storage_id
            )
            
            emit_signal("memory_storage_connected", storage_id, "connected")
    
    # Configure half-stored memory pool - special half size pool
    if memory_channel_system:
        memory_channel_system.create_channel(
            "half_storage_pool",
            MemoryChannelSystem.ChannelType.TERTIARY,
            MemoryChannelSystem.StorageType.LOCAL,
            100,  # Half the size of regular channels
            "Half-size memory storage pool"
        )

# Configure terminal system
func _configure_terminals() -> void:
    # Initialize the terminal controller
    if terminal_split_controller and dual_core_terminal:
        terminal_split_controller.initialize(
            dual_core_terminal,
            dual_memories_coordinator,
            meaning_transformation_pipeline,
            word_memory_system,
            wish_knowledge_system
        )
        
        # Create the DEFAULT_TERMINAL_COUNT terminals
        for i in range(DEFAULT_TERMINAL_COUNT):
            var core_name = "Terminal " + str(i+1)
            var assignment = null
            
            match i:
                0: 
                    assignment = TerminalSplitController.CoreAssignment.WORD_MEMORY
                    core_name = "Word Memory"
                1: 
                    assignment = TerminalSplitController.CoreAssignment.WISH_KNOWLEDGE
                    core_name = "Wish Knowledge"
                2: 
                    assignment = TerminalSplitController.CoreAssignment.DUAL_MEMORY
                    core_name = "Dual Memory"
                _: 
                    assignment = TerminalSplitController.CoreAssignment.CUSTOM
            
            # Create the terminal
            if not dual_core_terminal.cores.has(i):
                dual_core_terminal.create_core(i, core_name)
            
            # Assign its role
            terminal_split_controller.assign_core(i, assignment)
        
        # Set terminal split mode
        terminal_split_controller.set_split_mode(DEFAULT_TERMINAL_SPLIT_MODE)
        
        emit_signal("terminal_configuration_ready", DEFAULT_TERMINAL_COUNT, DEFAULT_TERMINAL_SPLIT_MODE)

# Connect memory systems
func _connect_memory_systems() -> void:
    # Connect dual memories coordinator
    if dual_memories_coordinator:
        dual_memories_coordinator.initialize(
            word_memory_system,
            wish_knowledge_system,
            memory_channel_system,
            dual_core_terminal
        )
    
    # Connect meaning transformation pipeline
    if meaning_transformation_pipeline:
        meaning_transformation_pipeline.initialize(
            dual_memories_coordinator,
            word_memory_system,
            wish_knowledge_system
        )
    
    # Connect catchphrase system
    if catchphrase_system:
        catchphrase_system.initialize(
            dual_memories_coordinator,
            meaning_transformation_pipeline,
            terminal_split_controller
        )
        
        # Add special memories from updated memory fragments
        _configure_catchphrase_patterns()

# Initialize visual systems 
func _initialize_visual_systems() -> void:
    # Initialize animation system
    if animation_system:
        animation_system.initialize(
            dual_memories_coordinator, 
            terminal_split_controller
        )
    
    # Initialize color system and connect to terminals
    if dynamic_color_system:
        dynamic_color_system.initialize(
            animation_system,
            terminal_split_controller,
            dual_memories_coordinator,
            meaning_transformation_pipeline
        )
        
        # Set initial color palette
        dynamic_color_system.set_color_palette(DEFAULT_COLOR_PALETTE, false)
        
        # Connect signals
        dynamic_color_system.connect("message_weight_detected", self, "_on_message_weight_detected")
        dynamic_color_system.connect("hash_marker_processed", self, "_on_hash_marker_processed")
        dynamic_color_system.connect("rainbow_mode_toggled", self, "_on_rainbow_mode_toggled")

# Configure catchphrase patterns from updated memory fragments
func _configure_catchphrase_patterns() -> void:
    if catchphrase_system:
        # Update with special hash patterns from CLAUDE.local.md
        catchphrase_system.add_catchphrase("# ## ### # #", "exact", {
            "type": "terminal_split",
            "confidence": 0.95,
            "split_mode": "triple_v",
            "effect_description": "Splits terminal into three vertical panels"
        })
        
        catchphrase_system.add_catchphrase("##############################", "exact", {
            "type": "hash_sequence",
            "confidence": 1.0,
            "replacement": "[HASH SEQUENCE ACTIVATED]",
            "effect_description": "Activates hash sequence for terminal splitting"
        })
        
        # Add pattern for 3 storage pools reference
        catchphrase_system.add_catchphrase("3 storages of 9 storages", "fuzzy", {
            "type": "storage_pools",
            "confidence": 0.9,
            "replacement": "[3/9 STORAGE POOLS ACTIVE]",
            "effect_description": "References the memory storage pool configuration"
        })
        
        # Add pattern for "memories of what i see in terminal"
        catchphrase_system.add_catchphrase("memories of what i see in terminal", "fuzzy", {
            "type": "terminal_mirror", 
            "confidence": 0.8,
            "effect_description": "Mirrors terminal content into memory system"
        })
        
        # Add special catchphrases for restart, rules, and reason
        catchphrase_system.add_catchphrase("restart by rules", "fuzzy", {
            "type": "restart_rule",
            "confidence": 0.9,
            "effect_description": "Restart process following rule system"
        })
        
        catchphrase_system.add_catchphrase("reason reason", "exact", {
            "type": "double_reason",
            "confidence": 1.0,
            "effect_description": "Emphasizes reasoning process with repetition"
        })
        
        catchphrase_system.add_catchphrase("words are", "fuzzy", {
            "type": "word_definition",
            "confidence": 0.8,
            "effect_description": "Defines the nature of words in the system"
        })
    }

# Load memory fragments
func _load_memory_fragments() -> void:
    var fragment_count = 0
    
    # Add blank memory fragment
    if word_memory_system:
        var message = {
            "type": "word_create",
            "payload": {
                "id": "blank_memory_fragment",
                "text": memory_fragment_patterns.blank,
                "dimension": "void"
            },
            "timestamp": OS.get_unix_time()
        }
        word_memory_system.record_word_message(message)
        fragment_count += 1
        
        # Add unity fragment
        message = {
            "type": "word_create",
            "payload": {
                "id": "unity_memory_fragment",
                "text": memory_fragment_patterns.unity,
                "dimension": "linear"
            },
            "timestamp": OS.get_unix_time()
        }
        word_memory_system.record_word_message(message)
        fragment_count += 1
        
        # Add dual fragment
        message = {
            "type": "word_create",
            "payload": {
                "id": "dual_memory_fragment",
                "text": memory_fragment_patterns.dual,
                "dimension": "dual"
            },
            "timestamp": OS.get_unix_time()
        }
        word_memory_system.record_word_message(message)
        fragment_count += 1
        
        # Add hash sequence fragment
        message = {
            "type": "word_create",
            "payload": {
                "id": "hash_sequence_fragment",
                "text": memory_fragment_patterns.hash_sequence,
                "dimension": "hash"
            },
            "timestamp": OS.get_unix_time()
        }
        word_memory_system.record_word_message(message)
        fragment_count += 1
        
        # Add split marker fragment
        message = {
            "type": "word_create",
            "payload": {
                "id": "split_marker_fragment",
                "text": memory_fragment_patterns.split_marker,
                "dimension": "split"
            },
            "timestamp": OS.get_unix_time()
        }
        word_memory_system.record_word_message(message)
        fragment_count += 1
    }
    
    emit_signal("memory_fragments_loaded", fragment_count)

# Initialize demo scene
func _initialize_demo() -> void:
    dual_memories_demo = DualMemoriesDemo.new()
    add_child(dual_memories_demo)
    
    # Configure demo to use our existing systems
    if dual_memories_demo:
        dual_memories_demo.dual_memories_coordinator = dual_memories_coordinator
        dual_memories_demo.meaning_transformation_pipeline = meaning_transformation_pipeline
        dual_memories_demo.terminal_split_controller = terminal_split_controller
        dual_memories_demo.catchphrase_system = catchphrase_system
        dual_memories_demo.word_memory_system = word_memory_system
        dual_memories_demo.wish_knowledge_system = wish_knowledge_system
        dual_memories_demo.dual_core_terminal = dual_core_terminal
        dual_memories_demo.memory_channel_system = memory_channel_system
        
        # Add new component references to demo
        if "animation_system" in dual_memories_demo:
            dual_memories_demo.animation_system = animation_system
        
        if "dynamic_color_system" in dual_memories_demo:
            dual_memories_demo.dynamic_color_system = dynamic_color_system
            
        # Mark demo as initialized
        dual_memories_demo.demo_initialized = true

# Process input through the entire system
func process_input(text: String, source: String = "user") -> Dictionary:
    if not system_initialized:
        return {"error": "System not initialized"}
    
    var result = {
        "original_text": text,
        "processed_text": text,
        "hash_processed": false,
        "hash_effect": "",
        "restart_detected": false,
        "weight_processed": false,
        "message_weight": "medium",
        "color_applied": false
    }
    
    # First check for special hash markers
    if dynamic_color_system:
        var hash_result = dynamic_color_system.process_hash_markers(text)
        if hash_result.hash_markers_removed:
            result.hash_processed = true
            result.hash_effect = hash_result.action
            text = hash_result.text  # Updated text with hash markers removed
    
    # Check for restart by rules
    if dynamic_color_system:
        var restart_result = dynamic_color_system.process_word_restart(text)
        if restart_result.restart_detected:
            result.restart_detected = true
            result.processed_text = restart_result.processed_text
            result.color_applied = true
            
            # Emit signal for restart detection
            emit_signal("word_restart_detected", restart_result.restart_type, text)
    
    # Check for message weight if enabled
    if dynamic_color_system and dynamic_color_system.message_weight_coloring:
        var weight = dynamic_color_system._analyze_message_weight(text)
        result.weight_processed = true
        result.message_weight = weight
    
    # Process through demo system if available
    if dual_memories_demo and dual_memories_demo.demo_initialized:
        var demo_result = dual_memories_demo.process_input(text, source)
        
        # Merge demo result with our result
        for key in demo_result.keys():
            result[key] = demo_result[key]
        
        return result
    
    # Otherwise process with meaning transformation pipeline
    elif meaning_transformation_pipeline:
        var pipeline_result = meaning_transformation_pipeline.process_text(text, source)
        result.processed_text = pipeline_result.transformed_text
        
        # Apply color if not already applied
        if dynamic_color_system and not result.color_applied:
            result.processed_text = dynamic_color_system.color_text_by_content(
                result.processed_text, "dual")
            result.color_applied = true
    
    # Update terminal displays
    if terminal_split_controller:
        terminal_split_controller.process_input(text, 0)
    
    return result

# Process a hash marker command
func process_hash_marker(marker: String) -> Dictionary:
    var result = {
        "processed": false,
        "action": "",
        "details": {}
    }
    
    # First process through dynamic color system if available
    if dynamic_color_system:
        var hash_result = dynamic_color_system.process_hash_markers(marker)
        if hash_result.hash_markers_removed:
            result.processed = true
            result.action = hash_result.action
            result.details["color_change"] = hash_result.color_change
            
            # Emit signal
            emit_signal("hash_marker_processed", marker, result.action)
            
            return result
    
    # Count number of # characters
    var hash_count = 0
    for c in marker:
        if c == '#':
            hash_count += 1
    
    # Different actions based on hash count
    if hash_count == 1:
        # Simple marker - just store
        result.processed = true
        result.action = "store"
    elif hash_count >= 3 and hash_count < 10:
        # Terminal split request
        result.processed = true
        result.action = "split_terminal"
        result.details.terminal_count = min(hash_count, MAX_TERMINALS)
        
        # Configure terminal split
        if terminal_split_controller:
            var split_mode = "single"
            if hash_count == 2:
                split_mode = "dual"
            elif hash_count == 3:
                split_mode = "triple_v"
            elif hash_count == 4:
                split_mode = "quad"
            else:
                split_mode = "custom"
            
            terminal_split_controller.set_split_mode(split_mode)
    elif hash_count >= 10:
        # Memory sync request
        result.processed = true
        result.action = "memory_sync"
        result.details.sync_level = min(hash_count / 10, 9)
        
        # Trigger memory sync across all pools
        if memory_channel_system:
            # Create synchronization task
            memory_channel_system.create_task(
                "memory_sync_task",
                MemoryChannelSystem.Priority.HIGH, 
                5.0,
                {"sync_level": result.details.sync_level}
            )
    
    # Emit signal
    emit_signal("hash_marker_processed", marker, result.action)
    
    return result

# Signal handlers
func _on_hash_marker_processed(marker_count, mode):
    # Trigger appropriate actions based on hash marker
    if animation_system and (mode == "rainbow" or mode == "rainbow_pulse"):
        # Create rainbow flow animation
        animation_system.create_akashic_flow_animation(1.0, 0.7)

func _on_message_weight_detected(text, weight):
    # Emit message weight signal
    emit_signal("message_weight_processed", text, weight)

func _on_rainbow_mode_toggled(enabled):
    if animation_system and enabled:
        # Create color flow animation
        animation_system.create_falling_text_animation("Rainbow mode activated", "flat")